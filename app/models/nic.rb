class Nic < ApplicationRecord
  belongs_to :node
  belongs_to :network
end
