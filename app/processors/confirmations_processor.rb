class ConfirmationsProcessor < ApplicationProcessor
  # NOTE: Use node instead of confirmation
  model_name "Node"

  keys [
    :identifier,
    :name,
    {confirmation: [
      :status,
      :existence,
      :content,
      :os_update,
      :app_update,
      :software,
      :security_update,
      :security_scan,
      security_hardwares: [],
      security_software: [:installation_method, :name],
    ]},
  ]

  converter :confirmation, get: ->(record) { record.solid_confirmation }

  # override
  def output_filter(output)
    output.delete(:id)
    output
  end

  def create(params)
    user_process(nil, :confirm) do |record|
      record.transaction do
        assign_params(params, record:)
        record.save || raise(ActiveRecord::Rollback)
      end
    end
  end

  def update(id, params)
    raise "Not allowed to update confirmation"
  end

  def destroy(id)
    raise "Not allowed to destroy confirmation"
  end
end
