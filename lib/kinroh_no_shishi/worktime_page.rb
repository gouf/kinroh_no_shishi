require 'watir'
require 'webdrivers/chromedriver'

class KinrohNoShishi
  class WorktimePage
    attr_reader :browser

    def initialize(browser)
      @browser = browser
    end

    def fill_form(current_months_day)
      # インデックス値指定は 0 始まり
      # ページ中で使われている日付と対応する
      @day_index = current_months_day - 1

      worktime_page_link.click            # 個人申請

      # ブラウザの表示を中央にスクロール
      @browser.scroll.to(:center)

      application_checkbox.click          # 申請
      set_actual_worktype_selection('2')  # ｵﾌｨｽ（技術）
      set_standby_field('1')              # 待機
      set_actual_worktime_start('09:00')  # 確定出勤
      set_actual_worktime_end('17:45')    # 確定退勤
      set_rest_time('00:45')              # 休憩時間
      set_commutation_cost('0')           # 変動交通費
    end

    # 一時保存
    def save
      @browser.button(name: 'hozon').click
      @browser.alert.ok
    end

    def close
      @browser.close
    end

    private

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

    def worktime_page_link
      @browser.div(id: 'kinou_200002')
    end
  end
end
