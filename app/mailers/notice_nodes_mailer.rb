class NoticeNodesMailer < ApplicationMailer
  after_deliver :update_notice_status

  def destroyed
    @notice = "destroyed"
    @user = params[:user]
    processor = ImportExport::Processors::NodesProcessor.new
    @nodes = params[:nodes_params].map { |node_param| processor.params_to_record(node_param) }
    mail subject: subject_with_site_title, to: @user.email
  end

  def disabled
    @notice = "disabled"
    @user = params[:user]
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: @user.email
  end

  def expired
    @notice = "expired"
    @user = params[:user]
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: @user.email
  end

  def destroy_soon
    @notice = "destroy_soon"
    @user = params[:user]
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: @user.email
  end

  def disbale_soon
    @notice = "disable_soon"
    @user = params[:user]
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: @user.email
  end

  def expire_soon
    @notice = "expire_soon"
    @user = params[:user]
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: @user.email
  end

  def unowned
    @notice = "unowned"
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: Settings.admin.email
  end

  def deleted_owner
    @notice = "deleted_owner"
    @ids = params[:ids]
    @nodes = Node.where(id: params[:ids]).to_a
    mail subject: subject_with_site_title, to: Settings.admin.email
  end

  def update_notice_status
    # do nothing if notice is destroyed, because destroyed nodes has already been deleted.
    return if @notice == "destroyed"

    # rubocop:disable Rails/SkipsModelValidations
    Node.where(id: @ids).update_all(notice: @notice, noticed_at: Time.current)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
