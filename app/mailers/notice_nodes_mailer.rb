class NoticeNodesMailer < ApplicationMailer
  after_deliver :update_notice

  # admin
  def unowned = admin_notice("unowned")
  def deleted_owner = admin_notice("deleted_owner")
  # special
  def destroyed = special_notice("destroyed")
  # user
  def destroy_soon = user_notice("destroy_soon")
  def disabled = user_notice("disabled")
  def disable_soon = user_notice("disable_soon")
  def unconfirmed = user_notice("unconfirmed")
  def approved = user_notice("approved")
  def unapproved = user_notice("unapproved")
  def expired = user_notice("expired")
  def expire_soon = user_notice("expire_soon")

  private def admin_notice(name)
    @notice = name
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: Settings.admin_email
  end

  private def user_notice(name)
    @notice = name
    @user = params[:user]
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: @user.email
  end

  private def special_notice(name)
    @notice = name
    @user = params[:user]
    @nodes = params[:nodes].map { |params| Node.new(params) }
    mail subject: subject_with_site_title, to: @user.email
  end

  private def update_notice
    # do nothing if @ids is not set
    return unless @ids

    # rubocop:disable Rails/SkipsModelValidations
    Node.where(id: @ids).update_all(notice: @notice, noticed_at: Time.current)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
