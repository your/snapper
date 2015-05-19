class SnapshotsController < ApplicationController
  
  
  def get_url
    session_url = session[:_url]
    if session_url.nil?
      params = snapshot_params
    else
      params = { :url => session_url }
    end
  end
  
  def estimated_wait
    base_wait = 10
    #flash[:estimated_wait] = Snapshot.where.not('duration' => nil).order("id desc").limit(10).average(:duration).to_i + 10
    Snapshot.where.not('duration' => nil).order("id desc").limit(10).average(:duration).to_i + base_wait
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
  
  def status
     @snapshot = Snapshot.find_by_generated_hash(params[:snapshot_id])
     render json: { id: @snapshot.generated_hash, ready: @snapshot.ready, msg: @snapshot.error, wait: estimated_wait }
  end
  

    
  def create
    estimated_wait
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
          
          #if @snapshot.test_url # check if URL is correct / is accessible
          @snapshot.snap # <-- asynchronous call handled by delayed_job
          #end
                      
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
    @snap_from = nil
    @snap_on = nil
    if @snapshot && @snapshot.ready == 1
      @snap_url = "/archive/snaps/snap_#{@snapshot.generated_hash}"
      @snapshot.views += 1
      @snapshot.save
      @snap_from = @snapshot.url
      @snap_on = @snapshot.created_at.in_time_zone('Eastern Time (US & Canada)').strftime("%-d/%-m/%y, %H:%M %Z")
    else
      render :error
      #redirect_to '/snapshots/error'
      #redirect_to snap_url
    end
  end
  
  def error
  end
  
  def snapshot_params
    params.require(:snapshot).permit(:url)
  end
  
end
