# sinatra-memo-app

FBCのプラクティス「Sinatraを使ってWebアプリケーションの基本を理解する」の課題

## インストール

    $ bundle install

## データベースとテーブル作成

PostgreSQLでユーザー`postgres`を追加した上で以下を実行。

    $ ./dbinit.sh

## 起動

    $ bundle exec ruby app.rb

上記を実行後 http://localhost:4567/memos にアクセスする。
