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

  def device_types
    authorize DeviceType, :manage?
  end

  def os_categories
    authorize OsCategory, :manage?
  end
end
