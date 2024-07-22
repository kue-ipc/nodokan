module BulksHelper
  BULK_LIST_COLS = [
    {name: :user,       grid: [0, 0, 2, 2, 1, 1], sort: :user},
    {name: :created_at, grid: [5, 5, 4, 4, 2, 2], sort: :created_at},
    {name: :updated_at, grid: [0, 0, 0, 0, 2, 2], sort: :updated_at},
    {name: :status,     grid: [2, 2, 2, 1, 1, 1], sort: :status},
    {name: :number,     grid: [0, 0, 0, 1, 1, 1]},
    {name: :success,    grid: [0, 0, 0, 1, 1, 1]},
    {name: :failure,    grid: [0, 0, 0, 1, 1, 1]},
    {name: :file,       grid: [0, 0, 0, 0, 1, 1]},
    {name: :result,     grid: [2, 2, 2, 1, 1, 1]},
    {name: :action,     grid: [3, 3, 2, 1, 1, 1]},
  ].freeze

  def bulk_list_cols
    BULK_LIST_COLS
  end
end
