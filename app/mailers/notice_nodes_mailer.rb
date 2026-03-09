class NoticeNodesMailer < ApplicationMailer
  after_deliver :update_notice

  # admin
  def unowned = admin_notice("unowned")
  def deleted_owner = admin_notice("deleted_owner")
  # special
  def destroyed
    @notice = "destroyed"
    @user = params[:user]
    @nodes = params[:nodes] # not records, serializable hashes
    @bulk = params[:bulk]
    mail subject: subject_with_site_title, to: @user.email, cc: Settings.admin.email
  end
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
    @nodes = params[:nodes]
    mail subject: subject_with_site_title, to: Settings.admin.email
  end

  private def user_notice(name)
    @notice = name
    @user = params[:user]
    @nodes = params[:nodes]
    mail subject: subject_with_site_title, to: @user.email
  end

  private def update_notice
    return unless @nodes.first.is_a?(Node)

    updates = {notice: @notice, noticed_at: Time.current}
    Node.where(id: @nodes.map(&:id)).update_all(updates) # rubocop:disable Rails/SkipsModelValidations
  end
end
