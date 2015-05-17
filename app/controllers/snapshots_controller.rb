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
    @username = user_name
  end
  
  def user_name
    username = cookies[:_uname]
    if !username.nil?
      username.to_s.split(" ")[0]
    else
      "Guest"
    end
  end
  
  def check_cookies
    !cookies[:_uid].nil? && !cookies[:_uname].nil?
  end
  
  def status
     @snapshot = Snapshot.find_by_generated_hash(params[:snapshot_id])
     render json: { id: @snapshot.generated_hash, ready: @snapshot.ready }
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
          @snapshot.generated_hash = generate_hash(@snapshot.id)
          @snapshot.snap # <-- asynchronous call handled by delayed_job
          @snapshot.views = 0
          @snapshot.save
          #
          flash[:snapshot_id] = @snapshot.generated_hash
          
          redirect_to new_snapshot_url
        else
          render :new
        end
        
      else
        #render :text => "wrong/expired auth"
        redirect_to '/auth/coursera'
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
  
  def download
    @snapshot = Snapshot.find_by_generated_hash(params[:id])
    @filename = "#{Rails.root}/public/archive/snaps/snap_#{@snapshot.generated_hash}.pdf"
    send_file(@filename,
          :type => 'application/pdf/docx/html/htm/doc',
          :disposition => 'attachment') 
  end
  
  def show
    @username = user_name
    @snapshot = Snapshot.find_by_generated_hash(params[:id])
    @snap_url = "/archive/snaps/snap_#{@snapshot.generated_hash}"
    @snapshot.views += 1
    @snapshot.save
    #redirect_to snap_url
  end
  
  def snapshot_params
    params.require(:snapshot).permit(:url)
  end
  
end
