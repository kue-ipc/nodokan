class LogicalComposition < ApplicationRecord
  belongs_to :node
  belongs_to :component, class_name: "Node", inverse_of: :composed_compositions
end
