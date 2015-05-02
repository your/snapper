class Snapshot < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :url
  
  def snap
    %x(sleep 5)
    done = $?.exitstatus == 0 ? 1 : -1 # 1 = ok, -1 = errors
    update_column :ready, done
  end
  
  # delayed_job's built-in success callback method
  #def success(job)
  #end
  
  handle_asynchronously :snap#, run_at => Proc.new { 5.minutes.from_now }
  
end
