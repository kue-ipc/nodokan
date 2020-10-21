class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def top
    unless user_signed_in?
      render 'devise/sessions/new'
      return
    end

    @unconfirmed_nodes_count =
      policy_scope(Node).where.not(confirmed_at: Time.current.ago(1.year)..)
        .or(policy_scope(Node).where(confirmed_at: nil)).count
    @networks = policy_scope(Network).all

    # flash[:alert] ||= []
    # flash[:alert] << content_tag(:div, 'hoge')
  end

  def about
  end
end
