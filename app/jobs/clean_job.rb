class CleanJob < ApplicationJob
  LIMIT_SIZE = 1000

  def delete_records(relation, size: LIMIT_SIZE, once: false)
    if !size.positive?
      relation.delete_all
    elsif once
      relation.limit(size).delete_all
    else
      total = 0
      loop do
        count = relation.limit(size).delete_all
        total += count
        break if count < size

        logger.debug("Repeat deletion")
      end
      total
    end
  end
end
