# 環境構築
## 開発環境構築
1. ```docker-compose up```
1. ```docker exec -it imagesearch_image_search_1 /bin/bash```でdocker内に入り、 ``` rake elastic_seed:run```
1. GCPのStorageやCloudVisionを使っているので、googleapikey.jsonをダウンロードして、vendor/gcs/googleapikey.jsonに保存
1. config/settings.ymlにgcp_project_idを設定
1. アニメデータを用意して./tmp/movies/{title}/{season}/{ep}/main.mkvに保存する
1. rakeのocrtest:upload_screenshotを実行しmkvからスクリーンショットを作成し、GCSに保存する
1. ocrtest:create_gifでGif画像を作成してGCSに保存する
1. ocrtest:register_imageinfoでGCSの画像データを元にDBを作成する
1. Docker内で```rails s```と```./bin/webpack-dev-server```

## CircleCI
1. Projectの用意
1. CircleCIのプロジェクトの設定のEnvironment VariablesにGCLOUD_SERVICE_KEYを作成し、そこにvendor/gcs/googleapikey.jsonをハッシュ化したものを入れる


## 本番環境構築
1. 自分のローカルの環境変数にAWS_ACCESS_KEY_IDとAWS_SECRET_ACCESS_KEYをセットする
1. vendor/aws/cfn/にCFNがあるので数字順にaws上で実行する。
1. ecsの引数はverndor/aws/secrets_manager/docker-hub.json.tmpを元に作成したSecretsManagerのarnを指定する。
1. healthcheckの引数はヘルスチェックが失敗した時にアラームメールを受け取るアドレス。その後Confirmationメールを受け取るのでconfirmする。
1. CloudFlareのCNAMEレコードをAWSのロードバランサーのDNS名と紐付ける。

# Notes
- CireciCI上のDockerのセカンダリでkuromojiを入れる方法がわからなかったので、vendor/dockerhubにあるカスタムイメージをDockerHubに手動で上げてそれを使用している