class Snapshot < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :url
    
  def snap
    start_date = Time.now
    xvfb = "xvfb-run --server-args=\"-screen 0, 1024x768x24\" "
    if Rails.env.production?
      script = "#{xvfb} ruby scripts/selenium-xvfb-task.rb #{url} #{generated_hash}"
    else
      script = "ruby scripts/selenium-xvfb-task.rb #{url} #{generated_hash}"
    end
    exit = %x[ #{script} ]
    #done = $?.exitstatus == 0 ? 1 : -1 # 1 = ok, -1 = errors
    case exit
    when "0"
      done = 1
    else
      update_column :error, exit[exit.index(":")+2..-2]
      done = -1
    end
    
    Rails.logger.info "exit #{$?.exitstatus.class}"
    Rails.logger.info "done #{done}"
      
    if done == 1
      path = "public/archive/snaps/snap_#{generated_hash}"
      #script = "pngquant --quality=45-55 #{path}.png ; mv #{path}-fs8.png #{path}.png"
      script = "pngnq -n 256 #{path}.png ; mv #{path}-nq8.png #{path}.png"
      p %x[ #{script} ]
       
      done = $?.exitstatus == 0 ? 1 : -1 # 1 = ok, -1 = errors
      
      if done == 1
        path = "public/archive/snaps/snap_#{generated_hash}"
        script = "img2pdf #{path}.png -o #{path}.pdf"
        p %x[ #{script} ]
        
        done = $?.exitstatus == 0 ? 1 : -1 # 1 = ok, -1 = errors
       
      end
    end
    end_date = Time.now - start_date
    update_column :ready, done
    update_column :duration, end_date
  end
  
  #def test_url
  #  begin
  #    Faraday.head(url)
  #  rescue Exception => e
  #    update_colum :error, e.message
  #    update_column :ready, -1 # error
  #    false
  #  else
  #    true
  #  end
  #end
  
  # delayed_job's built-in success callback method
  def success(job) # è andato in porto sicuro
    p "successo"
  end
  
  def after(job) # puo essere fallito
    p "dopo"
  end
  
  def max_attempts
    1
  end
  
  def max_run_time
    10.minutes
  end
  
  
  handle_asynchronously :snap#, run_at => Proc.new { 5.minutes.from_now }
  
  before_validation :smart_add_url_protocol

  protected

  def smart_add_url_protocol
      unless self.url == '' || self.url[/\Ahttp:\/\//] || self.url[/\Ahttps:\/\//]
        self.url = "http://#{self.url.gsub(/\s+/, '')}"
      end
  end
  
end
