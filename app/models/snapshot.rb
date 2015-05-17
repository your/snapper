class Snapshot < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :url
  
  def snap
    script = "ruby scripts/selenium-xvfb-task.rb #{url} #{generated_hash}"
    p %x[ #{script} ]
    done = $?.exitstatus == 0 ? 1 : -1 # 1 = ok, -1 = errors
    if done == 1
      path = "public/archive/snaps/snap_#{generated_hash}"
      script = "img2pdf #{path}.png -o #{path}.pdf"
      p %x[ #{script} ]
      done = $?.exitstatus == 0 ? 1 : -1 # 1 = ok, -1 = errors
    end
    update_column :ready, done
    p done
  end
  
  # delayed_job's built-in success callback method
  #def success(job)
  #end
  
  handle_asynchronously :snap#, run_at => Proc.new { 5.minutes.from_now }
  
end
