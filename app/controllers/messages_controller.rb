class MessagesController < ApplicationController  

  def inbox
    @messages = current_user.received_messages
  end

  def empty_trash
    current_user.mailbox.empty_trash
    redirect_to :action => "trash"
  end

  def download_attachment
    file_info = Attachment.find params[:id]
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    puts file_info.attachment.path.inspect
    send_file( file_info.attachment.path ,:type => file_info.attachment_content_type)
  end

  def search_email
    #    To/From" => "To/From", "Subject" => "Subject", "Body" => "Body", "Date" => "Date"
    case params[:search_from]
    when "To/From"
      users = User.all :conditions => ["email like ? OR login like ? OR name like ? ", "%#{params[:search_text]}%", "%#{params[:search_text]}%", "%#{params[:search_text]}%"]
      user_ids = users.map { |user| user.id }.join(",")
      @conditions = ["messages.sender_id in (?)", user_ids]
    when "Body"
      @conditions = ["messages.body like ?", "%#{params[:search_text]}%"]
    when "Subject"
      @conditions = ["messages.subject like ?", "%#{params[:search_text]}%"]
    when  "Date"
      @conditions = ["messages.created_at like ?", "%#{params[:search_text]}%"]
    else
      @conditions = ["messages.subject like ? OR messages.body like ? OR messages.created_at like ?", "%#{params[:search_text]}%", "%#{params[:search_text]}%", "%#{params[:search_text]}%"]
    end
    #    @all_mails = current_user.mailbox[:inbox].latest_mail(#"mail.body = ? OR mail.subject =?", params[:search_text], params[:search_text])
    puts "=aaaaaaaaaaaaaaaaaaaaaaaa====================================================================#{params[:search_text]}"
    @all_mails = current_user.mailbox[:all].mail :include => [:message,:user] , :conditions => @conditions
    puts "******************#{@all_mails.inspect}"

    #    .subject_or_body_like(params[:search_text])
    #    @all_mails = Mail.messages
    puts @all_mails.inspect
    #    _subject_or_body_like(params[:search_text])
    render :template => "message_system/inbox"
  end

  def append_div
    render :update do |page|
      page.replace_html params[:div_id], :partial=>"add_attachment"
    end
  end




  def trash
    session[:from] = "trash"
    @all_mails = current_user.mailbox[:trash].latest_mail
    render :template => "message_system/inbox"
  end

  def manage_mails
    @mails = Mail.all :conditions => ["id IN (?)", params[:mail]]
    puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    puts @mails.inspect
    puts params[:action_to_perform].inspect

    case params[:action_to_perform]
    when "mark_as_read"
      @mails.each do |mail|
        mail.mark_as_read
      end
      flash[:notice] = "Mail's has been marked as read"
      redirect_to :action => "inbox"

    when "mark_as_unread"
      @mails.each do |mail|
        mail.mark_as_unread
      end
      flash[:notice] = "Mail's has been marked as unread"
      redirect_to :action => "inbox"
    when "move_to_trash"

      @mails.each do |mail|
        convo = mail.conversation
        current_user.mailbox.move_to(:trash, :conversation => convo)
      end
      flash[:notice] = ""
      redirect_to :action => "inbox"
    when "move_to_inbox"

      @mails.each do |mail|
        convo = mail.conversation
        current_user.mailbox.move_to(:inbox, :conversation => convo)
      end
      flash[:notice] = "Mail(s) has been moved to inbox"
      redirect_to :action => "inbox"
    end
  end

  def move_single_conversation_to_trash
    convo = Conversation.find params[:id]
    current_user.mailbox.move_to(:trash, :conversation => convo)
    flash[:notice] = "Mail's has been moved to trash"
    redirect_to :action => "inbox"
  end

  def compose
    session[:from] = "compose"
    @message = Message.new
    @action_url = "send_message"
    @from = "Compose"
  end

  def send_message
    @attachments = []
    current_user.tmps.each do |tmp|
      @attachments << File.open( "#{RAILS_ROOT}/#{tmp.path}" )
    end
    recipients = params[:to].split(/;|,/)
    users = User.all :conditions => ["login in(?) OR email in(?)", recipients, recipients]
    current_user.send_message(users, params[:message][:body], params[:message][:subject], @attachments )
    cleanup(@attachments)
    flash[:notice] = t(:your_message_sent)
    redirect_to :action => "inbox"
  end
  def cleanup(attachments)
    attachments.each do |file|
      File.delete("#{RAILS_ROOT}/public/tmpdata/#{file.original_filename}") if File.exist?("#{RAILS_ROOT}/public/tmpdata/#{file.original_filename}")
    end
    current_user.tmps.delete_all
  end


  def remove_files
    @tmp = Tmp.find_by_unique_id(params[:id])
    File.delete("#{RAILS_ROOT}/#{@tmp.path}") if File.exist?("#{RAILS_ROOT}/#{@tmp.path}")
    @tmp.destroy
    render :nothing => true
  end

  def upload_attachment
    puts "*****************************************************************"
    puts params.inspect
    name =  params['Filedata'].original_filename
    directory = "public/tmpdata"
    path = File.join(directory, name)

    Tmp.create(:user_id => params[:id], :path => path, :unique_id => params[:unique_id])

    File.open(path, "wb") { |f| f.write(params['Filedata'].read) }
    render :nothing => true
  end

  def sent
    session[:from] = "sent"
    @all_mails = current_user.mailbox[:sentbox].mail
    render :action => "inbox", :reply_setter =>  "sent"
  end

  def message_details
    @mail = Mail.find params[:id]
  end

  def mail_details
    #    @conversation_details =  current_user.mailbox[:all].mail(:conversation => Conversation.find(params[:id]))
    @conversation_details =  current_user.read_conversation(Conversation.find(params[:id]))
    @latest_mail = current_user.mailbox[:inbox].latest_mail(:conversation => Conversation.find(params[:id])).first
    @reply_setter = params[:reply_setter]
    puts "--------------------------------------"
    puts @conversation_details.inspect
    puts @latest_mail.inspect
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
    flash[:notice] = "Reply has been sent"
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
    flash[:notice] = "Reply has been sent to all recipients you mentioned"
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
