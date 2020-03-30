require 'watir'
require 'webdrivers/chromedriver'

class KinrohNoShishi
  class LoginPage
    attr_reader :browser

    URL = 'https://kinrou.sas-cloud.jp/kinrou/kojin/'

    def initialize(browser)
      @browser = browser
    end

    def open
      @browser.goto URL
      self
    end

    def login_as(user_id:, password:, corporation_code:)
      corporation_code_field.set(corporation_code)
      user_id_field.set(user_id)
      password_field.set(password)

      login_button.click

      WorktimePage.new(@browser)
    end

    private

    def corporation_code_field
      @browser.text_field(name: 'houjinCode')
    end

    def user_id_field
      @browser.text_field(name: 'userId')
    end

    def password_field
      @browser.text_field(name: 'password')
    end

    def login_button
      @browser.button(name: 'bt')
    end
  end
end
