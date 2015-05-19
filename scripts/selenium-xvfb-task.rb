require 'selenium-webdriver'

website = ARGV[0]
snapshot_id = ARGV[1]

if website.nil? || snapshot_id.nil?
  print 1
else
  
  test_url = "curl -I -N -Ss #{website} 2>&1"
  res = %x[ #{test_url} ]
  
  if $?.exitstatus == 0 # no errors
  
    driver = Selenium::WebDriver.for :firefox
    
    filename = "public/archive/snaps/snap_#{snapshot_id}.png"
    
    driver.manage.window.resize_to(1024, 768)
    driver.manage.window.maximize

    driver.get website
    
    driver.execute_script("viewable = 600; step = Math.ceil(document.body.scrollHeight / viewable); for (i = 1; i <= step; i++) { window.scrollTo(0, viewable * i); } window.scrollTo(0, 0); ")
        
    driver.save_screenshot filename
    driver.quit
    
    print 0 # no errors
    
  else
    
    #p [res.index(":")+2..-3]
    print res # eg. (6) Could not resolve host: localhost
    #$?.exitstatus # errors (>0)
    
  end
  
end