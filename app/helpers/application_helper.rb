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
end
