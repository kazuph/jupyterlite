# JupyterLite 開発・更新ガイド

このリポジトリでJupyterLiteのコンテンツを開発・更新するための、最短かつ確実な手順を記載します。

---

## パート1: 初回環境構築（一度だけ実行）

リポジトリをクローンした後、最初に一度だけ実行する必要があるセットアップ手順です。

### 1. 設定ファイルの自動修正

プロジェクトに含まれる古い設定を自動で修正します。

```bash
# .yarnrc.yml の古い設定を削除
sed -i.bak '/enableStrictPeerDependencies/d' .yarnrc.yml

# package.json の古いインストールスクリプトを削除
sed -i.bak '/"install": "lerna bootstrap"/d' package.json

# package.json の "jlpm" を "yarn" に置換
sed -i.bak 's/jlpm/yarn/g' package.json
```

### 2. JavaScript依存関係のインストール

```bash
yarn install
```

### 3. ルート設定ファイルの作成

コンテンツの場所を正しく指定するため、プロジェクトのルートに新しい設定ファイルを作成します。

```bash
cat << EOF > jupyter_lite_config.json
{
  "LiteBuildConfig": {
    "lite_dir": "app",
    "contents": ["app/content", "examples"],
    "federated_extensions": [
      "https://github.com/jupyterlite/p5-kernel/releases/download/v0.1.0/jupyterlite_p5_kernel-0.1.0-py3-none-any.whl"
    ]
  }
}
EOF
```

### 4. Python環境のセットアップとカーネルのインストール

ビルドに必要なPythonパッケージ（Pyodideカーネル、ビルドツール等）を仮想環境にインストールします。

```bash
python3 -m venv .venv
.venv/bin/python3 -m pip install --upgrade pip
.venv/bin/python3 -m pip install -e py/jupyterlite-core jupyterlite-pyodide-kernel jupyter-server
```

### 5. 日本語フォントの配置（推奨）

グラフの文字化けを防ぐため、日本語フォントをサイトに同梱します。

```bash
mkdir -p examples/fonts
wget https://fonts.gstatic.com/s/notosansjp/v55/-F6jfjtqLzI2JPCgQBnw7HFyzSD-AsregP8VFBEj75s.ttf -O examples/fonts/NotoSansJP-Regular.ttf
```

---

## パート2: コンテンツ更新時の最短手順

ノートブックの追加や修正を行った後、その変更をブラウザに反映させるための手順です。

### 1. サイトの再構築

変更したファイルをサイトに反映させます。このコマンドが完了するまで待ちます。

```bash
.venv/bin/python3 -m jupyter lite build --config jupyter_lite_config.json --output-dir dist
```

### 2. Webサーバーの再起動

古いサーバーを停止し、新しい内容でサーバーを起動します。

```bash
# 現在のサーバーを停止 (PIDは適宜変更してください)
# ps aux | grep http.server で探すこともできます
kill $(lsof -t -i:8888)

# 新しいサーバーをバックグラウンドで起動
nohup python3 -m http.server --directory dist --bind 127.0.0.1 8888 > server.log 2>&1 &
```

### 3. ブラウザで確認

`http://localhost:8888/lab/` にアクセスし、**ハードリフレッシュ**（Mac: `Cmd+Shift+R`, Win: `Ctrl+Shift+R`）して変更が反映されていることを確認します。

```
