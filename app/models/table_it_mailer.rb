class TableItMailer < ActionMailer::Base

def poke_mail(issue)
  if issue.assigned_to
    recipients = issue.assigned_to.mail
    
    @user = issue.assigned_to
    @issue = issue
    
    mail(:to => issue.assigned_to.mail, 
    :from => "#{issue.author.firstname}<#{issue.author.mail}>",
    :subject => "*poke, poke* Hurry up!") do |format|
          format.html { render 'table_it_mailer/poke_mail' }
        end   
    
  end    
end

def close_ticket_plugin_mail(issue)
  if issue.assigned_to
  recipients = issue.assigned_to.mail
  
  @user = issue.assigned_to
  @issue = issue
  
    mail(:to => issue.assigned_to.mail, 
    :from => "Redmine TableIt plugin",
    :subject => "issue ##{issue.id} is closed") do |format|
      format.html { render 'table_it_mailer/close_ticket_plugin_mail' }
    end  
  end    
end

end
