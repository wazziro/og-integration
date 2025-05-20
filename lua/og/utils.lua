-- nvim-og: ユーティリティモジュール
local M = {}
local config = require('og.config')

-- エラーレベルに応じた通知
function M.notify(msg, level)
  level = level or 'info'
  
  -- 設定に基づいて通知するかどうかを決定
  if not config.should_notify(level) then
    return
  end
  
  -- neovim 0.6+でvim.notifyが利用可能かどうかをチェック
  if vim.notify and type(vim.notify) == 'function' then
    local notify_level = vim.log.levels[string.upper(level)] or vim.log.levels.INFO
    vim.notify(msg, notify_level, { title = 'og' })
  else
    -- 古いバージョンでの代替
    local prefix = level == 'error' and 'Error: ' or 
                  level == 'warn' and 'Warning: ' or ''
    vim.cmd('echomsg "' .. prefix .. msg:gsub('"', '\\"') .. '"')
  end
end

-- コマンドを実行して結果を取得
function M.execute_command(cmd, input)
  -- 一時ファイルを作成（必要な場合）
  local temp_file = nil
  if input then
    temp_file = vim.fn.tempname()
    local file = io.open(temp_file, 'w')
    if file then
      file:write(input)
      file:close()
      cmd = 'cat ' .. vim.fn.shellescape(temp_file) .. ' | ' .. cmd
    else
      M.notify('一時ファイルの作成に失敗しました', 'error')
      return nil, -1
    end
  end
  
  -- コマンドを実行
  local output = ''
  local ret = -1
  
  -- vim.fn.systemを使用してコマンドを実行
  output = vim.fn.system(cmd)
  ret = vim.v.shell_error
  
  -- 一時ファイルを削除
  if temp_file and vim.fn.filereadable(temp_file) == 1 then
    vim.fn.delete(temp_file)
  end
  
  return output, ret
end

-- パスの正規化
function M.normalize_path(path)
  if vim.fn.has('win32') == 1 then
    path = path:gsub('/', '\\')
  else
    path = path:gsub('\\', '/')
  end
  return path
end

-- 現在のファイルに対応するJSONファイルパスを取得
function M.get_json_file_for_current_buffer()
  local current_file = vim.fn.expand('%:p')
  local file_base = vim.fn.fnamemodify(current_file, ':r')
  local json_file = file_base .. '.json'
  
  return json_file
end

return M
