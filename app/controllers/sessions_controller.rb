class SessionsController < ApplicationController
  before_action :check_cookie, only: [:create]
  @cookie = nil
  
  def create
    if @cookie.nil?
      auth_hash = request.env['omniauth.auth']
     
      @authorization = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      if @authorization
        render :text => "Welcome back #{@authorization.user.name}! You have already signed up. Are you enrolled? #{validate_enrollment(auth_hash["info"]["enrollments"])}"
      else
        user = User.new :uid => auth_hash["uid"],
                        :name => auth_hash["info"]["name"],
                        :locale => auth_hash["info"]["locale"],
                        :timezone => auth_hash["info"]["timezone"]                      
                      
        user.authorizations.build :provider => auth_hash["provider"], :uid => auth_hash["uid"]
        user.save
      
        cookies[:_auth_uid] = { :value => auth_hash["uid"], :expires => Time.now + 1.hour }
 
        render :text => "Hi #{user.name}! You've signed up. Are you enrolled? #{validate_enrollment(auth_hash["info"]["enrollments"])}"
      else
        @authorization = Authorization.find_by_provider_and_uid("coursera", @cookie)
        if @authorization
          render :text => "1 Welcome back #{@authorization.user.name}! You have already signed up. Are you enrolled? #{validate_enrollment(auth_hash["info"]["enrollments"])}"
        else
          rander :text => "cazzo"
        end
      end
    end
  end
  
  def check_cookie
    @cookie = cookies[:_auth_uid]
    p @cookie
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
