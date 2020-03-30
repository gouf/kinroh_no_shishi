require 'watir'
require 'dotenv'
require_relative 'lib/kinroh_no_shishi/site'
require_relative 'lib/kinroh_no_shishi/login_page'
require_relative 'lib/kinroh_no_shishi/worktime_page'

Dotenv.load

browser = Watir::Browser.new
# browser.window.resize_to(2_500, 2_500) # width, height

login_page =
  KinrohNoShishi::LoginPage.new(browser)

login_page.open

worktime_page =
  login_page.login_as(
    corporation_code: ENV['KINROH_NO_SHISHI_HOJIN_CODE'],
    user_id:          ENV['KINROH_NO_SHISHI_USER_ID'],
    password:         ENV['KINROH_NO_SHISHI_PASSWORD']
  )

current_months_day = 30 # 今月30日を自動入力の対象にする
worktime_page.fill_form(current_months_day)

worktime_page.save # 一時保存ボタンを押す

worktime_page.close
