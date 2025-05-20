-- テスト用の設定ファイル

-- パスを追加して開発中のプラグインを読み込めるようにする
local plug_path = vim.fn.expand('<sfile>:p:h:h')
vim.opt.rtp:prepend(plug_path)

-- プラグインを設定
require('og').setup({
  -- テスト用の設定
  notification_level = 'debug',
})

print('nvim-ogプラグインのテスト設定を読み込みました。')
