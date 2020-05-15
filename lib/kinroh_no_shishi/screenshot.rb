require 'watir'
require 'webdrivers/chromedriver'

class KinrohNoShishi
  class Screenshot
    attr_reader :browser
    attr_writer :day_index

    def initialize(browser)
      @browser = browser
    end

    def personal_application_list
      @browser.goto('https://kinrou.sas-cloud.jp/kinrou/kojin/kojinbetuSyoukai/')
      _ = @browser.window.title # ページ遷移完了まで次の処理を待たせる
      take_screenshot
    end

    def take_screenshot
      scroll_down_window
      @browser.screenshot.save('screenshot.png')
    end

    private

    # FIXME: コードの重複... lib/kinroh_no_shishi/worktime_page.rb
    # 月の後半... 15日以降の場合 Web ブラウザの画面をスクロールさせる
    # 操作対象の要素が見つからないのを防ぐ
    # ページの情報量的に、800px ほど下に移動すれば充分なはず
    # HINT: @browser.scroll.by(left, top)
    def scroll_down_window
      @browser.scroll.by(0, 800) if @day_index >= 15
    end
  end
end
