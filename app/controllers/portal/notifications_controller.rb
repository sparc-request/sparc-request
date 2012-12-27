class Portal::NotificationsController < Portal::BaseController
  respond_to :html, :json
  before_filter :find_notification, :only => [:show]

  def index
    @notifications = @user.all_notifications
    respond_with @user, @notifications
  end

  def show
    sub_service_request_id = params[:sub_service_request_id]
    @sub_service_request = SubServiceRequest.find(sub_service_request_id) if sub_service_request_id

    # Marking as read is being done in ajax when viewing notifications.
    # This, however, is the code for doing it in the controller.
    # @notification.user_notifications.where(:identity_id => @user.id).each do |user_notification|
    #   user_notification.update_attributes({:read => true})
    # end

    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    @recipient = Identity.find(params[:identity_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])

    # TODO: should #new create a new notification?
    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    @notification = Notification.create(params[:notification])
    if @message = @notification.messages.create(params[:message])
      @sub_service_request = @notification.sub_service_request

      # TODO: we created a new Notification, but all_notifications()
      # searches for UserNotifications.  do we need to also create a
      # UserNotification?
      # (also, perhaps the name all_notifications is confusing?)
      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)

      UserMailer.notification_received(@user).deliver
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def user_portal_update
    @notification = Notification.find(params[:id])
    
    if @notification.messages.create(params[:message])
      @notifications = @user.all_notifications
      UserMailer.notification_received(@user).deliver
    end    
    respond_to do |format|
      format.js { render 'portal/notifications/create' }
    end
  end

  def admin_update
    @notification = Notification.find(params[:id])

    if @notification.messages.create(params[:message])
      # @notification.reload
      @sub_service_request = @notification.sub_service_request
      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)
      UserMailer.notification_received(@user).deliver
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def mark_as_read
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id]) rescue nil
    if @sub_service_request
      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)
    else
      @notifications = @user.all_notifications
    end
    params[:notifications].each do |k,v|
      notification = Notification.find(k)
      notification.user_notifications_for_current_user(@user).each do |user_notification|
        user_notification.update_attributes(:read => v)
      end
    end  
    respond_to do |format|
      format.js { render 'portal/notifications/create' }
    end
  end

private
  def find_notification
    @notification = Notification.find(params[:id])
  end
end
