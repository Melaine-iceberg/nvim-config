-- 面包屑导航（winbar）：dropbar.nvim
--
-- 窗口顶部画一条  路径 › 模块 › 结构体 › 函数 › 语句  的层级条，
-- 点任意一段就从那一格往下弹出**同级**的兄弟节点：
--   · 点目录   → 这个目录里的其它文件 / 子目录
--   · 点 impl  → 同一个 impl 里的其它方法
--   · 点 match  → 其它分支
-- 选中直接跳过去，跟 VS Code 顶部那套面包屑一个手感。键盘也能用：
-- <leader>; 打开"挑一个符号"的菜单，菜单里 <CR> 跳转、i 进模糊搜索。
--
-- 数据来源按顺序退化：LSP 的 documentSymbol → treesitter → 纯路径。
-- 所以没有 LSP 的文件（txt、配置文件）也不会整条空掉，至少还写得出"在哪"。
--
-- 注意：dropbar 自己独占 winbar（直接写 vim.wo.winbar），
-- 所以 init.lua 里的 lualine 已经不再配置 winbar / inactive_winbar，
-- 两边同时写只会互相覆盖。

local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'Bekaboo/dropbar.nvim' }

-- 这些地方没有"层级"可讲，或者本来就窄，多一行只会把正文挤掉。
-- 名单和原来 lualine 的 disabled_filetypes.winbar 保持一致，另加了浮窗类的 ft。
local excluded_filetypes = {
  dashboard = true,
  oil = true,
  help = true,
  qf = true,
  mason = true,
  terminal = true,
  snacks_dashboard = true,
  snacks_picker_list = true,
  snacks_picker_input = true,
  snacks_picker_preview = true,
}

local function is_big_file(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return false end
  local stat = vim.uv.fs_stat(name)
  return stat ~= nil and stat.size > 1024 * 1024
end

--- 这个 buffer 本身值不值得画一条面包屑（不看窗口）
---@param buf integer
---@return boolean
local function buffer_excluded(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return true end
  -- help / 目录浏览 / 终端 / 浮层这类 buftype 非空的 buffer，层级没有意义
  if vim.bo[buf].buftype ~= '' then return true end
  if excluded_filetypes[vim.bo[buf].filetype] then return true end
  -- 无名 buffer（刚打开、:enew）没有"在哪"可讲，画出来只是一条空行
  if vim.api.nvim_buf_get_name(buf) == '' then return true end
  -- 超大文件不做符号解析，否则滚动会卡
  return is_big_file(buf)
end

require('dropbar').setup {
  bar = {
    -- 默认的 enable 只在"有 treesitter 或有 LSP"时才挂，纯文本文件顶上会是空的。
    -- 这里反过来：默认都挂，拿不到符号就只显示路径——正好接替原来 lualine 里那一段。
    enable = function(buf, win)
      if buf == 0 then buf = vim.api.nvim_get_current_buf() end
      if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then return false end

      -- 非普通窗口（浮窗、terminal 浮层、picker 预览）不占这一行
      if vim.fn.win_gettype(win) ~= '' then return false end
      if vim.api.nvim_win_get_config(win).relative ~= '' then return false end

      -- 别人已经设了 winbar 就不抢
      if vim.wo[win].winbar ~= '' then return false end

      return not buffer_excluded(buf)
    end,

    padding = { left = 1, right = 1 },

    -- 路径那几段太长时掐掉中间，保留"从哪开始"和"文件叫什么"
    truncate = true,
  },

  menu = {
    -- 在菜单里上下移动时，光标会在相邻符号之间实时预览；点歪了也不会乱跳
    preview = true,
    -- 弹菜单时光标自动跳到最近的格子，不用先挪鼠标再去点
    quick_navigation = true,
    entry = { padding = { left = 1, right = 1 } },
  },

  icons = {
    -- 图标跟着 bamboo 的语法色走（函数蓝、类型紫、字段青），
    -- 和状态栏、补全菜单里那一套是同一个色系，不会突然跳出一堆饱和色。
    enable = true,
  },
}

-- dropbar 只负责"挂"，不管"摘"：它一旦往某个窗口写过 winbar，
-- 之后这个窗口切成 oil / help / 空 buffer 也还留着那一行。
-- 下面把不该有的地方清掉，等切回普通文件时 dropbar 自己会重新挂上。
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'FileType' }, {
  group = vim.api.nvim_create_augroup('custom-dropbar-detach', { clear = true }),
  callback = function(args)
    if not buffer_excluded(args.buf) then return end
    for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
      if vim.wo[win].winbar ~= '' then vim.wo[win].winbar = '' end
    end
  end,
})

-- 鼠标划过面包屑时高亮光标下那一段。Neovim 默认不投递 MouseMove 事件，
-- 不打开这一项就只有"点得动"，没有"指得亮"。
vim.o.mousemoveevent = true

-- 键盘入口：列出当前位置的所有层级，挑一个直接跳（等价于"点面包屑"）。
-- 鼠标党可以完全忽略这条，直接点顶部那排字就行。
vim.keymap.set('n', '<leader>;', function() require('dropbar.api').pick() end, { desc = 'Pick symbol from breadcrumb' })
