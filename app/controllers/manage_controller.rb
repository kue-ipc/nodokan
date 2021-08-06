class ManageController < ApplicationController
  def places
    authorize Place, :manage?
  end

  def hardwares
  end

  def operating_systems
  end

  def security_softwares
  end
end
