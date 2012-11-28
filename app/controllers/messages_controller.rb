# -*- encoding : utf-8 -*-
class MessagesController < ApplicationController  

  def inbox
    @messages = current_user.received_messages
    @messages = @messages.paginate(:page => params[:page], :per_page => 10)
  end

  def empty_trash
    current_user.deleted_messages.process do |message|
      message.delete
    end
    flash[:notice] = t(:trash_empty)
    redirect_to trash_messages_path
  end

  def show
    @message = ActsAsMessageable::Message.find_by_id(params[:id])
    @message.mark_as_read
    @message.from.popup_storz_display_name
  end

  def download_attachment
    file_info = Attachment.find params[:id]
    send_file( file_info.attachment.path ,:type => file_info.attachment_content_type)
  end

  def contact_me    
    user = User.find_by_id(params[:user_id])
    current_user.send_message(user, :topic => params[:topic], :body => params[:body].html_safe)
    respond_to do |format|
      format.js do
        unless params[:div_id].blank?
          render :js => "alert(#{t(:message_sent)});$('#contact_me_div_#{params[:div_id]}').toggle('slow');$('#body').val('');"
        else
          render :js => "alert(#{t(:message_sent)});$('#contact_me_div').toggle('slow');$('#body').val('');"
        end        
      end
    end    
  end  
  
  def gathering_message    
    user = User.find_by_id(params[:user_id])
    current_user.send_message(user, :topic => params[:topic], :body => params[:body].html_safe)
    respond_to do |format|
      format.js do
        render :js => "alert(#{t(:message_sent_to_owner)});$('#contact_me_div').toggle('slow');$('#body').val('');"
      end
    end    
  end
  
  def trash
    @messages = current_user.deleted_messages
    @messages = @messages.paginate(:page => params[:page], :per_page => 6, :order => "created_at DESC" )
  end

  def reply
    @message = ActsAsMessageable::Message.find_by_id(params[:id])    
  end

  def do_reply
    @message = ActsAsMessageable::Message.find_by_id(params[:message_id])
    @message.reply(:topic => params[:topic], :body => params[:body])
    flash[:notice] = t(:message_sent)
    redirect_to inbox_messages_path
  end

  def manage
    @messages = ActsAsMessageable::Message.all :conditions => ["id IN (?)", params[:message]]    
    case params[:action_to_perform]
    when "mark_as_read"
      @messages.each do |message|
        message.mark_as_read
      end
      flash[:notice] = t(:marked_read)
      redirect_to :action => "inbox"
    when "mark_as_unread"
      @messages.each do |message|
        message.mark_as_unread
      end
      flash[:notice] = t(:marked_unread)
      redirect_to :action => "inbox"
    when "move_to_trash"
      @messages.each do |message|
        current_user.delete_message(message)
      end
      flash[:notice] = t(:message_moved)
      redirect_to inbox_messages_path
    when "move_to_inbox"
      @messages.each do |message|
        message.update_attributes(:sender_delete => false, :recipient_delete => false)
      end
      flash[:notice] = t(:message_moved)
      redirect_to :action => "inbox"
    end
  end

  def move_single_conversation_to_trash
    convo = Conversation.find params[:id]
    current_user.mailbox.move_to(:trash, :conversation => convo)
    flash[:notice] = t(:moved_to_trash)
    redirect_to :action => "inbox"
  end

  def compose    
  end

  def send_message    
    recipients = params[:to].split(/;|,/)
    users = User.all :conditions => ["email in(?)", recipients]
    unless users.blank?
      users.each do |user|
        current_user.send_message(user, :topic => params[:topic], :body => params[:body].html_safe)
      end
      flash[:notice] = t(:message_sent)
      redirect_to inbox_messages_path
    else
      flash[:notice] = t(:provide_correct_email)
      render :action => "compose"
    end    
  end

  def sent_items
    @messages = current_user.sent_messages
    @messages = @messages.paginate(:page => params[:page], :per_page => 6, :order => "created_at DESC" )
  end

  def reply_to_conversation
    @attachments = []
    if current_user.tmps.size > 0
      current_user.tmps.each do |tmp|
        @attachments << File.open( "#{RAILS_ROOT}/#{tmp.path}" )
      end
    end
    recipients = params[:to].split(/;|,/)
    users = User.all :conditions => ["login in(?) OR email in(?)", recipients, recipients]
    body =    params[:message][:body].nil?    ? "" : params[:message][:body]
    subject = params[:message][:subject].nil? ? "" : params[:message][:subject]
    @mail = current_user.reply(Conversation.find(params[:id]), users , body, subject,@attachments)
    cleanup(@attachments)
    flash[:notice] = t(:reply_sent)
    redirect_to :controller => "message_system", :action => "inbox"
  end

  def reply_all_to_conversation
    @attachments = []
    current_user.tmps.each do |tmp|
      @attachments << File.open( "#{RAILS_ROOT}/#{tmp.path}" )
    end
    mail = Mail.find params[:id]
    body =    params[:message][:body].nil?    ? "" : params[:message][:body]
    subject = params[:message][:subject].nil? ? "" : params[:message][:subject]
    current_user.reply_to_all(mail, body, subject,@attachments)
    cleanup(@attachments)
    flash[:notice] = t(:reply_sent_to_all)
    redirect_to :controller => "message_system", :action => "inbox"
  end

  def reply_mail
    @action_url = "reply_to_conversation"
    @from = "Reply"
    @org_message = Message.find params[:message_id]
    @conversation_or_mail_id = params[:id]
    subject = @org_message.subject.sub(/^(Re: )?/, "Re: ")
    body = "#{@org_message.sender.login} wrote on #{@org_message.created_at.strftime('%A %B %d %I:%M:%S %p %Y')}: \n> " + @org_message.body
    @message = Message.new(:sender_id => params[:sender_id], :subject => subject, :body => body)
    @reply_setter = params[:reply_setter]
    render :template => "message_system/compose"
  end

  def reply_all_to_mail
    @action_url = "reply_all_to_conversation"
    @from = "Reply_all"
    @org_message = Message.find params[:message_id]
    @mail = Mail.find params[:id]
    @conversation_or_mail_id = params[:id]
    subject = @org_message.subject.sub(/^(Re: )?/, "Re: ")
    @recipients_for_reply_all = [ [@org_message.sender.login] + @org_message.recipients.map { |recipient| recipient.login } - [ current_user.login] ].join(";")
    body = "#{@org_message.sender.login} wrote on #{@org_message.created_at.strftime('%A %B %d %I:%M:%S %p %Y')}: \n> " + @org_message.body
    @message = Message.new(:subject => subject, :body => body)
    render :template => "message_system/compose"
  end
end