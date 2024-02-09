class LogicalComposition < ApplicationRecord
  belongs_to :node
  belongs_to :component, class_name: "Node", foreign_key: "node_id", inverse_of: :composed_compositions
end
