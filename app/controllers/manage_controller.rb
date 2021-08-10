class ManageController < ApplicationController
  def places
    authorize Place, :manage?
  end

  def hardwares
    authorize Hardware, :manage?
  end

  def operating_systems
    authorize OperatingSystem, :manage?
  end

  def security_softwares
    authorize SecuritySoftware, :manage?
  end
end
