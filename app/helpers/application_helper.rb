module ApplicationHelper
  def site_title
    Settings.site.title || t(:nodokan)
  end

  def model_class(model = nil)
    if model.nil?
      controller.controller_name.classify.constantize
    elsif model.is_a?(ActiveRecord)
      model.class
    else
      model
    end
  end

  def candidate_values(model, target, list = [], order: nil, limit: 100)
    condition = list.index_with { |name| model.__send__(name) }
    models = policy_scope(model.class)
    models = models.where(condition) if condition.present?
    models = models.order(order) if order
    models.limit(limit).distinct.pluck(target)
  end
end
