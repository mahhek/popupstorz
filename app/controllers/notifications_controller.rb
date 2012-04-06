class NotificationsController < ApplicationController
def destroy
    
    @notification = Notification.find(params[:id])
    @notification.destroy
    respond_to do |format|
      format.js do
        @notifications = Notification.find_all_by_user_id(current_user.id)
        foo = render_to_string(:partial => '/accounts/notifications', :locals => { :notifications => @notifications }).to_json
        render :js => "$('#notifications_div').html(#{foo})"
      end
    end
    
  end
end
