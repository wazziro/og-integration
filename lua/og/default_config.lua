local M = {}

function M.default_config()
  return {
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
end

return M
