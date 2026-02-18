class NodeCheckPerUserJob < ApplicationJob
  queue_as :check

  def perform(user, time = Time.current)
    destroy_nodes = []

    action_node_ids = {
      reset_notice: [],
      reset_execution: [],
      # destroy: [],
      disable: [],
      schedule_destroy: [],
      schedule_disable: [],
    }

    notice_node_ids = {
      # destroyed: [],
      disabled: [],
      expired: [],
      destroy_soon: [],
      disable_soon: [],
      expire_soon: [],
    }

    user.nodes.includes(nics: :network).find_each do |node|
      if node.should_destroy?
        if Node.destroy_grace_period <= 0 || (node.execution_at&.<=(time) && node.notice_destroy_soon?)
          destroy_nodes << node
        elsif node.execution_at.nil? || !node.notice_destroy_soon?
          action_node_ids[:schedule_destroy] << node.id
          notice_node_ids[:destroy_soon] << node.id
        elsif node.need_notice?(:destroy_soon, time)
          notice_node_ids[:destroy_soon] << node.id
        end
      elsif node.disabled?
        action_node_ids[:reset_execution] << node.id unless node.execution_at.nil?
        notice_node_ids[:disabled] << node.id if node.need_notice?(:disabled, time)
      elsif node.should_disable?
        if Node.disable_grace_period <= 0 || (node.execution_at&.<=(time) && node.notice_disable_soon?)
          action_node_ids[:disable] << node.id
          notice_node_ids[:disabled] << node.id
        elsif node.execution_at.nil? || !node.notice_disable_soon?
          action_node_ids[:schedule_disable] << node.id
          notice_node_ids[:disable_soon] << node.id
        elsif node.need_notice?(:disable_soon, time)
          notice_node_ids[:disable_soon] << node.id
        end
      elsif node.expired?
        action_node_ids[:reset_execution] << node.id unless node.execution_at.nil?
        notice_node_ids[:expired] << node.id if node.need_notice?(:expired, time)
      elsif node.expire_soon?
        action_node_ids[:reset_execution] << node.id unless node.execution_at.nil?
        notice_node_ids[:expire_soon] << node.id if node.need_notice?(:expire_soon, time)
      else
        action_node_ids[:reset_execution] << node.id unless node.execution_at.nil?
        notice_node_ids[:reset_notice] << node.id unless node.notice_none? && node.notice_at.nil?
      end
    end

    # actions
    # rubocop:disable Rails/SkipsModelValidations
    if action_node_ids[:reset_notice].present?
      Node.where(id: action_node_ids[:reset_notice]).update_all(notice: :none, noticed_at: nil)
    end
    if action_node_ids[:reset_execution].present?
      Node.where(id: action_node_ids[:reset_execution]).update_all(execution_at: nil)
    end
    if action_node_ids[:disable].present?
      Node.where(id: action_node_ids[:disable]).update_all(disabled: true, execution_at: nil)
    end
    if action_node_ids[:schedule_destroy].present?
      Node.where(id: action_node_ids[:schedule_destroy]).update_all(execution_at: time + Node.destroy_grace_period)
    end
    if action_node_ids[:schedule_disable].present?
      Node.where(id: action_node_ids[:schedule_disable]).update_all(execution_at: time + Node.disable_grace_period)
    end
    # rubocop:enable Rails/SkipsModelValidations

    # notices
    if notice_node_ids[:disabled].present?
      NoticeNodesMaler.with(ids: notice_node_ids[:disabled], user:).disbaled.deliver_later
    end
    if notice_node_ids[:expired].present?
      NoticeNodesMaler.with(ids: notice_node_ids[:expired], user:).expired.deliver_later
    end
    if notice_node_ids[:destroy_soon].present?
      NoticeNodesMaler.with(ids: notice_node_ids[:destroy_soon], user:).destroy_soon.deliver_later
    end
    if notice_node_ids[:disable_soon].present?
      NoticeNodesMaler.with(ids: notice_node_ids[:disable_soon], user:).disbale_soon.deliver_later
    end
    if notice_node_ids[:expire_soon].present?
      NoticeNodesMaler.with(ids: notice_node_ids[:expire_soon], user:).expire_soon.deliver_later
    end

    # destroy
    if destroy_nodes.present?
      error_count = 0
      processor = ImportExport::Processors::NodesProcessor.new
      destroyed_nodes_params = []
      destroy_nodes.each do |node|
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
  end
end
