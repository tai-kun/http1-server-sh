# http1-server-sh

- **テストしていない**
- HTTP/1.0, HTTP/1.1
- `GET` のみ
- クエリに対応
- ヘッダーは見ない (つまり `Accept` も見ない)

## bin/

Docker 内では `/etc/serversh/bin/` に配置される。

### bin/env.sh
- 環境変数が定義されている。
- 設定されていなければ、デフォルト値がセットされる。
  |変数名|役割|制約|必須|デフォルト|
  |---|---|---|---|---|
  |SERVERSH_LOG_LEVEL  |このレベル以上のログが保存される|レベルが低い順に、`debug`,　`info`,　`warn`,　`error`|No|`info`|
  |SERVERSH_LOG_FILE   |ログの保存先|文字列|No|`/var/log/serversh.log`|
  |SERVERSH_INIT_SCRIPT|サーバが起動する直前に実行されるスクリプト|文字列|No|`/etc/serversh/src/init.sh`|
  |SERVERSH_MAIN_SCRIPT|リクエストを処理するスクリプト|文字列|No|`/etc/serversh/src/main.sh`|
  |SERVERSH_PORT_NUMBER|サーバが待ち受けるポートの番号|ポート番号|No|`2980`|

### bin/utils.sh
- 役立ちそうな関数が定義されている。
- `log`: ログファイル `SERVERSH_LOG_FILE` に記録する。
  |引数|役割|制約|必須|
  |---|---|---|---|
  |`$1`|ログレベル|`debug`,　`info`,　`warn`,　`error`|Yes|
  |`$2`|ログメッセージ|文字列|No|
  ```bash
  # SERVERSH_LOG_LEVEL=info
  log debug 'Hey'
  log info 'Hey'
  log warn 'Hey'
  log error 'Hey'
  ```
  ```log
  2023-05-03T02:22:51Z INFO  Hey
  2023-05-03T02:22:51Z WARN  Hey
  2023-05-03T02:22:51Z ERROR Hey
  ```
- `get_query_value_from_search`: 
  |引数|役割|制約|必須|
  |---|---|---|---|
  |`$1`|URL のクエリ|文字列|Yes|
  |`$2`|クエリ|文字列|Yes|
  |`$3`|デフォルト値||No|
  ```bash
  get_query_value_from_search 'param1=%E3%81%82&param2=2' 'param1'
  # あ
  get_query_value_from_search 'param1=%E3%81%82&param2=2' 'param3' 'null'
  # null
  ```
- `resp_200`: 200 OK でレスポンスを完了する。
  |引数|役割|制約|必須|
  |---|---|---|---|
  |`$1`|`Content-Type: text/plain` でボディに与えられるテキスト|文字列|No|
  ```bash
  resp_200 '<テキストデータ>'
  ```
- `resp_400`: 400 Bad Request でレスポンスを完了する。
  |引数|役割|制約|必須|
  |---|---|---|---|
  |`$1`|`Content-Type: text/plain` でボディに与えられるテキスト|文字列|No|
  ```bash
  resp_400 'クエリ param1 が無効な値です。'
  ```
- `resp_404`: 404 Not Found でレスポンスを完了する。
  |引数|役割|制約|必須|
  |---|---|---|---|
  |`$1`|`Content-Type: text/plain` でボディに与えられるテキスト|文字列|No|
  ```bash
  resp_404 'お探しのページは見つかりませんでした。'
  ```
- `resp_json`: 200 OK でレスポンスを完了する。
  |引数|役割|制約|必須|
  |---|---|---|---|
  |`$1`|`Content-Type: application/json` でボディに与えられるテキスト|文字列|Yes|
  ```bash
  resp_json '{"key":"value"}'
  ```

### bin/entrypoint.sh
- 最初に実行されるスクリプト。
- サーバは `socat` を使って実装されている。
- `SERVERSH_INIT_SCRIPT` にファイルが存在すれば `bash` で実行する。

### bin/main.sh
- リクエストの内容を解析して、URL のパスとクエリを取得する。
- スクリプトファイル `SERVERSH_MAIN_SCRIPT` を `bash` で実行する。
- スクリプトの `$1` には URL のパスが与えられる。
- スクリプトの `$2` には URL のクエリが与えられる。

## 例

ターミナル 1

```bash
bash ./examples/run.sh
```

ターミナル 2

```bash
curl localhost:2980
# Success
curl localhost:2980?param1=100
# Success
curl localhost:2980?param1=foo
# param1 must be a number
```

ログ (examples/log/serversh.log)

