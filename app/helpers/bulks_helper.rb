module BulksHelper
  BULK_LIST_COLS = [
    {name: :user,       grid: [0, 0, 0, 1, 1, 1], sort: :user},
    {name: :model,      grid: [0, 0, 2, 1, 1, 1], sort: :model},
    {name: :created_at, grid: [5, 5, 4, 4, 2, 2], sort: :created_at},
    {name: :updated_at, grid: [0, 0, 0, 0, 2, 2], sort: :updated_at},
    {name: :status,     grid: [2, 2, 2, 1, 1, 1], sort: :status},
    {name: :count,      grid: [0, 0, 0, 1, 1, 1]},
    {name: :file,       grid: [0, 0, 0, 1, 1, 1]},
    {name: :result,     grid: [2, 2, 2, 1, 1, 1]},
    {name: :action,     grid: [3, 3, 2, 2, 2, 2]},
  ].freeze

  def bulk_list_cols
    BULK_LIST_COLS
  end

  def bulk_model_list
    if current_user.admin?
      [
        ["Node", Node.model_name.human],
        # ["Confirmation", Confirmation.model_name.human],
        ["Network", Network.model_name.human],
        ["User", User.model_name.human],
      ]
    else
      [
        ["Node", Node.model_name.human],
        # ["Confirmation", Confirmation.model_name.human],
      ]
    end
  end
end
