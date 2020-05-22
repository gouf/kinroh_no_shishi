require 'watir'
require 'webdrivers/chromedriver'
require_relative 'worktime_config'

class KinrohNoShishi
  class WorktimePage
    attr_reader :browser, :worktime_config

    def initialize(browser)
      @browser = browser
    end

    # 申請に必要な情報を自動入力する
    # YAML テンプレートを利用する
    def fill_form(worktime_template_name:, current_months_day:)
      # インデックス値指定は 0 始まり
      # ページ中で使われている日付と対応する
      @day_index = current_months_day - 1
      worktime_config = WorktimeConfig.load(worktime_template_name)

      goto_worktime_page   # 個人申請

      scroll_down_window

      application_checkbox.click # 申請

      set_actual_worktype_selection(worktime_config.fetch(:actual_work_type))       # 実績勤務区分
      set_standby_field(            worktime_config.fetch(:standby))                # 待機
      set_actual_worktime_start(    worktime_config.fetch(:actual_worktime_start))  # 確定出勤
      set_actual_worktime_end(      worktime_config.fetch(:actual_worktime_end))    # 確定退勤
      set_rest_time(                worktime_config.fetch(:rest_time))              # 休憩時間
      set_commutation_cost(         worktime_config.fetch(:commutation_cost))       # 変動交通費
      set_application_comment(      worktime_config.fetch(:application_comment))    # 申請コメント
    end

    # 申請ボタンを押して入力内容を保存
    def save
      application_confirm_button.click
      application_button.wait_until { |button| button.text.eql?('申請する') }
                        .wait_until(&:enabled?)
                        .click

      @browser.alert
              .ok

      _ = @browser.window.title # ページ遷移完了まで次の処理を待たせる
    end

    def close
      @browser.close
    end

    private

    # 月の後半... 15日以降の場合 Web ブラウザの画面をスクロールさせる
    # 操作対象の要素が見つからないのを防ぐ
    # ページの情報量的に、800px ほど下に移動すれば充分なはず
    # HINT: @browser.scroll.by(left, top)
    def scroll_down_window
      return unless @day_index >= 15

      @browser.scroll.by(0, 800)

      # スクロール後、後続の別メソッドが次の操作に即座に移ると その操作に失敗するのでここで一旦待たせる
      sleep 1
    end

    # 確定出勤
    def set_actual_worktime_start(worktime)
      @browser.execute_script(
        %Q(document.querySelector('input[name="dataList[#{@day_index}].column_1_47"]').value = '#{worktime}')
      )
    end

    # 確定退勤
    def set_actual_worktime_end(worktime)
      browser.execute_script(
        %Q(document.querySelector('input[name="dataList[#{@day_index}].column_1_48"]').value = '#{worktime}')
      )
    end

    # 休憩時間
    def set_rest_time(rest_time)
      browser.execute_script(
        %Q(document.querySelector('input[name="dataList[#{@day_index}].column_2_59"]').value = '00:45')
      )
    end

    # 変動交通費
    def set_commutation_cost(cost)
      @browser.execute_script(
        %Q(document.querySelector('input[name="dataList[#{@day_index}].column_2_72"]').value = '#{cost}')
      )
    end

    def application_checkbox
      @browser.checkbox(name: "shinseiFlag[#{@day_index}]")
    end

    # 申請ボタン
    def application_button
      @browser.button(name: 'shinsei')
    end

    # 申請確認ボタン
    def application_confirm_button
      @browser.button(name: 'shinseiKakunin')
    end

    # 待機
    def set_standby_field(num_flag)
      # ON : 1
      # OFF: 0
      @browser.text_field(name: "dataList[#{@day_index}].column_2_23").set(num_flag.to_s)
    end

    # 実績勤務区分
    def set_actual_worktype_selection(selection_index)
      @browser.execute_script(
        %Q(document.querySelector('a#id_syuttai_shortname_select_#{@day_index}').click())
      )
      # ｵﾌｨｽ（技術） を選択
      @browser.execute_script(
        # %Q(document.querySelector('a#id_kinmu_pull_a_#{@day_index}_2').click())
        %Q(document.querySelector('a#id_kinmu_pull_a_#{@day_index}_#{selection_index}').click())
        # 本来は「1」
        # 2020/03/31 分の選択肢からは 09001730 という項目が追加された模様
        # %Q(document.querySelector('a#id_kinmu_pull_a_#{day_index}_1').click())
      )
    end

    def set_application_comment(comment)
      @browser.text_field(id: "id_value_char_#{@day_index}").set(comment)
    end

    def goto_worktime_page
      @browser.goto('https://kinrou.sas-cloud.jp/kinrou/kojin/kintaiShinsei/')
    end
  end
end
