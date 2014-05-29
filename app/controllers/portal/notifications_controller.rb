class Portal::NotificationsController < Portal::BaseController
  respond_to :html, :json
  before_filter :find_notification, :only => [:show]

  def index
    @notification_index = true
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

    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    @notification = Notification.create(params[:notification])
    @message = @notification.messages.create(params[:message])
    
    if @message.valid? 
      @message.save

      @sub_service_request = @notification.sub_service_request

      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)

      UserMailer.notification_received(@message.recipient).deliver unless @message.recipient.email.blank?
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def user_portal_update
    @notification = Notification.find(params[:id])
    
    # TODO: @message is not set here; is that correct?
    @message = @notification.messages.create(params[:message])

    if @message.valid?
      @message.save
      # TODO: this is not set if no message is created; is that correct?
      @notifications = @user.all_notifications
      UserMailer.notification_received(@message.recipient).deliver unless @message.recipient.email.blank?
    end    
    respond_to do |format|
      format.js { render 'portal/notifications/create' }
    end
  end

  def admin_update
    @notification = Notification.find(params[:id])
    @message = @notification.messages.create(params[:message])

    if @message.valid?
      @message.save
      # @notification.reload
      @sub_service_request = @notification.sub_service_request
      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)
      UserMailer.notification_received(@message.recipient).deliver unless @message.recipient.email.blank?
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
