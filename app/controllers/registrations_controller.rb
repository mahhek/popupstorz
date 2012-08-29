# -*- encoding : utf-8 -*-
class RegistrationsController < Devise::RegistrationsController
   
  protected

  def after_update_path_for(resource)
    profile_path(resource.id)
  end


end
