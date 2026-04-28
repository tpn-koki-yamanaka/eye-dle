# Vite + Hono Workshop

このリポジトリは、`frontend` (Vite) と `backend` (Hono) のサンプル構成です。  
`scripts/sample.py` で `uvx` を使った Python 実行サンプルも含みます。

## 前提ツール

このワークスペースでは以下のバージョンを想定しています。

- Node.js: `24.14.0`
- Python: `3.13.12`
- uv / uvx: `0.10.6`

`mise.toml` で管理しているため、`mise` を使う場合はプロジェクト直下で自動的に反映されます。

## セットアップ

リポジトリ直下で依存関係をインストールします。

```bash
npm install
npm --prefix frontend install
npm --prefix backend install
```

## 開発サーバー起動

ターミナルを 2 つ開いて起動します。

- Backend 起動 (`http://localhost:8787`)

```bash
npm run dev:backend
```

- Frontend 起動 (`http://localhost:5173`)

```bash
npm run dev:frontend
```

## 動作確認

### 1) API の直接確認

```bash
curl http://localhost:8787/api/hello
```

期待値:

```json
{"message":"Hello from Hono backend!"}
```

### 2) Frontend から API 呼び出し確認

ブラウザで `http://localhost:5173` を開き、`Call API` ボタンを押します。  
Vite Proxy 経由で `/api/hello` が呼ばれ、レスポンスが画面に表示されれば成功です。

## Python スクリプト (`uvx`) 実行

サンプルスクリプト: `scripts/sample.py`

```bash
uvx python scripts/sample.py
```

この環境ではデフォルトで Python `3.13.12` が使われます。  
バージョンを明示したい場合:

```bash
uvx --python 3.13 python scripts/sample.py
```

初回のみ、指定バージョンが未取得なら `uvx` が Python をダウンロードする場合があります。
