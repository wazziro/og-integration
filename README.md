# nvim-og

`og`タスク管理ツールのNeovimプラグイン

## 概要

このプラグインは、`og`タスク管理ツールとNeovimを連携させるためのインターフェースを提供します。
タスクデータをJSONとして保存しつつ、Markdownでのインタラクティブなタスクリスト編集を可能にします。

## 機能

- `todo.md`ファイルを開くと、同じディレクトリの`todo.json`から内容を自動的に読み込みます
- `todo.md`ファイルを保存すると、変更内容をJSONに自動的に反映します
- Markdownとして表示・編集できるタスクリストをJSONデータとして確実に保存
- タスクデータの整形とフォーマット機能を提供

## インストール

### [packer.nvim](https://github.com/wbthomason/packer.nvim)を使用

```lua
use {
  'username/nvim-og',
  config = function()
    require('og').setup()
  end
}
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)を使用

```lua
{
  'username/nvim-og',
  config = function()
    require('og').setup()
  end
}
```

## 設定

```lua
require('og').setup({
  -- ogコマンドのパス
  og_cmd = 'og',
  
  -- 自動コマンドを有効にするかどうか
  enable_autocmds = true,
  
  -- 通知レベル: 'off', 'error', 'warn', 'info', 'debug'
  notification_level = 'info',
  
  -- 保存時に自動的に整形するかどうか
  auto_format = true,
})
```

## コマンド

- `:OgFormat` - 現在のバッファ内のタスクリストを整形します
- `:OgToJson [output_file]` - 現在のバッファをJSONに変換します（オプションで出力ファイルを指定可能）
- `:OgFromJson [input_file]` - JSONファイルをMarkdownに変換して現在のバッファに読み込みます

## 使い方

1. `todo.md`ファイルを作成または開きます
2. タスクを追加・編集します（例: `- [p] (A) [[タスク名]] due:2025-05-19`）
3. ファイルを保存すると、変更内容が自動的に`todo.json`に反映されます

## 必要条件

- Neovim 0.5.0以上
- `og`コマンドラインツールがインストールされ、パスが通っていること

## ライセンス

MIT

## 開発者

- 氏名 or ユーザーネーム
