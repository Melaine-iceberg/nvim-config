-- 文件管理：oil.nvim
-- 把目录变成一个可编辑的 buffer：改名字就是改文本，删行就是删文件，:w 才真正落盘。
-- 和内置 dir 分工：
--    `-` / `:e .`  → 原生 dir（只读、零开销，看和跳）
--    <leader>e    → oil（可增删改名，干活）

vim.pack.add { { src = 'https://github.com/stevearc/oil.nvim', version = vim.version.range '^2' } }

require('oil').setup {
  -- 不抢原生 dir 的 :e <dir>，两者共存
  default_file_explorer = false,

  columns = { 'icon' },
  view_options = { show_hidden = true },

  -- 删除走回收站，不永久删（Windows 支持）
  delete_to_trash = true,

  -- :w 落盘前再确认一次，避免手滑改错文件名
  skip_confirm_for_simple_edits = false,

  -- 文件在磁盘上被外部改动时自动刷新
  watch_for_changes = true,

  float = {
    padding = 2,
    max_width = 0.85,
    max_height = 0.85,
    border = 'rounded',
  },

  keymaps = {
    -- 这个键留给内置 dir，oil 不要抢
    ['-'] = false,
  },
}

-- 浮窗打开：看完按 q 就关，不占布局
vim.keymap.set('n', '<leader>e', function()
  require('oil').open_float()
end, { desc = 'Explore files (float)' })

-- 全窗口打开：适合大范围整理、批量改名
vim.keymap.set('n', '<leader>E', function()
  require('oil').open()
end, { desc = 'Explore files (window)' })
