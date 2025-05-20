-- nvim-og: コマンド実装モジュール
local M = {}
local config = require('og.config')
local utils = require('og.utils')

-- コマンドの設定
function M.setup()
  -- :OgFormat コマンド - 現在のバッファを整形
  vim.api.nvim_create_user_command('OgFormat', function()
    M.format_buffer()
  end, {
    desc = 'Format the current buffer using og fmt command',
  })
  
  -- :OgToJson コマンド - 現在のバッファをJSONに変換
  vim.api.nvim_create_user_command('OgToJson', function(opts)
    local output_file = opts.args ~= "" and opts.args or nil
    M.convert_to_json(output_file)
  end, {
    nargs = '?',
    desc = 'Convert current buffer to JSON',
    complete = 'file',
  })
  
  -- :OgFromJson コマンド - JSONからMarkdownに変換
  vim.api.nvim_create_user_command('OgFromJson', function(opts)
    local input_file = opts.args ~= "" and opts.args or nil
    M.convert_from_json(input_file)
  end, {
    nargs = '?',
    desc = 'Convert JSON to Markdown and load into current buffer',
    complete = 'file',
  })
end

-- JSONからMarkdownにバッファを読み込む
function M.load_from_json(json_file)
  -- ファイルが存在するか確認
  if vim.fn.filereadable(json_file) ~= 1 then
    utils.notify("JSONファイル " .. json_file .. " が見つかりません。", "error")
    return false
  end
  
  -- ogコマンドを実行
  local cmd = config.get_og_cmd() .. ' --from json --to markdown ' .. vim.fn.shellescape(json_file)
  local output, ret = utils.execute_command(cmd)
  
  if ret ~= 0 then
    utils.notify("JSONからMarkdownへの変換に失敗しました: " .. output, "error")
    return false
  end
  
  -- バッファの内容を置き換え
  local lines = vim.split(output, '\n')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  utils.notify("JSONファイルから内容を読み込みました", "info")
  
  return true
end

-- Markdownの変更をJSONに適用する
function M.apply_to_json(json_file)
  -- バッファの内容を取得
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')
  
  -- JSONファイルが存在するか確認
  local json_exists = vim.fn.filereadable(json_file) == 1
  
  -- 適切なコマンドを選択
  local cmd
  if json_exists then
    -- 既存JSONに変更を適用
    cmd = config.get_og_cmd() .. ' apply --from markdown --target-json ' .. vim.fn.shellescape(json_file)
  else
    -- 新規作成
    cmd = config.get_og_cmd() .. ' --from markdown --to json -o ' .. vim.fn.shellescape(json_file)
    -- JSON書き込み後にMarkdownを整形するためのコマンドを追加
    local fmt_cmd = config.get_og_cmd() .. ' fmt --from markdown'
    
    -- コマンドを実行
    local output, ret = utils.execute_command(cmd, content)
    if ret ~= 0 then
      utils.notify("Markdownの変更をJSONに適用できませんでした: " .. output, "error")
      return false
    end
    
    -- 整形コマンドを実行
    local fmt_output, fmt_ret = utils.execute_command(fmt_cmd, content)
    if fmt_ret ~= 0 then
      utils.notify("Markdownの整形に失敗しました: " .. fmt_output, "error")
      return false
    end
    
    -- バッファの内容を整形済みの内容で置き換え
    local fmt_lines = vim.split(fmt_output, '\n')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, fmt_lines)
    
    utils.notify("新しいJSONファイルを作成しました", "info")
    return true
  end
  
  -- 既存JSONに変更を適用する場合
  local output, ret = utils.execute_command(cmd, content)
  if ret ~= 0 then
    utils.notify("Markdownの変更をJSONに適用できませんでした: " .. output, "error")
    return false
  end
  
  -- 成功した場合、整形済みのMarkdownを現在のバッファに反映
  local fmt_lines = vim.split(output, '\n')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, fmt_lines)
  
  utils.notify("JSONファイルを更新しました", "info")
  return true
end

-- 現在のバッファを整形する
function M.format_buffer()
  -- バッファの内容を取得
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')
  
  -- ogコマンドを実行
  local cmd = config.get_og_cmd() .. ' fmt --from markdown'
  local output, ret = utils.execute_command(cmd, content)
  
  if ret ~= 0 then
    utils.notify("Markdownの整形に失敗しました: " .. output, "error")
    return
  end
  
  -- バッファの内容を置き換え
  local fmt_lines = vim.split(output, '\n')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, fmt_lines)
  
  utils.notify("バッファを整形しました", "info")
end

-- バッファの内容をJSONに変換
function M.convert_to_json(output_file)
  -- バッファの内容を取得
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')
  
  -- コマンドを構築
  local cmd = config.get_og_cmd() .. ' --from markdown --to json'
  if output_file then
    cmd = cmd .. ' -o ' .. vim.fn.shellescape(output_file)
  end
  
  -- コマンドを実行
  local output, ret = utils.execute_command(cmd, content)
  
  if ret ~= 0 then
    utils.notify("JSONへの変換に失敗しました: " .. output, "error")
    return
  end
  
  if output_file then
    utils.notify("JSONに変換し、" .. output_file .. " に保存しました", "info")
  else
    -- 新しいバッファを作成してJSONを表示
    vim.cmd('new')
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))
    vim.bo[buf].filetype = 'json'
    vim.api.nvim_buf_set_name(buf, '[converted-json]')
    utils.notify("JSONに変換しました", "info")
  end
end

-- JSONからMarkdownに変換
function M.convert_from_json(input_file)
  if not input_file then
    -- ファイル選択ダイアログを表示
    input_file = vim.fn.input('JSONファイルのパスを入力: ', '', 'file')
    if input_file == '' then
      return
    end
  end
  
  -- ファイルが存在するか確認
  if vim.fn.filereadable(input_file) ~= 1 then
    utils.notify("JSONファイル " .. input_file .. " が見つかりません。", "error")
    return
  end
  
  -- コマンドを実行
  local cmd = config.get_og_cmd() .. ' --from json --to markdown ' .. vim.fn.shellescape(input_file)
  local output, ret = utils.execute_command(cmd)
  
  if ret ~= 0 then
    utils.notify("JSONからMarkdownへの変換に失敗しました: " .. output, "error")
    return
  end
  
  -- バッファの内容を置き換え
  local lines = vim.split(output, '\n')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  
  utils.notify("JSONからMarkdownに変換しました", "info")
end

return M
