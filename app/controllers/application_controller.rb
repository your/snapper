class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  http_basic_authenticate_with :name => "penn", :password => "design", :if => lambda { Rails.env.development? }

  def stats_students
    @stats_students = User.distinct.count('uid')
  end
  
  def stats_snapshots
    @stats_snapshots = Snapshot.where(ready: 1).distinct.count('id')
  end
  
  def stats_views
    @stats_views = Snapshot.sum(:views)
  end
  
  #def latest_duration
  #  @latest_duration = Snapshot.last.duration
  #end
  
  helper_method :stats_students
  helper_method :stats_snapshots
  helper_method :stats_views
  #helper_method :latest_duration
  
end