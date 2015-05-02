class SnapshotsController < ApplicationController
  def new
    @snapshot = Snapshot.new
  end
  
  def check_cookies
    !cookies[:_uid].nil? && !cookies[:_uname].nil?
  end
  
  def create
    @snapshot = Snapshot.new(snapshot_params)
    
    if check_cookies
      
      @authorization = Authorization.find_by_provider_and_uid("coursera", cookies[:_uid])
      
      if @authorization
        @snapshot.user_id = @authorization.user_id
        
        if @snapshot.save
          #
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
      render :text => "no/expired cookie"
      redirect_to :controller => 'sessions', :action => 'create', :provider => 'coursera'
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
