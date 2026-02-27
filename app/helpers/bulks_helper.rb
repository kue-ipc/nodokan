module BulksHelper
  BULK_LIST_COLS = [
    {name: :user,       grid: [0, 0, 0, 1, 1, 1], sort: :users_username},
    {name: :target,     grid: [0, 0, 2, 1, 1, 1], sort: :target},
    {name: :created_at, grid: [5, 5, 4, 4, 2, 2], sort: :created_at},
    {name: :updated_at, grid: [0, 0, 0, 0, 2, 2], sort: :updated_at},
    {name: :status,     grid: [2, 2, 2, 1, 1, 1], sort: :status},
    {name: :count,      grid: [0, 0, 0, 1, 1, 1]},
    {name: :input,      grid: [0, 0, 0, 1, 1, 1]},
    {name: :output,     grid: [2, 2, 2, 1, 1, 1]},
    {name: :action,     grid: [3, 3, 2, 2, 2, 2]},
  ].freeze

  def bulk_list_cols
    BULK_LIST_COLS
  end

  def bulk_target_models
    if current_user.admin?
      [Node, Confirmation, Network, User]
    else
      [Node, Confirmation]
    end
  end

  def bulk_target_list
    bulk_target_models.map do |model|
      [model.model_name.human, model.model_name.element]
    end
  end

  def bulk_content_type_list
    [
      ["CSV", "text/csv"],
      ["YAML", "application/yaml"],
      ["JSONL", "application/jsonl"],
    ]
  end
end
