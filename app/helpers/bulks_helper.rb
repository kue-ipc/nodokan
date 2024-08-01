module BulksHelper
  BULK_LIST_COLS = [
    {name: :user,       grid: [0, 0, 0, 1, 1, 1], sort: :user},
    {name: :target,     grid: [0, 0, 2, 1, 1, 1], sort: :model},
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

  def bulk_targets
    if current_user.admin?
      [
        "Node",
        # "Confirmation",
        "Network",
        "User",
      ]
    else
      [
        "Node",
        # "Confirmation",
      ]
    end
  end

  def bulk_target_list
    bulk_targets.map do |target|
      [target, t(target.underscore, scope: "activerecord.models")]
    end
  end
end
