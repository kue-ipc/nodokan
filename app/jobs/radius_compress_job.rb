class RadiusCompressJob < ApplicationJob
  queue_as :default

  def perform(*args)
    count = 0
    Radius::Radpostauth.group(:username).count.filter { |_k, v| v > 1 }.each_key do |username|
      last = Radius::Radpostauth.where(username: username).order(:authdate).last
      count += Radius::Radpostauth.where(username: username).where.not(id: last.id).destroy_all.count
    end
    logger.info("Destroied: #{count}")
  end
end
