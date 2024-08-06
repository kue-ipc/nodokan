module Page
  extend ActiveSupport::Concern

  private def set_page(page: nil, per: nil)
    @page = params[:page]&.to_i || page
    @per = params[:per]&.to_i || per
  end

  private def paginate(model)
    model.page(@page).per(@per)
  end
end
