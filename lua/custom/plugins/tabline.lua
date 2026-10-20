-- 文件标签页：bufferline.nvim
--
-- 屏幕最上面那排页签，就是"现在开着哪几个文件"。
-- 点一下切过去，点 ✕ / 中键关掉，跟 VS Code 一个手感。
--
-- 和 <leader><leader>（snacks 的 buffer 列表）分工：
--   页签   → 手上正在翻的两三个文件，一直在视野里，随手切
--   picker → 翻找那些已经忘了名字的 buffer
--
-- 颜色不用自己配：bufferline 会从当前主题的 Normal / TabLineSel / Diagnostic
-- 里推出一整套（见 bufferline.config），bamboo 深浅两套它都跟得上，
-- 切换明暗时它自己重算高亮，不需要往 custom/highlights.lua 里再加东西。

local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'akinsho/bufferline.nvim' }

-- 关页签走 snacks.bufdelete：同一个文件开了多个分屏时，它只关 buffer 不动窗口，
-- 而默认的 `bdelete!` 会把窗口一起卷走，布局会突然塌掉。
local close = function(bufnr) Snacks.bufdelete { buf = bufnr } end

require('bufferline').setup {
  options = {
    mode = 'buffers',

    -- 不要 [1][2] 这种序号前缀：文件名加图标已经够认了，
    -- 前缀除了占宽度还会跟行号、状态栏里的数字打架。
    numbers = 'none',

    -- 选中态只在下缘画一条线，比左侧那块大色块安静得多
    indicator = { style = 'underline' },
    separator_style = 'thin',

    -- 图标来自 mini.icons 的 devicons 兼容层（init.lua 里已经 mock 过，
    -- 所以不必再装 nvim-web-devicons）
    show_buffer_icons = true,
    color_icons = true,

    show_buffer_close_icons = true,
    buffer_close_icon = '✕',
    -- 改动点和状态栏那颗保持一致，扫一眼就知道哪个文件还没存
    modified_icon = '●',

    -- 右上角那个"关掉全部"的按钮不要：挨着页签，误点的代价太大
    show_close_icon = false,

    -- 页签上带 LSP 诊断数：改别人文件的时候，先知道还剩几个红点
    diagnostics = 'nvim_lsp',

    -- 只有一个文件时也留着这排。关掉确实能省一行，
    -- 但每开一个新文件整屏就往下跳一格，眼睛很难受。
    always_show_bufferline = true,

    close_command = close,
    right_mouse_command = close,
    middle_mouse_command = close,

    -- 只把"真正的文件"开成页签。
    -- help / quickfix / 浮窗 / oil 的目录 buffer，buftype 都不是空的，
    -- 一条规则就能全挡掉，不然跳几次定义 tab 栏就满是临时 buffer。
    custom_filter = function(buf)
      return vim.bo[buf].buftype == '' and vim.bo[buf].filetype ~= 'oil'
    end,
  },
}

-- 启动页上不挂页签：那时候一个文件都没开，留着只是一条空色带，
-- 还会把 dashboard 的 logo 往下顶一行。进到真文件再让它回来。
local group = vim.api.nvim_create_augroup('custom-tabline', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = { 'dashboard', 'snacks_dashboard' },
  callback = function() vim.o.showtabline = 0 end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = '*',
  callback = function()
    if vim.bo.buftype == '' and vim.bo.filetype ~= 'snacks_dashboard' then vim.o.showtabline = 2 end
  end,
})

