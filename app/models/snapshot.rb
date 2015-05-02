class Snapshot < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :url
  
  def snap
    %x('sleep 5')
    done = $?.exitstatus == 0 ? 1 : -1 # 1 = ok, -1 = errors
    update_column :ready, $?.exitstatus
  end
  
  handle_asynchronously :snap
  
end
