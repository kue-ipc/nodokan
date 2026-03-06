require "stringio"

class NodeCheckPerUserJob < ApplicationJob
  class Update
    def initialize(updates, codition: nil)
      @updates = updates
      @condition = codition&.to_proc
      @nodes = []
    end

    def add(node, force: false)
      @nodes << node if force || @condition.nil? || @condition.call(node)
    end
    alias << add

    def run
      Node.where(id: @node.map(&:id)).update_all(@updates) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  class Notice
    def initialize(name, time: Time.current)
      @name = name
      @time = time
      @node = []
    end

    def add(node, force: false, time: @time)
      @nodes << node if force || node.need_notice?(@name, time:)
    end
    alias << add

    def deliver_mail(user)
      if @nodes.present?
        NoticeNodesMailer.with(user:, nodes: @nodes).__send__(@name).deliver_later
      end
    end
  end

  queue_as :check

  def perform(user, time: Time.current)
    unless Settings.feature.node_check
      Ralis.logger.info "Node check is disabled. Skipping NodeCheckPerUserJob for @user #{@user.username}."
      return
    end

    @user = @user
    @time = time
    @counts = Hash.new(0)

    @update_dict = {
      reset_notice: Update.new({notice: :nil, noticed_at: nil},
        codition: ->(node) { node.notice || node.notice_at }),
      reset_execution: Update.new({execution_at: nil},
        codition: ->(node) { node.execution_at }),
      schedule_destroy: Update.new({execution_at: @time + Node.destroy_grace_period}, all: true,
        codition: ->(node) { !node.execution_at || !node.notice_destroy_soon? }),
      schedule_disable: Update.new({execution_at: @time + Node.disable_grace_period}, all: true,
        codition: ->(node) { !node.execution_at || !node.notice_disable_soon? }),
    }
    @notice_dict = Node.notices.keys.index_with { |name| Notice.new(name, time: @time) }
    @execute_dict = {
      disbale: [],
      destroy: [],
    }

    check_nodes_per_user

    disable_all
    destroy_all

    updates.each { |update| update.run }
    notices.each { |notice| notice.deliver_mail(@user) }

    logger.info("Result check node for #{@user.username}: #{counts.to_json}")
    if @counts[:error]&.positive?
      raise "Failed to check nodes for #{@user.username}: #{@counts[:error]} errors occurred."
    end
  end

  def check_nodes_per_user

    @user.nodes.includes(:confirmation, nics: :network).find_each do |node|
      if Settings.config.auto_destroy_node && node.should_destroy?(time: @time)
        if Node.destroy_grace_period <= 0 || (node.execution_at&.<=(@time) && node.notice_destroy_soon?)
          @execute_dict[:destroy] << node
        else
          @update_dict[:schedule_destroy] << node
          @notice_dict[:destroy_soon] << node
        end
      elsif node.disabled?
        @update_dict[:reset_execution] << node
        @notice_dict[:disabled] << node
      elsif Settings.config.auto_disable_node && node.should_disable?(time: @time)
        if Node.disable_grace_period <= 0 || (node.execution_at&.<=(@time) && node.notice_disable_soon?)
          @execute_dict[:disable] << node
        else
          @update_dict[:schedule_disable] << node
          @notice_dict[:disable_soon] << node
        end
      elsif Settings.feature.confirmation
        @update_dict[:reset_execution] << node
        case (status = node.solid_confirmation.status(time: @time))
        when :unconfirmed, :expired, :expire_soon
          @notice_dict[status] << node
        else
          @update_dict[:reset_notice] << node
        end
      else
        @update_dict[:reset_execution] << node
        @update_dict[:reset_notice] << node
      end
    end
  end

  def disable_all
    nodes = @execute_dict[:disable]
    return if nodes.blank?

    nodes.each do |node|
      if node.update({disabled: true})
        @update_dict[:reset_execution] << node
        @notice_dict[:disabled] << node
        @counts[:disable] += 1
      else
        Rails.logger.error do
          "Failed to disable node #{node.id} for #{@user.username}: #{node.errors.full_messages.join(", ")}"
        end
        @counts[:error] += 1
      end
    end
  end

  def destroy_all
    nodes = @execute_dict[:destroy]
    return if nodes.blank?

    bulk = Bulk.new(user: @user, target: "node")
    destroy_nodes_jsonl = nodes.map { |node| {id: node.id, _destroy: true}.to_json }.join("\n")
    io = StringIO.new(destroy_nodes_jsonl)
    filename = "auto_destroy_nodes_#{@time.strftime('%Y%m%d%H%M%S')}.jsonl"
    bulk.output.attach(io:, filename:, content_type: "application/jsonl", identify: false)
    if bulk.save
      nodes.each do |node|
        @notice_dict[:destroyed].add(node.serializable_hash, force: true)
        @counts[:destroy] += 1
      end
    else
      Rails.logger.error do
        "Failed to create bulk for destroying nodes for #{@user.username}: #{bulk.errors.full_messages.join(", ")}"
      end
      @counts[:error] += nodes.size
    end
  end
end
