module Page
  extend ActiveSupport::Concern

  private def set_page(page: nil, per: nil)
    @page = params[:page]&.to_i || page
    @per = params[:per]&.to_i || per
    @per = nil if @per&.zero?
    @page_params = {
      page: @page,
      per: @per,
    }
  end

  private def page_params
    @page_params || (raise "No set_page")
  end

  private def paginate(model)
    model.page(@page).per(@per)
  end
end
