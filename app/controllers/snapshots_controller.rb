class SnapshotsController < ApplicationController
  def new
    @snapshot = Snapshot.new
  end
  
  def create
    @snapshot = Snapshot.new(snapshot_params)
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
