require 'watir'
require 'webdrivers/chromedriver'
require 'dotenv'

Dotenv.load

browser = Watir::Browser.new
browser.window.resize_to(2_500, 2_500) # width, height

# インデックス値指定は 0 始まり
# ページ中で使われている日付と対応する
day_index = 30 - 1 # 今月30日の欄に入力したいので -1 の指定をする

# 自宅勤務を想定した自動入力
# 9:00 - 17:45, 休憩 00:45
# 自動で申請はせず、一時保存機能での自動保存をする

# 一部入力欄が Watir での入力を受け付けないため、JS を記述して実行することで対応している

# JS の alert 対応のため、ヘッドレスモードでは動かない (※要検証)

# ---

#
# ログインページ へ移動
#

browser.goto('https://kinrou.sas-cloud.jp/kinrou/kojin/')

#
# ログイン情報を入力
#

# 法人コード
browser.text_field(name: 'houjinCode').set(ENV['KINROH_NO_SHISHI_HOJIN_CODE'])

# 社員コード
browser.text_field(name: 'userId').set(ENV['KINROH_NO_SHISHI_USER_ID'])

# パスワード
browser.text_field(name: 'password').set(ENV['KINROH_NO_SHISHI_PASSWORD'])

# ログイン ボタン クリック
browser.button(name: 'bt').click

# ---

#
# ログイン後
# 個人申請 ページ
#


# 個人申請 クリック
browser.div(id: 'kinou_200002').click

# browser.scroll.to(:bottom)

# ブラウザの表示を中央にスクロール
browser.scroll.to(:center)

# 「申請」フラグ ON
browser.checkbox(name: "shinseiFlag[#{day_index}]").click

# 実績勤務区分 選択
browser.execute_script(
  %Q(document.querySelector('a#id_syuttai_shortname_select_#{day_index}').click())
)
# ｵﾌｨｽ（技術） を選択
browser.execute_script(
  %Q(document.querySelector('a#id_kinmu_pull_a_#{day_index}_2').click())
  # 本来は「1」
  # 03/31 分の選択肢からは 09001730 という項目が追加された模様
  # %Q(document.querySelector('a#id_kinmu_pull_a_#{day_index}_1').click())
)

# 申請コメント
browser.text_field(id: "id_value_char_#{day_index}").set('自宅勤務')

# 待機
# ON : 1
# OFF: 0
browser.text_field(name: "dataList[#{day_index}].column_2_23").set('1')

# 確定出勤
browser.execute_script(
  %Q(document.querySelector('input[name="dataList[#{day_index}].column_1_47"]').value = '09:00')
)

# 確定退勤
browser.execute_script(
  %Q(document.querySelector('input[name="dataList[#{day_index}].column_1_48"]').value = '17:45')
)

# 休憩時間
browser.execute_script(
  %Q(document.querySelector('input[name="dataList[#{day_index}].column_2_59"]').value = '00:45')
)

# 変動交通費
browser.execute_script(
  %Q(document.querySelector('input[name="dataList[#{day_index}].column_2_72"]').value = '0')
)

# ---

#
# 一時保存 ボタンをクリック
#
browser.button(name: 'hozon').click
browser.alert.ok

# ---

browser.close
