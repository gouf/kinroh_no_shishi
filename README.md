# これはなに

[勤労の獅子](https://sas-com.com/service/kinrou.html) という勤怠管理 Web システムがあり、そこへの入力作業を半自動化する

# 使い方

1. `lib/kinroh_no_shishi/config/*.yml` にテンプレートを保存する
2. 実行・呼び出し時に、ファイル名と同じシンボル名 (eg. `:work_at_home`) を指定する

## 想定・手順

次のような利用方法を想定

1. `.env` にログイン情報を保存
2. `lib/kinroh_no_shishi/config/` に、テンプレートとなる YAML ファイルを保存
3. `bundle e ruby main.rb` で自動入力・申請処理を走らせる

申請は自動承認されることを想定

システム利用者は記入者, 管理者の2種類がいると思われるが、記入者のみ対応

採用組織が異なれば もしかしたら、設定内容に差が生じて動かないかもしれない

# Link

* [Watir Project](http://watir.com/)
