# class TableItIssuesController < ApplicationController

#   before_filter :find_issue, :authorize
#   accept_api_auth :poke, :time

#   def poke
#     respond_to do |format|
#       format.js
#     end
#   end

#   def time
#     time = params[:time]

#     @success = true

#     if time === true
#       @success = @issue.start_time!
#     elsif time === false
#       @success = @issue.stop_time!
#     else
#       tentry = @issue.time_entries.create
#         hours: time,
#         activity_id: 8,
#         user: User.current,
#         spent_on: Date.todays

#       @success = tentry.errors.empty?
#     end

#     respond_to do |format|
#       format.json
#       format.js
#     end
    
#   end
# end