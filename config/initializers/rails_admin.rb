require "nested_form/engine"
require "nested_form/builder_mixin"

RailsAdmin.config do |config|
  config.asset_source = :webpack
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Authorization ==
  config.authorize_with do
    redirect_to main_app.root_path unless current_user.admin?
  end

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  config.audit_with :paper_trail, "User", "PaperTrail::Version" # PaperTrail >= 3.0.0

  config.model "PaperTrail::Version" do
    visible false
  end

  config.model "PaperTrail::VersionAssociation" do
    visible false
  end

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  paper_trail_audit_model = %w[
    Ipv4Arp Ipv6Neighbor
    Ipv4Pool Ipv6Pool
    Node Confirmation
    Nic Network Assignment
    Place DeviceType Hardware OsCategory OperatingSystem SecuritySoftware
    User
  ]

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    history_index do
      only paper_trail_audit_model
    end
    history_show do
      only paper_trail_audit_model
    end
  end

  config.label_methods << :address
end
