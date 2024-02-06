module Page
  extend ActiveSupport::Concern

  private def set_page
    @page = params[:page]&.to_i
    @per = params[:per]&.to_i
  end

  private def paginate(model)
    model.page(@page).per(@per)
  end
end
