class AdminMailer < ApplicationMailer
  default to: Settings.admin.email

  def job_failure
    @job = params[:job]
    @job_id = params[:job_id]
    @time = params[:time]
    @exception = params[:exception]
    mail subject: subject_with_site_title
  end

  def deleted_users
    @nodes = Node.where(notice: "deleted_owner", noticed_at: nil).to_a
    mail subject: subject_with_site_title
  end

  def unowned
    @nodes = Node.where(notice: "unowned", noticed_at: nil).to_a
    mail subject: subject_with_site_title
  end

  # FIXE
  def touch_noticed_at
    # rubocop:disable Rails/SkipsModelValidations
    Node.where(id: @nodes.map(&:id)).touch_all(:noticed_at)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
