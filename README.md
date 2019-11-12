# 環境構築
## 開発環境構築
1. ```docker-compose up```
1. ```docker exec -it imagesearch_image_search_1 /bin/bash```でdocker内に入り、 ``` rake elastic_seed:run```
1. GCPのStorageやCloudVisionを使っているので、googleapikey.jsonをダウンロードして、vendor/gcs/googleapikey.jsonに保存
1. config/settings.ymlにgcp_project_idを設定
1. いい感じのアニメデータを用意してocrtest.rakeなどを実行しデータを作る
1. Docker内で```rails s```と```./bin/webpack-dev-server```
1. その他何か忘れている事

## CircleCI
1. Projectの用意
1. CircleCIのプロジェクトの設定のEnvironment VariablesにGCLOUD_SERVICE_KEYを作成し、そこにvendor/gcs/googleapikey.jsonをハッシュ化したものを入れる


## 本番環境
1. AWSでEC2とElasticIPを操作するのでそれらの権限をもつアカウントを作成する
1. 自分のローカルの環境変数にAWS_ACCESS_KEY_IDとAWS_SECRET_ACCESS_KEYをセットする
1. ElasticIPを確保しvendor/ansible/main.ymlを編集し適切なIPを設定
1. vendor/ansibleに移動し、```ansible-playbook main.yml```を実行
1. ansibleが失敗しても何度か実行すると通る事がある

# Notes

- 本番環境でデータを作成する仕組みを実装していなかったので、代わりにローカルで作ったDBを手動でAWSに上げて本番環境でダウンロードしている
- CireciCI上のDockerのセカンダリでkuromojiを入れる方法がわからなかったので、vendor/dockerhubにあるカスタムイメージをDockerHubに手動で上げてそれを使用している