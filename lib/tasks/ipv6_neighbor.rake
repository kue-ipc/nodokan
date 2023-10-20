namespace :ipv6_neighbor do
  desc "TODO"
  task register: :environment do
    PaperTrail.request.disable_model(Ipv6Neighbor)
  end
end
