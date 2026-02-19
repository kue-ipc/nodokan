class NoticeNodesMailer < ApplicationMailer
  after_deliver :update_notice

  # no notice
  def none = nil

  # spcifided notice
  def destroyed
    @notice = "destroyed"
    @user = params[:user]
    processor = ImportExport::Processors::NodesProcessor.new
    @nodes = params[:nodes_params].map { |node_param| processor.params_to_record(node_param) }
    mail subject: subject_with_site_title, to: @user.email
  end

  # normal notice
  def destroy_soon = nromal_notice("destroy_soon")
  def disabled = nromal_notice("disabled")
  def disable_soon = nromal_notice("disable_soon")
  def unconfirmed = nromal_notice("unconfirmed")
  def approved = nromal_notice("approved")
  def unapproved = nromal_notice("unapproved")
  def expired = nromal_notice("expired")
  def expire_soon = nromal_notice("expire_soon")
  def unowned = nromal_notice("unowned")
  def deleted_owner = nromal_notice("deleted_owner")

  private def nromal_notice(name)
    @notice = name
    @user = params[:user]
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: @user.email
  end

  private def update_notice
    # do nothing if notice is destroyed, because destroyed nodes has already been deleted.
    return if @notice == "destroyed"

    # rubocop:disable Rails/SkipsModelValidations
    Node.where(id: @ids).update_all(notice: @notice, noticed_at: Time.current)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
