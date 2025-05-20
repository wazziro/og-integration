-- ftdetect/ogtask.lua
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.md"},
  callback = function()
    if vim.fn.expand("%:t") == "todo.md" then
      vim.bo.filetype = "markdown.ogtask" -- ← ここを変更
    end
  end,
})
