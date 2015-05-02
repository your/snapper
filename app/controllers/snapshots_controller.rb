class SnapshotsController < ApplicationController
  
  def get_url
    session_url = session[:_url]
    if session_url.nil?
      params = snapshot_params
    else
      params = { :url => session_url }
    end
  end
  
  def new
    @snapshot = Snapshot.new
    session_url = session[:_url]
    if !session_url.nil?
      create
    end
  end
  
  def check_cookies
    !cookies[:_uid].nil? && !cookies[:_uname].nil?
  end
  
  def create
    @snapshot = Snapshot.new(get_url)
    session[:_url] = nil # destroy immediately session url!
    
    if check_cookies
      
      @authorization = Authorization.find_by_provider_and_uid("coursera", cookies[:_uid])
      
      if @authorization
        @snapshot.user_id = @authorization.user_id
        @snapshot.ready = 0 # not done yet
        
        if @snapshot.save
          #
          @snapshot.snap # <-- asynchronous call handled by delayed_job
          p "COME E' ANDATA?"
          p @snapshot.ready
          @snapshot.generated_hash = generate_hash(@snapshot.id)
          @snapshot.save
          #
          flash[:snapshot_id] = @snapshot.id
          
          redirect_to new_snapshot_url
        else
          render :new
        end
        
      else
        render :text => "wrong/expired auth"
      end
      
    else
      #render :text => "no/expired cookie"
      session[:_url] = @snapshot.url
      redirect_to :controller => 'sessions', :action => 'new'
    end
    
  end
  
  def generate_hash(url)
    url.to_s(36)
  end
  
  def show
    @snapshot = Snapshot.find(params[:id])
    redirect_to @snapshot.url
  end
  
  def snapshot_params
    params.require(:snapshot).permit(:url)
  end
  
end
