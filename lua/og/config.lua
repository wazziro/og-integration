-- nvim-og: 設定管理モジュール
local M = {}

-- デフォルト設定
local default_config = {
  -- ogコマンドのパス
  og_cmd = 'og',
  
  -- 自動コマンドを有効にするかどうか
  enable_autocmds = true,
  
  -- 通知レベル
  -- 'off': 通知を表示しない
  -- 'error': エラーのみ表示
  -- 'warn': 警告以上を表示
  -- 'info': 情報、警告、エラーを表示
  -- 'debug': すべてのメッセージを表示
  notification_level = 'info',
  
  -- 保存時に自動的に整形するかどうか
  auto_format = true,
}

-- 現在のプラグイン設定
M.config = vim.deepcopy(default_config)

-- 設定のセットアップ
function M.setup(opts)
  -- ユーザー設定とデフォルト設定をマージ
  opts = opts or {}
  M.config = vim.tbl_deep_extend('force', default_config, opts)
end

-- 設定値を取得
function M.get(key)
  return M.config[key]
end

-- ogコマンドのパスを取得
function M.get_og_cmd()
  return M.config.og_cmd
end

-- 通知レベルをチェック
function M.should_notify(level)
  local levels = {
    off = 0,
    error = 1,
    warn = 2,
    info = 3,
    debug = 4,
  }
  
  local config_level = levels[M.config.notification_level] or 3
  local msg_level = levels[level] or 3
  
  return msg_level <= config_level
end

return M
