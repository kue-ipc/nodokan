class RadiusCompressJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    limit_size = 1000
    total = 0
    Radius::Radpostauth.group(:username).count.filter { |_k, v| v > 1}
      .each do |username, count|
      ((count / limit_size) + 1).times do
        total += Radius::Radpostauth
          .where(username: username)
          .where.not(id: Radius::Radpostauth.where(username: username)
            .order(:authdate).last.id)
          .limit(limit_size).delete_all
      end
    end
    logger.info("Deleted: #{total}")
  end
end
