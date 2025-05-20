-- nvim-og: A Neovim plugin for the og task management tool
local M = {}

-- モジュールをインポート
local config = require('og.config')
local commands = require('og.commands')

-- プラグインの初期化関数
function M.setup(opts)
  -- ユーザー設定とデフォルト設定をマージ
  config.setup(opts)

  -- コマンドの登録
  commands.setup()
  
  -- 自動コマンドの登録
  M.create_autocmds()
end

-- 自動コマンドの設定
function M.create_autocmds()
  local augroup = vim.api.nvim_create_augroup('OgTaskManager', { clear = true })
  
  -- todo.mdファイルを開いたときに、todo.jsonから内容を読み込む
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = augroup,
    pattern = '*.md',
    callback = function(args)
      local file = vim.fn.expand('<afile>:p')
      local file_base = vim.fn.fnamemodify(file, ':r')
      local json_file = file_base .. '.json'
      
      -- JSONファイルが存在するか確認
      if vim.fn.filereadable(json_file) == 1 and vim.fn.fnamemodify(file, ':t') == 'todo.md' then
        commands.load_from_json(json_file)
      end
    end,
  })
  
  -- todo.mdファイルを保存する前に、JSONに変更を適用する
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup,
    pattern = '*.md',
    callback = function(args)
      local file = vim.fn.expand('<afile>:p')
      local file_base = vim.fn.fnamemodify(file, ':r')
      local json_file = file_base .. '.json'
      
      -- JSONファイルが存在するか確認、または新規作成が必要か
      if vim.fn.fnamemodify(file, ':t') == 'todo.md' then
        local success = commands.apply_to_json(json_file)
        
        -- 失敗した場合は保存を中止
        if not success then
          return true -- true を返して保存を中止
        end
      end
    end,
  })
end

return M
