class SessionsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
 
    @authorization = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
    if @authorization
      render :text => "Welcome back #{@authorization.user.name}! You have already signed up."
    else
      user = User.new :uid => auth_hash["uid"],
                      :name => auth_hash["info"]["name"],
                      :locale => auth_hash["info"]["locale"],
                      :timezone => auth_hash["info"]["timezone"]                      
                      
      user.authorizations.build :provider => auth_hash["provider"], :uid => auth_hash["uid"]
      user.save
 
      render :text => "Hi #{user.name}! You've signed up."
    end
  end
end
