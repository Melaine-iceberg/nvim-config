-- 通用 UI 增强（与语言无关）

local gh = function(repo) return 'https://github.com/' .. repo end

-- 顶部吸顶显示当前所在的函数 / impl / struct 签名。
-- 滚到函数中间时，头上还留着 "fn foo(...) -> Result<...>" 那一行。
vim.pack.add { gh 'nvim-treesitter/nvim-treesitter-context' }
require('treesitter-context').setup {
  max_lines = 3, -- 最多占几行
  multiline_threshold = 1, -- 多行签名折叠成一行显示
  mode = 'cursor', -- 只显示光标所在的那一层
  separator = nil, -- 不要分割线，靠高亮自然区分，更干净
}

-- 原生语法树选择（0.13 内置，不需要 incremental-selection 插件）
-- 在 Rust 里想选中整个 match 分支、整个 fn、整个 struct，比手搓 motions 快得多。
local ts_select = function(target)
  return function() vim.treesitter.select(target) end
end
vim.keymap.set({ 'n', 'x' }, 'gsv', ts_select 'parent', { desc = 'Expand selection to parent node' })
vim.keymap.set({ 'n', 'x' }, 'gsc', ts_select 'child', { desc = 'Shrink selection to child node' })
vim.keymap.set({ 'n', 'x' }, 'gsn', ts_select 'next', { desc = 'Select next sibling node' })
vim.keymap.set({ 'n', 'x' }, 'gsp', ts_select 'prev', { desc = 'Select previous sibling node' })

-- 彩虹括号：嵌套两层以上的 ()/[]/{} 用不同颜色区分。
-- Rust 的闭包套 match 套宏、Lua 的回调套表，一眼就能看出哪一对是一层。
-- 颜色在 lua/custom/highlights.lua 里定义，这里只决定循环顺序：
-- 4 色循环比默认 7 色克制，长表达式不会变成调色盘。
vim.pack.add { gh 'HiPhish/rainbow-delimiters.nvim' }
require('rainbow-delimiters.setup').setup {
  highlight = {
    'RainbowDelimiterBlue',
    'RainbowDelimiterCyan',
    'RainbowDelimiterViolet',
    'RainbowDelimiterRed',
  },
}

-- 把代码里写死的颜色值直接涂成那个颜色（#33b1ff、#fff 这种）。
-- mini.nvim 自带，不额外装插件；写主题、画 UI 时特别好用。
local hipatterns = require 'mini.hipatterns'
hipatterns.setup {
  highlighters = {
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
}

-- [[ <leader>t 开关组 ]]
-- 都走 snacks 的 toggle，开/关会同步到右下角通知，看得见状态变化。
local toggle = function(lhs, name, desc)
  vim.keymap.set('n', lhs, function() Snacks.toggle[name]():toggle() end, { desc = desc })
end

-- 终端：浮动窗口，再按一次收起；进程保留，不会丢历史
vim.keymap.set('n', '<leader>tt', function()
  Snacks.terminal.toggle(nil, { cwd = vim.fn.getcwd() })
end, { desc = '[T]oggle [T]erminal' })

-- 缩进线：截图 / 分享代码时临时关掉
toggle('<leader>ti', 'indent', '[T]oggle [I]ndent guides')

-- 专注模式：当前窗口放大居中，其余压暗
toggle('<leader>tz', 'zen', '[T]oggle [Z]en mode')
