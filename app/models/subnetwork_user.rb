class SubnetworkUser < ApplicationRecord
  belongs_to :user
  belongs_to :subnetwork
end
