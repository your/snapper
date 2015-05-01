class SessionsController < ApplicationController

  def create

    auth_uid = cookies[:_auth_uid] # possibly nil
 
    @authorization = Authorization.find_by_provider_and_uid("coursera", auth_uid)
    if @authorization
      render :text => "Welcome back #{@authorization.user.name}! You have already signed up."
    else
      auth_hash = request.env['omniauth.auth']
      user = User.new :uid => auth_hash["uid"],
                      :name => auth_hash["info"]["name"],
                      :locale => auth_hash["info"]["locale"],
                      :timezone => auth_hash["info"]["timezone"]                      
                      
      user.authorizations.build :provider => auth_hash["provider"], :uid => auth_hash["uid"]
      user.save
      
      cookies[:_auth_uid] = { :value => auth_hash["uid"], :expires => Time.now + 1.hour }
 
      render :text => "Hi #{user.name}! You've signed up. Are you enrolled? #{validate_enrollment(auth_hash["info"]["enrollments"])}"
    end
  end
  
  
  def validate_enrollment(enrollments)
    validated = false
    enrollments.each do |e|
      course_id = e["courseId"]
      if course_id == Pdfsnapshot::COURSE_ID && e["startStatus"].to_s == "Present"
        validated = true
        break
      end
    end
    validated
  end
end
