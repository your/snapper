require 'selenium-webdriver'

website = ARGV[0]
snapshot_id = ARGV[1]

if website.nil? || snapshot_id.nil?
  print 1
else
  
  test_url = "curl -I -N -Ss #{website} 2>&1"
  res = %x[ #{test_url} ]
  
  if $?.exitstatus == 0 # no errors
  
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['download.prompt_for_download'] = false
    profile['download.default_directory'] = "/dev/null"
    profile['accept_untrusted_certs'] = true 
    
    driver = Selenium::WebDriver.for :firefox, :profile => profile
    
    driver.manage.timeouts.page_load = 30 # seconds 
    driver.manage.timeouts.script_timeout = 20
    driver.manage.timeouts.implicit_wait = 20
    
    filename = "public/archive/snaps/snap_#{snapshot_id}.png"
    
    driver.manage.window.resize_to(1024, 768)
    driver.manage.window.maximize

    driver.get website
    
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { 
      1.times {
        driver.execute_script("
        var viewable = 600;
        var step = Math.ceil(document.body.scrollHeight / viewable);
        var delay = 0;
        var delayMilliseconds = 50;

        for (var i=0; i<= step; i++) {
            (function(j){
                delay = j*delayMilliseconds;
                setTimeout(function(){
                   window.scroll(0, j*viewable);
                },delay);
            })( i );
        } return true;")
        driver.execute_script("window.scrollTo(0, 0); return true; ")
      }
    }
        
    driver.save_screenshot filename
    driver.quit
    
    print 0 # no errors
    
  else
    
    #p [res.index(":")+2..-3]
    print res # eg. (6) Could not resolve host: localhost
    #$?.exitstatus # errors (>0)
    
  end
  
end