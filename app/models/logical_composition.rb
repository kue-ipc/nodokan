class LogicalComposition < ApplicationRecord
  has_paper_trail

  belongs_to :node
  belongs_to :component, class_name: "Node", inverse_of: :composed_compositions
end
