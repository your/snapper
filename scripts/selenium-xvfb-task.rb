require 'selenium-webdriver'

website = ARGV[0]
snapshot_id = ARGV[1]

if website.nil? || snapshot_id.nil?
  print 1
else
  
  test_url = "curl -A \"Mozilla/5.0 (X11; Linux x86_64; rv:28.0) Gecko/20100101 Firefox/28.0\" -I -N -Ss #{website} 2>&1"
  res = %x[ #{test_url} ]
  
  if $?.exitstatus == 0 # no errors
  
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.native_events = false
    profile['download.prompt_for_download'] = false
    profile['download.default_directory'] = "/dev/null"
    profile['accept_untrusted_certs'] = true 
    
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 120 # seconds
    driver = Selenium::WebDriver.for :firefox, :http_client => client, :profile => profile
    
    #driver = Selenium::WebDriver.for :firefox#, :profile => profile
    
    driver.manage.timeouts.page_load = 120 # seconds 
    driver.manage.timeouts.script_timeout = 30
    driver.manage.timeouts.implicit_wait = 30
    
    filename = "public/archive/snaps/snap_#{snapshot_id}.png"
    
    driver.manage.window.resize_to(1024, 768)
    driver.manage.window.maximize

    driver.get website
    
    wait = Selenium::WebDriver::Wait.new(:timeout => 120)
    #wait.until { 
    #    driver.execute_script("for(var viewable=300,step=Math.ceil(document.body.scrollHeight/viewable),delay=0,delayMilliseconds=700,i=0;step>=i;i++)!function(e){delay=e*delayMilliseconds,setTimeout(function(){return window.scroll(0,e*viewable),console.log(i,step,e*viewable),e*viewable===3900?!0:void 0},delay)}(i);")
    #}
    #wait.until {
    #  driver.execute_script("window.scrollTo(0, 0);")
    #}
    wait.until { 
      5.times {
        driver.execute_script("function scroll() { viewable = 600; step =   Math.ceil(document.body.scrollHeight / viewable); for (i = 0; i <= step ; i++)  { window.scrollTo(0, viewable * i); } return true; } return scroll();")
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