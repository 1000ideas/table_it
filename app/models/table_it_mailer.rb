class TableItMailer < ActionMailer::Base

  def poke_mail(issue)
    if issue.assigned_to
      recipients = issue.assigned_to.mail
      
      @user = issue.assigned_to
      @issue = issue
      
      mail(:to => issue.assigned_to.mail, 
      :from => "#{issue.author.firstname}<#{issue.author.mail}>",
      :subject => "[redmine - #{issue.tracker.name} ##{issue.id}] *poke, poke* Hurry up!") do |format|
            format.html { render 'table_it_mailer/poke_mail' }
          end   
      
    end    
end



end
