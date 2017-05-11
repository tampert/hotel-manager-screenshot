#!/usr/bin/env ruby
require 'net/ftp'
require 'selenium-webdriver'
require 'fileutils'
require 'mini_magick'

# Other drivers are available as well http://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/WebDriver.html#for-class_method
driver = Selenium::WebDriver.for :chrome
driver.manage.window.resize_to(1280, 1050)
driver.manage.window.maximize
languages = ["nl","at", "be", "ch", "de", "es", "fr", "gr", "ie", "it", "pt"] #, "co.uk", "com"

languages.each {  |language| 
  puts " -------- start "+ language +" -------- "
  #make directory/ folder
  Dir.mkdir 'shots/'+ language unless File.exists?('shots/'+ language)
  screenshot_path = 'shots/'+ language+'/'
  #language_no_dots = language.sub '.', '_'
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  driver.navigate.to 'https://www.trivago.'+language+'/hotelmanager/login.html'

  username = wait.until {
        element = driver.find_element(:name, "LoginForm[sUsername]")
        element if element.displayed?
  }
  password = driver.find_element(:name, "LoginForm[sPassword]")
  username.send_keys(ARGV[0])
  password.send_keys(ARGV[1])

  # Click the button based the form it is in (you can also call 'submit' method)
  form = wait.until {
      element = driver.find_element(:id, "signinForm loginForm")
      element if element.displayed?
  }
  password.send_keys :enter
  # puts driver.page_source
  input = wait.until {
      element = driver.find_element(:id, "hotelselection-wideMenu")
      element if element.displayed?
  }
  puts " - we are logged into hotel manager for " + language if input.displayed?

  # driver.navigate.to 'https://www.trivago.'+language+'/hotelmanager/rates/3854016/rate_shopper.html'
  # driver.execute_script("document.body.style['zoom'] = 0.9; $('.leftNavigation-wrapper').remove(); $('.logo-navi-wrapper').remove(); $('.mainNavigation').remove(); $('footer').remove(); $('.alert--info').remove(); $('.header-unified').css({'padding-top':0})");
  # sleep(1)
  # driver.manage.window.resize_to(1600, 1343)
  # content = wait.until {
  #     element = driver.find_element(:id, "hgw_main_content")
  #     element if element.displayed?
  # }
  # puts "we are in rate shoper" if content.displayed?
  # sleep(1)
  # driver.save_screenshot(screenshot_path+'rate_benchmarking.png')
  # image = MiniMagick::Image.open( screenshot_path+'rate_benchmarking.png')
  # image.crop "1160x1340+0+0"
  # image.write screenshot_path +'rate_benchmarking.png'

  driver.navigate.to 'https://www.trivago.'+language+'/hotelmanager/hotel_news/3854016/hotel_news.html'
  driver.execute_script("$('.leftNavigation-wrapper').remove(); $('.logo-navi-wrapper').remove(); $('.mainNavigation').remove(); $('footer').remove(); $('#alertHotelNews').remove(); $('.header-unified').css({'padding-top':0}); $('#hgw_main_content').css({'padding-top':0});")
  content = wait.until {
     element = driver.find_element(:id, "hgw_main_content")
     element if element.displayed?
  }
  puts " - we are in hotel news" if content.displayed?
  driver.save_screenshot(screenshot_path+'hotel_news.png')
  image = MiniMagick::Image.open(screenshot_path+'hotel_news.png')
  image.crop "1160x880+36+0"
  image.write screenshot_path+'hotel_news.png'
  the_hotel_news_image = File.new(screenshot_path+'hotel_news.png')
  server_1 = '10.1.2.50'
  server_2 = '10.1.2.55'
  upload_user = ARGV[2]
  upload_password = ARGV[3]
  puts " - start upload 1"
  ftp = Net::FTP.new(server_1)
  ftp.passive = true
  ftp.login upload_user, upload_password
  files = ftp.chdir('/images/images/layoutimages/hotel_manager/pro/feature_preview/'+language+'/')
  #write the file
  ftp.putbinaryfile(the_hotel_news_image)
  files = ftp.list
  #puts "list out of directory:"
  puts " - updated hotel_news.png on " + server_1
  #puts files
  ftp.close
  puts " - start upload 2"
  ftp = Net::FTP.new(server_2)
  ftp.passive = true
  ftp.login upload_user, upload_password
  files = ftp.chdir('/images/images/layoutimages/hotel_manager/pro/feature_preview/'+language+'/')
  #write the file
  ftp.putbinaryfile(the_hotel_news_image)
  files = ftp.list
  #puts "list out of directory:"
  puts " - updated hotel_news.png on " + server_2
  #puts files
  ftp.close

# driver.navigate.to 'https://www.trivago.'+language+'/hotelmanager/customer_profile/3854016/customer_profile.html'
#   driver.execute_script("document.body.style['zoom'] = 0.69; $('.leftNavigation-wrapper').remove(); $('.logo-navi-wrapper').remove(); $('.mainNavigation').remove(); $('footer').remove(); $('.alert--info').remove(); $('.header-unified').css({'padding-top':0}); $('#hgw_main_content').css({'padding-top':0});")
#   content = wait.until {
#       element = driver.find_element(:id, "hgw_main_content")
#       element if element.displayed?
#   }
#   puts "we are in customer_profile" if content.displayed?
#   driver.manage.window.resize_to(1280, 1050)
#
#   driver.save_screenshot(screenshot_path+'visitors_profiles.png')
#
#   image = MiniMagick::Image.open(screenshot_path+'visitors_profiles.png')
#   image.crop "869x936+25+0"
#   image.write screenshot_path+'visitors_profiles.png'
  puts " -------- end  "+ language +"  -------- "
  puts 
}
driver.quit