```log
2023-05-03T02:22:51Z DEBUG Exec: /etc/serversh/src/init.sh
2023-05-03T02:22:51Z INFO  This is init.sh
2023-05-03T02:22:51Z INFO  Listening on port 2980
2023-05-03T02:22:53Z DEBUG REQ_METHOD=GET
2023-05-03T02:22:53Z DEBUG URL_PATH=/
2023-05-03T02:22:53Z DEBUG HTTP_VER=HTTP/1.1
2023-05-03T02:22:53Z DEBUG URL_PATHNAME=/
2023-05-03T02:22:53Z DEBUG URL_SEARCH=
2023-05-03T02:22:53Z DEBUG Exec: /etc/serversh/src/main.sh
2023-05-03T02:22:53Z INFO  200 OK, /, param1=0
2023-05-03T02:22:53Z DEBUG HTTP/1.1 200 OK
2023-05-03T02:22:56Z DEBUG REQ_METHOD=GET
2023-05-03T02:22:56Z DEBUG URL_PATH=/?param1=100
2023-05-03T02:22:56Z DEBUG HTTP_VER=HTTP/1.1
2023-05-03T02:22:56Z DEBUG URL_PATHNAME=/
2023-05-03T02:22:56Z DEBUG URL_SEARCH=param1=100
2023-05-03T02:22:56Z DEBUG Exec: /etc/serversh/src/main.sh
2023-05-03T02:22:56Z INFO  200 OK, /, param1=100
2023-05-03T02:22:56Z DEBUG HTTP/1.1 200 OK
2023-05-03T02:22:57Z DEBUG REQ_METHOD=GET
2023-05-03T02:22:57Z DEBUG URL_PATH=/?param1=foo
2023-05-03T02:22:57Z DEBUG HTTP_VER=HTTP/1.1
2023-05-03T02:22:57Z DEBUG URL_PATHNAME=/
2023-05-03T02:22:57Z DEBUG URL_SEARCH=param1=foo
2023-05-03T02:22:57Z DEBUG Exec: /etc/serversh/src/main.sh
2023-05-03T02:22:57Z ERROR 400 Bad Request, /, param1=foo
2023-05-03T02:22:57Z DEBUG HTTP/1.1 400 Bad Request
```

## 例 Kubernetes

Pod の情報を取得する API サーバをデプロイしてみる。


ターミナル 1

```bash
bash ./examples/k8s.sh
# Creating cluster "example" ...
#  ✓ Ensuring node image (kindest/node:v1.25.3) 🖼
#  ✓ Preparing nodes 📦 📦  
#  ✓ Writing configuration 📜 
#  ✓ Starting control-plane 🕹️ 
#  ✓ Installing CNI 🔌 
#  ✓ Installing StorageClass 💾 
#  ✓ Joining worker nodes 🚜 
# Set kubectl context to "kind-example"
# You can now use your cluster with:

# kubectl cluster-info --context kind-example

# Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
# role.rbac.authorization.k8s.io/get-pod-info created
# rolebinding.rbac.authorization.k8s.io/get-pod-info created
# serviceaccount/get-pod-info created
# service/get-pod-info created
# pod/get-pod-info created
# pod/target-pod created
# configmap/get-pod-info created

# Try:
#   curl localhost:2980/ip?name=target-pod
#   curl localhost:2980/log

# Press Ctrl+C to stop

# Forwarding from 127.0.0.1:2980 -> 2980
# Handling connection for 2980
# Handling connection for 2980
# ^C
```

ターミナル 2

```bash
./examples/.cache/kubectl get pod -o wide
# NAME           READY   STATUS    RESTARTS   AGE   IP           NODE             NOMINATED NODE   READINESS GATES
# get-pod-info   1/1     Running   0          23s   10.244.1.2   example-worker   <none>           <none>
# target-pod     1/1     Running   0          23s   10.244.1.3   example-worker   <none>           <none>

curl localhost:2980/ip?name=target-pod
# 10.244.2.171

curl localhost:2980/log
# 2023-05-03T06:42:59Z INFO  Listening on port 2980
# 2023-05-03T06:43:29Z DEBUG REQ_METHOD=GET
# 2023-05-03T06:43:29Z DEBUG URL_PATH=/ip?name=target-pod
# 2023-05-03T06:43:29Z DEBUG HTTP_VER=HTTP/1.1
# 2023-05-03T06:43:29Z DEBUG URL_PATHNAME=/ip
# 2023-05-03T06:43:29Z DEBUG URL_SEARCH=name=target-pod
# 2023-05-03T06:43:29Z DEBUG Exec: /etc/serversh/src/main.sh
# 2023-05-03T06:43:29Z DEBUG HTTP/1.1 200 OK
# 2023-05-03T06:43:52Z DEBUG REQ_METHOD=GET
# 2023-05-03T06:43:52Z DEBUG URL_PATH=/log
# 2023-05-03T06:43:52Z DEBUG HTTP_VER=HTTP/1.1
# 2023-05-03T06:43:52Z DEBUG URL_PATHNAME=/log
# 2023-05-03T06:43:52Z DEBUG URL_SEARCH=
# 2023-05-03T06:43:52Z DEBUG Exec: /etc/serversh/src/main.sh
```
