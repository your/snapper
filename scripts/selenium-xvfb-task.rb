require 'selenium-webdriver'

website = ARGV[0]
snapshot_id = ARGV[1]

if website.nil? || snapshot_id.nil?
  1
else
  
  driver = Selenium::WebDriver.for :firefox
    
  filename = "public/archive/snaps/snap_#{snapshot_id}.png"

  driver.get website
  driver.save_screenshot filename
  driver.quit
  
  0
end