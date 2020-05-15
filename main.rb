require 'date'
require 'watir'
require 'dotenv'
require 'active_support/core_ext'
require_relative 'lib/kinroh_no_shishi/site'
require_relative 'lib/kinroh_no_shishi/login_page'
require_relative 'lib/kinroh_no_shishi/worktime_page'
require_relative 'lib/kinroh_no_shishi/screenshot'

module Task
  # 指定した日付に対して、テンプレートに設定した値を自動入力・申請 (確定処理) をする
  def self.run
    Dotenv.load

    Watir.default_timeout = 2.minutes # テザリングなどで遅い回線からアクセスした場合でも自動処理できるようにする
    browser = Watir::Browser.new

    # スクリーンショット作成用に充分なウィンドウサイズを設定
    browser.window.resize_to(2_300, 900) # width, height

    login_page =
      KinrohNoShishi::LoginPage.new(browser)

    login_page.open

    worktime_page =
      login_page.login_as(
        corporation_code: ENV['KINROH_NO_SHISHI_HOJIN_CODE'],
        user_id:          ENV['KINROH_NO_SHISHI_USER_ID'],
        password:         ENV['KINROH_NO_SHISHI_PASSWORD']
      )

    day_today = Date.today.day

    worktime_page.fill_form(
      current_months_day: day_today, # 今月n日を自動入力の対象にする
      worktime_template_name: :work_at_home
    )

    worktime_page.save # 申請ボタンを押す

    screenshot_page =
      KinrohNoShishi::Screenshot.new(worktime_page.browser)
    screenshot_page.day_index = day_today # FIXME: 値の直接書き換えではなくメソッドの引数として値を渡す
    screenshot_page.personal_application_list

    worktime_page.close

    # 撮影したスクリーンショットを Mac 環境の open コマンドで開く
    system('open ~/kinroh_no_shishi/screenshot.png')
    screenshot_page.close
  end
end

Task.run
