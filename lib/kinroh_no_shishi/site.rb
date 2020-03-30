require 'watir'
require 'webdrivers/chromedriver'
require 'dotenv'

class KinrohNoShishi
  class Site
    def initialize(browser)
      @browser = browser
    end

    def login_page
      @login_page = LoginPage.new(@browser)
    end

    def worktime_page
      @worktime_page = WorktimePage.new(@browser)
    end

    def close
      @browser.close
    end
  end
end
