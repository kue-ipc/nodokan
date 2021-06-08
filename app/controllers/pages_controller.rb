class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def top
    unless user_signed_in?
      render 'devise/sessions/new'
      return
    end

    @need_confirm_count =
      policy_scope(Node).includes(:confirmation)
        .where.not(confirmations: Confirmation.all)
        .or(policy_scope(Node).includes(:confirmation)
          .where(confirmations: { expiration: Time.current.. }))
        .count
    @networks = policy_scope(Network).all

    # flash[:alert] ||= []
    # flash[:alert] << content_tag(:div, 'hoge')
  end

  def about
  end
end
