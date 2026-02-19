class NodeCheckPerUserJob < ApplicationJob
  queue_as :check

  def perform(user, time: Time.current)
    unless Settings.feature.node_check
      Ralis.logger.info "Node check is disabled. Skipping NodeCheckPerUserJob for user #{user.username}."
      return
    end

    updates, notices, destroy_nodes = check_nodes_per_user(user, time:)
    updates.each { |update| update.run }
    notices.each { |notice| notice.deliver_mail(user) }
    destroy(destroy_nodes, user)
  end

  def check_nodes_per_user(user, time: Time.current)
    update_dict = {
      reset_notice: Update.new({notice: :none, noticed_at: nil},
        codition: ->(node) { !node.notice_none? || !node.notice_at.nil? }),
      reset_execution: Update.new({execution_at: nil},
        codition: ->(node) { !node.execution_at.nil? }),
      disable: Update.new({disabled: true, execution_at: nil},
        codition: ->(node) { !node.disabled? }),
      schedule_destroy: Update.new({execution_at: time + Node.destroy_grace_period},
        codition: ->(node) { node.execution_at.nil? || !node.notice_destroy_soon? }),
      schedule_disable: Update.new({execution_at: time + Node.disable_grace_period},
        codition: ->(node) { node.execution_at.nil? || !node.notice_disable_soon? }),
    }
    notice_dict = Node.notices.valuse.to_h do |name, _|
      name = name.intern
      [name, Notice.new(name, time:)]
    end
    destroy_nodes = []

    user.nodes.includes(:confirmation, nics: :network).find_each do |node|
      if Settings.config.auto_destroy_node && node.should_destroy?(time:)
        if Node.destroy_grace_period <= 0 || (node.execution_at&.<=(time) && node.notice_destroy_soon?)
          destroy_nodes << node
        else
          update_dict[:schedule_destroy].add(node)
          notice_dict[:destroy_soon].add(node)
        end
      elsif node.disabled?
        update_dict[:reset_execution].add(node)
        notice_dict[:disabled].add(node)
      elsif Settings.config.auto_disable_node && node.should_disable?(time:)
        if Node.disable_grace_period <= 0 || (node.execution_at&.<=(time) && node.notice_disable_soon?)
          update_dict[:disable].add(node)
          notice_dict[:disabled].add(node)
        else
          update_dict[:schedule_disable].add(node)
          notice_dict[:disable_soon].add(node)
        end
      elsif Settings.feature.confirmation
        update_dict[:reset_execution].add(node)
        case (status = node.solid_confirmation.status(time:))
        when :unconfirmed, :expired, :expire_soon
          notice_dict[status].add(node)
        else
          update_dict[:reset_notice].add(node)
        end
      else
        update_dict[:reset_execution].add(node)
        update_dict[:reset_notice].add(node)
      end
    end
    [update_dict.values, notice_dict.values, destroy_nodes]
  end

  def destroy(nodes, user)
    return if nodes.blank?

    # TODO: Bulkにしてもいいかもしれない？
    error_count = 0
    processor = ImportExport::Processors::NodesProcessor.new
    destroyed_nodes_params = []
    nodes.each do |node|
      params = processor.record_to_params(node)
      node.destroy!
      destroyed_nodes_params << params
    rescue StandardError => e
      logger.error("Failed to destroy a node: #{node.id} - #{e.message}")
      error_count += 1
    end
    NoticeNodesMaler.with(nodes_params: destroyed_nodes_params, user:).destroyed.deliver_later

    if error_count.positive?
      raise "error occurred while destroying nodes for user #{user.username}."
    end
  end

  class Update
    def initialize(updates, codition: nil)
      @updates = updates
      @condition = codition&.to_proc
      @node_ids = []
    end

    def add(node, force: false)
      @node_ids << node.id if force || @condition.nil? || @condition.call(node)
    end

    def run
      if @node_ids.present?
        # rubocop:disable Rails/SkipsModelValidations
        Node.where(id: @node_ids).update_all(updates)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end

  class Notice
    def initialize(name, time: Time.current)
      @name = name
      @time = time
      @node_ids
    end

    def add(node, force: false, time: @time)
      @node_ids << node.id if force || node.need_notice?(@notice, time:)
    end

    def deliver_mail(user)
      if @node_ids.present?
        NoticeNodesMaler.with(ids: @node_ids, user:).__send__(@name).deliver_later
      end
    end
  end
end
