class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def stats_students
    @stats_students = User.distinct.count('uid')
  end
  
  def stats_snapshots
    @stats_snapshots = Snapshot.where(ready: 1).distinct.count('id')
  end
  
  def stats_views
    @stats_views = Snapshot.sum(:views)
  end
  
  helper_method :stats_students
  helper_method :stats_snapshots
  helper_method :stats_views
  
end