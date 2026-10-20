--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options
-- ============================================================
do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = true

  -- [[ Setting options ]]
  --  See `:help vim.o`
  -- NOTE: You can change these options as you wish!
  --  For more options, you can see `:help option-list`

  -- Make line numbers default
  vim.o.number = true
  -- You can also add relative line numbers, to help with jumping.
  --  Experiment for yourself to see if you like it!
  vim.o.relativenumber = true

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.o.mouse = 'a'

  -- Don't show the mode, since it's already in the status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Enable break indent
  vim.o.breakindent = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.o.signcolumn = 'yes'

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 300

  -- Configure how new splits should be opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Sets how neovim will display certain whitespace characters in the editor.
  --  See `:help 'list'`
  --  and `:help 'listchars'`
  --
  --  Notice listchars is set using `vim.opt` instead of `vim.o`.
  --  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
  --   See `:help lua-options`
  --   and `:help lua-guide-options`
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  -- Preview substitutions live, as you type!
  vim.o.inccommand = 'split'

  -- Show which line your cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  vim.o.scrolloff = 10

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  -- See `:help 'confirm'`
  vim.o.confirm = true

  -- ── 视觉细节 ──────────────────────────────────────────────
  -- 这一段只影响"看起来怎么样"，不影响功能。

  -- 真彩色。主题里全是 #rrggbb，没有这一项会被降级成 256 色近似值，颜色会发灰。
  -- （bamboo 自己会开，但显式写出来换成别的主题也不会翻车）
  vim.o.termguicolors = true

  -- 所有浮窗统一圆角：LSP hover、诊断详情、which-key、补全文档、通知都吃这一条。
  -- Neovim 0.11+ 的全局选项，省掉了给每个插件单独写 border = 'rounded'。
  vim.o.winborder = 'rounded'

  -- 空行不再刷一片 `~`；分割线/折叠标记换成细字符，画面立刻干净一档。
  vim.opt.fillchars = {
    eob = ' ', -- 缓冲区末尾留白，不要 ~~~
    vert = '│', -- 垂直分割用细线
    fold = ' ', -- 折叠行不涂底色块
    foldopen = '▾',
    foldclose = '▸',
    foldsep = '│',
    diff = '╱',
  }

  -- 行号列固定 3 格，行数在 999/1000 之间来回跳时不会整屏左右抖
  vim.o.numberwidth = 3

  -- 横向滚动时左右各留 8 列，长行滚到边缘时不贴屏幕框
  vim.o.sidescrolloff = 8

  -- 折行的行首放一个箭头。配合上面的 breakindent，长行折下来时能一眼看出
  -- "这是同一句话的下一段"，而不是新的一行。
  vim.o.showbreak = '↳ '

  -- 分屏时按屏幕位置保持内容，滚动/跳转不会让两边文字上下错位
  vim.o.splitkeep = 'screen'
end

-- ============================================================
-- SECTION 2: KEYMAPS & AUTOCMDS
-- basic keymaps, basic autocmds
-- ============================================================
do
  -- [[ Basic Keymaps ]]
  --  See `:help vim.keymap.set()`

  -- Clear highlights on search when pressing <Esc> in normal mode
  --  See `:help hlsearch`
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Diagnostic Config & Keymaps
  --  See `:help vim.diagnostic.Opts`

  -- 诊断图标用几何符号，不用 Nerd Font 图标：
  --   方块/三角/圆点比花哨图标更克制，跟 bamboo 这种低饱和主题也更搭；
  --   顺带的好处是换个没装 Nerd Font 的终端也不会变成一堆方块。
  local diag_icons = {
    [vim.diagnostic.severity.ERROR] = '●',
    [vim.diagnostic.severity.WARN] = '▲',
    [vim.diagnostic.severity.INFO] = '■',
    [vim.diagnostic.severity.HINT] = '○',
  }

  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- 行尾提示：前缀跟着严重级别换形状，颜色由 DiagnosticVirtualText* 决定，
    -- 所以同一屏里 error 是粉点、warn 是紫三角，扫一眼就能分级。
    virtual_text = {
      spacing = 2,
      prefix = function(d) return diag_icons[d.severity] or '●' end,
    },
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    -- 左侧标记列同步换成同一套符号，行尾和行号列对得上
    signs = {
      text = diag_icons,
    },

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  --
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- TIP: Disable arrow keys in normal mode
  -- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
  -- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
  -- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
  -- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

  -- Keybinds to make split navigation easier.
  --  Use CTRL+<hjkl> to switch between windows
  --
  --  See `:help wincmd` for a list of all window commands
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  -- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
  -- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
  -- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
  -- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
  -- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

  -- [[ Basic Autocommands ]]
  --  See `:help lua-guide-autocommands`

  -- Highlight when yanking (copying) text
  --  Try it with `yap` in normal mode
  --  See `:help vim.hl.hl_op()` (0.13 起 vim.hl.on_yank() 已废弃)
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.hl_op { higroup = 'Visual', timeout = 300 } end,
  })

  -- Markdown / 纯文本的"阅读模式"。
  -- 代码要的是对齐，文章要的是能顺着读：折行、按词折、把 ** / ` / 链接这些
  -- 标记符号藏掉只留结果（conceallevel=2 靠 treesitter 的 conceal 实现）。
  vim.api.nvim_create_autocmd('FileType', {
    desc = 'Prose-friendly display for markdown and text',
    group = vim.api.nvim_create_augroup('kickstart-prose', { clear = true }),
    pattern = { 'markdown', 'markdown.mdx', 'text' },
    callback = function()
      vim.opt_local.conceallevel = 2 -- 标记符号隐形，只显示渲染后的样子
      vim.opt_local.concealcursor = 'nc' -- 光标所在行也一样，不来回闪
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true -- 只在空格处折行，不把单词劈两半
      vim.opt_local.spell = true -- 拼写检查（:set spell 可临时关）
    end,
  })
end

-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
  -- [[ Intro to `vim.pack` ]]
  -- `vim.pack` is a new plugin manager built into Neovim,
  --  which provides a Lua interface for installing and managing plugins.
  --
  --  See `:help vim.pack`, `:help vim.pack-examples` or the
  --  excellent blog post from the creator of vim.pack and mini.nvim:
  --  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
  --
  --  To inspect plugin state and pending updates, run
  --    :lua vim.pack.update(nil, { offline = true })
  --
  --  To update plugins, run
  --    :lua vim.pack.update()
  --
  --
  --  Throughout the rest of the config there will be examples
  --  of how to install and configure plugins using `vim.pack`.
  --
  --  In this section we set up some autocommands to run build
  --  steps for certain plugins after they are installed or updated.

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated and
  --  runs the appropriate build command for that plugin if necessary.
  --
  -- See `:help vim.pack-events`
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

--- Because most plugins are hosted on GitHub, you can use the helper
--- function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
  -- [[ Installing and Configuring Plugins ]]
  --
  -- To install a plugin simply call `vim.pack.add` with its git url.
  -- This will download the default branch of the plugin, which will usually be `main` or `master`
  -- You can also have more advanced specs, which we will talk about later.
  --
  -- For most plugins its not enough to install them, you also need to call their `.setup()` to start them.
  --
  -- For example, lets say we want to install `guess-indent.nvim` - a plugin for
  -- automatically detecting and setting the indentation.
  --
  -- We first install it from https://github.com/NMAC427/guess-indent.nvim
  -- and then call its `setup()` function to start it with default settings.
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- Here is a more advanced configuration example that passes options to `gitsigns.nvim`
  --
  -- See `:help gitsigns` to understand what each configuration key does.
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  local gitsigns = require 'gitsigns'
  gitsigns.setup {
    signs = {
      add = { text = '+' }, ---@diagnostic disable-line: missing-fields
      change = { text = '~' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
    },
    -- gitsigns.nvim's recommended keymaps:
    on_attach = function(bufnr)
      -- Navigation
      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end, { desc = 'Jump to next git [c]hange', buf = bufnr })

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end, { desc = 'Jump to previous git [c]hange', buf = bufnr })

      -- Visual mode actions
      vim.keymap.set('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [s]tage hunk', buf = bufnr })
      vim.keymap.set('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [r]eset hunk', buf = bufnr })
      -- Normal mode actions
      vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk', buf = bufnr })
      vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk', buf = bufnr })
      vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer', buf = bufnr })
      vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer', buf = bufnr })
      vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk', buf = bufnr })
      vim.keymap.set('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline', buf = bufnr })
      vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = 'git [b]lame line', buf = bufnr })
      vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index', buf = bufnr })
      vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis '~' end, { desc = 'git [D]iff against last commit', buf = bufnr })
      vim.keymap.set('n', '<leader>hQ', function() gitsigns.setqflist 'all' end, { desc = 'git hunk [Q]uickfix list (all files in repo)', buf = bufnr })
      vim.keymap.set('n', '<leader>hq', gitsigns.setqflist, { desc = 'git hunk [q]uickfix list (all changes in this file)', buf = bufnr })
      -- Toggles
      vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line', buf = bufnr })
      vim.keymap.set('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle git intra-line [w]ord diff', buf = bufnr })
      -- Text object
      vim.keymap.set({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'text object [i]nside [h]unk', buf = bufnr })
    end,
  }

  -- Useful plugin to show you pending keybinds.
  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    -- 按键后多久弹出（毫秒）。0 = 立即，200 = 快速连按时不打断
    delay = 200,
    icons = {
      mappings = vim.g.have_nerd_font,
      breadcrumb = '»',
      separator = '➜',
      group = '+',
    },
    -- 圆角浮窗 + 内边距，跟其他浮窗风格统一
    win = {
      border = 'rounded',
      padding = { 1, 2 },
    },
    layout = {
      spacing = 4,
      align = 'center',
    },
    -- Document existing key chains
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>b', group = '[B]uffer' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
      { '<leader>r', group = '[R]ust', mode = { 'n' } },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
      { ']', group = 'Next' },
      { '[', group = 'Prev' },
    },
  }

  -- [[ Colorscheme ]]
  -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command under that to load whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  -- [[ Colorscheme: bamboo ]]
  -- 墨绿底色的主题，语法色克制（蓝紫用得少，红黄绿为主），长时间看眼睛不累。
  --
  -- 明暗两套：
  --   深色 = vulgaris（默认那套）
  --   浅色 = light
  -- bamboo 的 style 是跟着 vim.o.background 走的，所以切换只要改 background
  -- 再重套一次配色：<leader>tm 来回切，或 :Theme light / :Theme dark。
  -- 具体逻辑在 lua/custom/theme.lua。
  vim.pack.add { gh 'ribru17/bamboo.nvim' }

  vim.o.background = 'dark'

  require('bamboo').setup {
    style = 'vulgaris', -- 深色底子；background=light 时 bamboo 会自动切到 'light'
    toggle_style_key = nil, -- 不用它自带的循环切换，走下面的 <leader>tm
    toggle_style_list = { 'vulgaris', 'light' },
    transparent = false,
    dim_inactive = false, -- 不做非活动窗口压暗，分屏时看着更均匀
    ending_tildes = false, -- 不显示缓冲区末尾那堆 ~
    cmp_itemkind_reverse = false,

    -- 代码风格：注释和条件判断走斜体，其余保持直立。
    code_style = {
      comments = { italic = true },
      conditionals = { italic = true },
      keywords = {},
      functions = {},
      namespaces = { italic = true },
      parameters = { italic = true },
      strings = {},
      variables = {},
    },

    diagnostics = {
      darker = false,
      undercurl = true,
      background = false, -- 行尾诊断为只上色、不加底色，代码行不会被糊成一块
    },
  }

  vim.cmd.colorscheme 'bamboo'

  -- bamboo 没覆盖到的零件（补全图标、缩进线、启动页）在这里补，
  -- 颜色统一从 lua/custom/palette.lua 取，深浅两套自动跟着走。
  require 'custom.highlights'

  -- 明暗切换：<leader>tm / :ThemeToggle / :Theme dark|light
  require 'custom.theme'

  -- 想让编辑器跟终端背景融为一体（毛玻璃/透明终端），取消下面三行注释：
  -- vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  -- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
  -- vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })

  -- Highlight todo, notes, etc in comments
  vim.pack.add { gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup { signs = false }

  -- [[ mini.nvim ]]
  --  A collection of various small independent plugins/modules
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- If a nerd font is available, load the icons module for pretty icons in various plugins.
  if vim.g.have_nerd_font then
    require('mini.icons').setup()
    -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
    MiniIcons.mock_nvim_web_devicons()
  end

  -- Better Around/Inside textobjects
  --
  -- Examples:
  --  - va)  - [V]isually select [A]round [)]paren
  --  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
  --  - ci'  - [C]hange [I]nside [']quote
  require('mini.ai').setup {
    -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  --
  -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
  -- - sd'   - [S]urround [D]elete [']quotes
  -- - sr)'  - [S]urround [R]eplace [)] [']
  require('mini.surround').setup()

  -- [[ Statusline: lualine ]]
  -- 手搓一套跟 bamboo 调色板对齐的主题，比通用主题更协调。
  -- 色板本身在 lua/custom/palette.lua，和 custom/highlights.lua 共用同一份。
  vim.pack.add { gh 'nvim-lualine/lualine.nvim' }

  -- theme 写成函数，而不是一张固定表：
  -- lualine 每次收到 ColorScheme 或 background 变化都会重新调用它，
  -- 于是 <leader>tm 切到浅色时状态栏会一起变，不会留在深色那套里。
  local function bamboo_theme()
    local p = require 'custom.palette'
    return {
      normal = {
        a = { fg = p.bg0, bg = p.green, gui = 'bold' },
        b = { fg = p.fg, bg = p.bg1 },
        c = { fg = p.dim, bg = p.bg0 },
      },
      insert = { a = { fg = p.bg0, bg = p.blue, gui = 'bold' } },
      visual = { a = { fg = p.bg0, bg = p.purple, gui = 'bold' } },
      replace = { a = { fg = p.bg0, bg = p.pink, gui = 'bold' } },
      command = { a = { fg = p.bg0, bg = p.yellow, gui = 'bold' } },
      terminal = { a = { fg = p.bg0, bg = p.teal, gui = 'bold' } },
      inactive = {
        a = { fg = p.dim, bg = p.bg0 },
        b = { fg = p.dim, bg = p.bg0 },
        c = { fg = p.dim, bg = p.bg0 },
      },
    }
  end

  require('lualine').setup {
    options = {
      theme = bamboo_theme,
      -- 扁平风：不要倾斜的切角，也不要在组件之间插分隔符——
      -- 分隔符的颜色会跟着组件自己的前景色走（这里是接近纯白的文字色），
      -- 一道亮白竖线反而比不加更吵。层次交给各段的底色差去做。
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      globalstatus = true,
      disabled_filetypes = {
        statusline = { 'dashboard', 'snacks_dashboard', 'oil', 'help' },
        -- winbar 不在这里配：顶部面包屑整条交给 dropbar（见
        -- lua/custom/plugins/breadcrumb.lua）。lualine 只要还写着 winbar，
        -- dropbar 就会因为"这一行已经被占用"而拒绝挂载。
      },
    },
    sections = {
      lualine_a = { { 'mode', padding = { left = 1, right = 1 } } },
      lualine_b = { 'branch', 'diff' },
      -- 只留文件名，不带路径：完整路径已经在顶部面包屑里了，
      -- 底部再写一遍等于同一条信息占两行，长路径还会把状态栏挤爆。
      lualine_c = { { 'filename', path = 0, symbols = { modified = ' ●', readonly = ' ', newfile = '' } } },
      -- 右侧：诊断 → 文件类型 → 文件编码。诊断靠右，和左边光标位置分开，
      -- 眼睛不用在两个信息密度高的区域之间来回找。
      lualine_x = {
        { 'diagnostics', symbols = { error = '● ', warn = '▲ ', info = '■ ', hint = '○ ' } },
        { 'filetype', colored = true },
        { 'encoding' },
      },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    inactive_sections = {
      lualine_c = { { 'filename', path = 0 } },
      lualine_x = { 'location' },
    },

    -- 这里不再有 winbar / inactive_winbar：
    -- 顶部面包屑整条交给 dropbar.nvim，它可点击展开（同级文件 / 同级方法都列出来），
    -- 配置在 lua/custom/plugins/breadcrumb.lua。lualine 和它抢同一行只会让 dropbar 让位。

    extensions = { 'quickfix', 'mason' },
  }

  -- ... and there is more!
  --  Check out: https://github.com/nvim-mini/mini.nvim
end

-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
  -- [[ Fuzzy Finder (files, lsp, etc) ]]
  --
  -- Telescope is a fuzzy finder that comes with a lot of different things that
  -- it can fuzzy find! It's more than just a "file finder", it can search
  -- many different aspects of Neovim, your workspace, LSP, and more!
  --
  -- There are lots of other alternative pickers (like snacks.picker, or fzf-lua)
  -- so feel free to experiment and see what you like!
  --
  -- The easiest way to use Telescope, is to start by doing something like:
  --  :Telescope help_tags
  --
  -- After running this command, a window will open up and you're able to
  -- type in the prompt window. You'll see a list of `help_tags` options and
  -- a corresponding preview of the help.
  --
  -- Two important keymaps to use while in Telescope are:
  --  - Insert mode: <c-/>
  --  - Normal mode: ?
  --
  -- This opens a window that shows you all of the keymaps for the current
  -- Telescope picker. This is really useful to discover what Telescope can
  -- do as well as how to actually do it!

  -- [[ snacks.nvim ]]
  -- folke 出品，一个插件覆盖：picker / dashboard / 通知 / 缩进线 / 平滑滚动 / 输入框。
  -- 顶掉原来 telescope + plenary + fzf-native + ui-select 四个插件，更快也更统一。
  vim.pack.add { gh 'folke/snacks.nvim' }

  -- 欢迎页底部的插件计数。
  -- 注意：不要用 #vim.pack.get()，它会解析每个插件的 git 版本，实测要 700ms。
  -- 直接数目录，耗时约 1ms。
  local nplugins = 0
  for _, kind in vim.fs.dir(vim.fs.joinpath(vim.fn.stdpath 'data', 'site', 'pack', 'core', 'opt')) do
    if kind == 'directory' then nplugins = nplugins + 1 end
  end

  require('snacks').setup {
    -- 模糊查找（替代 telescope）
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true, ignored = false },
      },
      layouts = {
        default = { layout = { width = 0.85, height = 0.85 } },
      },
      -- 列表里"文件名在前、路径压暗跟在后面"：先读到叫什么，需要区分同名文件
      -- 时再往右看它在哪个目录。默认顺序是反的，一屏长路径读起来很累。
      formatters = {
        file = { filename_first = true, truncate = 'center', min_width = 40 },
      },
      win = {
        input = { keys = { ['<Esc>'] = { 'close', mode = { 'n', 'i' } } } },
      },
    },

    -- 无参数启动时的欢迎页
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = ' ', key = 'f', desc = 'Find File', action = ':lua Snacks.picker.files()' },
          { icon = ' ', key = 'r', desc = 'Recent Files', action = ':lua Snacks.picker.recent()' },
          { icon = ' ', key = 'g', desc = 'Grep Text', action = ':lua Snacks.picker.grep()' },
          { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
          { icon = '', key = 'q', desc = 'Quit', action = ':qa' },
        },
        header = table.concat({
          '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
          '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
          '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
          '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
          '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
          '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
          '',
          '             bamboo  ·  rust',
        }, '\n'),
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
        -- 不要用 { section = 'startup' }：它内部写死了 require('lazy.stats')，
        -- 而本配置用的是内置 vim.pack，没有 lazy.nvim，会直接抛错。
        {
          align = 'center',
          padding = 1,
          text = { { 'vim.pack  ·  ', hl = 'footer' }, { nplugins .. ' plugins', hl = 'special' } },
        },
      },
    },

    -- 右下角通知
    -- fancy 样式 = 图标 + 标题 + 一条与级别同色的横线 + 右上角时间，
    -- 比默认的紧凑样式有层次，又不会像 nvim-notify 那样糊一大块。
    notifier = {
      enabled = true,
      style = 'fancy',
      timeout = 3000,
      width = { min = 40, max = 0.4 },
    },

    -- 缩进参考线：四级色循环 + 当前代码块高亮（具体颜色在 custom/highlights.lua）
    indent = {
      enabled = true,
      animate = { enabled = true, style = 'out' },
      hl = { 'SnacksIndent1', 'SnacksIndent2', 'SnacksIndent3', 'SnacksIndent4' },
      -- scope：光标所在的那一层用亮青色描出来，等于免费的"当前位置"指示器
      scope = { enabled = true, underline = true },
    },

    -- 平滑滚动
    scroll = { enabled = true },

    -- 命令行输入框美化
    input = { enabled = true },

    -- 超大文件保护：自动关掉 treesitter / 折叠，防止卡死
    bigfile = { enabled = true },

    -- 快速打开时跳过部分插件
    quickfile = { enabled = true },

    -- 内置终端（<leader>tt 开）
    terminal = { enabled = true },

    -- 以下模块暂不启用：
    --  statuscolumn 会接管 sign 列，需要调整 gitsigns/诊断配置，先不动
    --  explorer 用 oil.nvim 或 :Ex 更顺手
    statuscolumn = { enabled = false },
    explorer = { enabled = false },
    words = { enabled = false },
  }

  -- 键位和原来的 telescope 完全一致，肌肉记忆不用改
  vim.keymap.set('n', '<leader>sh', function() Snacks.picker.help() end, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', function() Snacks.picker.files() end, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', function() Snacks.picker.pickers() end, { desc = '[S]earch [S]elect picker' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', function() Snacks.picker.grep_word() end, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', function() Snacks.picker.resume() end, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', function() Snacks.picker.recent() end, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', function() Snacks.picker.commands() end, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', function() Snacks.picker.buffers() end, { desc = '[ ] Find existing buffers' })

  -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
  -- If you later switch picker plugins, this is where to update these mappings.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      -- Find references for the word under your cursor.
      vim.keymap.set('n', 'grr', function() Snacks.picker.lsp_references() end, { buffer = buf, desc = '[G]oto [R]eferences' })

      -- Jump to the implementation of the word under your cursor.
      -- Useful when your language has ways of declaring types without an actual implementation.
      vim.keymap.set('n', 'gri', function() Snacks.picker.lsp_implementations() end, { buffer = buf, desc = '[G]oto [I]mplementation' })

      -- Jump to the definition of the word under your cursor.
      -- This is where a variable was first declared, or where a function is defined, etc.
      -- To jump back, press <C-t>.
      vim.keymap.set('n', 'grd', function() Snacks.picker.lsp_definitions() end, { buffer = buf, desc = '[G]oto [D]efinition' })

      -- Fuzzy find all the symbols in your current document.
      -- Symbols are things like variables, functions, types, etc.
      vim.keymap.set('n', 'gO', function() Snacks.picker.lsp_symbols() end, { buffer = buf, desc = 'Open Document Symbols' })

      -- Fuzzy find all the symbols in your current workspace.
      -- Similar to document symbols, except searches over your entire project.
      vim.keymap.set('n', 'gW', function() Snacks.picker.lsp_workspace_symbols() end, { buffer = buf, desc = 'Open Workspace Symbols' })

      -- Jump to the type of the word under your cursor.
      -- Useful when you're not sure what type a variable is and you want to see
      -- the definition of its *type*, not where it was *defined*.
      vim.keymap.set('n', 'grt', function() Snacks.picker.lsp_type_definitions() end, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  -- 搜索当前缓冲区内的行
  vim.keymap.set('n', '<leader>/', function() Snacks.picker.lines() end, { desc = '[/] Fuzzily search in current buffer' })

  -- 只在已打开的缓冲区里 grep
  vim.keymap.set('n', '<leader>s/', function() Snacks.picker.grep_buffers() end, { desc = '[S]earch [/] in Open Files' })

  -- 直接搜索 Neovim 配置文件
  vim.keymap.set('n', '<leader>sn', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })

  -- 标签页之间来回切（顶部那排页签点鼠标也行，这里留键盘的）
  vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev buffer (tab)' })
  vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer (tab)' })

  -- 关当前页签。走 snacks.bufdelete 而不是 :bdelete，
  -- 这样同一个文件开了多个分屏时窗口布局不会被扯乱。
  vim.keymap.set('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = '[B]uffer [D]elete (close tab)' })
end

-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
  -- [[ LSP Configuration ]]
  -- Brief aside: **What is LSP?**
  --
  -- LSP is an initialism you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  -- LSP 进度/通知统一交给 snacks.notifier（见 Section 5），
  -- 所以这里不再安装 fidget.nvim，避免右下角两个进度窗互相重叠。

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename the variable under your cursor.
      --  Most Language Servers support renaming across files, etc.
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --  See `:help lsp-config` for information about keys and how to configure
  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- tsc = {},
    --
    -- Some languages (like rust) have entire language plugins that can be useful:
    --    https://github.com/mrcjkb/rustaceanvim
    --
    -- But for many setups, the LSP (`rust_analyzer`) will work just fine
    -- rust_analyzer = {},

    stylua = {}, -- Used to format Lua code

    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
        client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
            --  See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.api.nvim_get_runtime_file('', true),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- Disable formatting (formatting is done by stylua)
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }

  -- Automatically install LSPs and related tools to stdpath for Neovim
  require('mason').setup {}

  -- Translates between nvim-lspconfig server names and mason.nvim package names (e.g. lua_ls <-> lua-language-server)
  require('mason-lspconfig').setup {
    automatic_enable = false, -- Change this to true if you want to automatically enable servers that are installed manually (e.g. via :Mason / :MasonInstall)
  }

  -- Ensure the servers and tools above are installed
  --
  -- To check the current status of installed tools and/or manually install
  -- other tools, you can run
  --    :Mason
  --
  -- You can press `g?` for help in this menu.
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- You can add other tools here that you want Mason to install
  })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ============================================================
-- SECTION 7: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
  -- [[ Formatting ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- You can specify filetypes to autoformat on save here:
      local enabled_filetypes = {
        -- lua = true,
        -- python = true,
        rust = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
    },
    -- You can also specify external formatters in here.
    formatters_by_ft = {
      rust = { 'rustfmt' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end

-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
do
  -- [[ Snippet Engine ]]

  -- NOTE: You can also specify plugin using a version range for its git tag.
  --  See `:help vim.version.range()` for more info
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}

  -- `friendly-snippets` contains a variety of premade snippets.
  --    See the README about individual language/framework/plugin snippets:
  --    https://github.com/rafamadriz/friendly-snippets
  --
  -- 注意：LuaSnip 只是「片段引擎」，它自己一条片段都不带。
  -- 只 setup 引擎、不装片段库 = 仓库是空的，blink 的 snippets 源永远返回 0 条，
  -- 菜单里自然怎么敲都不会出现片段项。这就是之前"片段补全不生效"的原因。
  vim.pack.add { gh 'rafamadriz/friendly-snippets' }

  -- lazy_load 只注册一个 FileType 钩子，真正打开某类文件时才去读它那堆 json，
  -- 不会把几百条片段全塞进启动流程。
  require('luasnip.loaders.from_vscode').lazy_load()

  -- 自己写的片段放 lua/custom/snippets/<filetype>.lua，同样按需加载。
  -- 不想要自定义片段：把那个目录整个删掉即可，这里的判断会让它安静跳过。
  local snippets_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'snippets')
  if vim.uv.fs_stat(snippets_dir) then
    require('luasnip.loaders.from_lua').lazy_load { paths = { snippets_dir } }
  end

  -- [[ Autocomplete Engine ]]
  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }

  -- 菜单第一列怎么画（把 rust-analyzer 的 "(… )" 换成真实参数表）：
  -- 逻辑在 lua/custom/blink_label.lua，这里只是把两个函数挂上去。
  local blink_label = require 'custom.blink_label'

  require('blink.cmp').setup {
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See `:help blink-cmp-config-keymap` for defining your own keymap
      preset = 'default',

      -- 'default' 预设里只有 <C-y> 是 accept，<CR> 压根没映射。
      -- 习惯回车确认的话，少了这一行就会出现"菜单里明明显示整段片段，
      -- 回车后缓冲区里只剩触发词"——因为回车只是换行，条目从未被接受。
      -- 'accept' 接受当前选中项；菜单没开时 fallback 回落成正常换行。
      -- （想保留 <C-y> 又要回车确认，就照这样在预设上叠一条，别整套换成 'enter'，
      --   那会把 <C-y> 一起丢掉。）
      ['<CR>'] = { 'accept', 'fallback' },

      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      -- 终端里是等宽 Nerd Font（你用的是 Maple Mono NF CN）→ 保持 'mono'：
      -- 图标只占 1 列，跟后面的文字严丝合缝。如果换成非等宽的 Nerd Font 再改 'normal'。
      nerd_font_variant = 'mono',
      -- 图标字形沿用 blink 内置的一套（Material Design Icons，Nerd Font 都有）。
      -- 想换某个 kind 的图标就在下面单开一行覆盖，例如：
      --   kind_icons = { Function = '', Method = '' },
    },

    completion = {
      -- 文档窗口：默认 auto_show = false，只有按 <c-space> 才弹，所以平时看不到。
      -- 打开后选中条目右侧会自动浮出签名 + 注释（这块内容由 LSP 的 markdown 渲染）。
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          -- 优先贴在菜单右侧（'e' = east），右边空间不够才依次退到左 / 下 / 上。
          -- 两个 key 分别对应"菜单在光标上方 / 下方"两种情况。
          direction_priority = {
            menu_north = { 'e', 'w', 'n', 's' },
            menu_south = { 'e', 'w', 's', 'n' },
          },
          max_width = 70,
        },
      },

      menu = {
        draw = {
          -- 补全项本身的语法高亮：blink 会拿当前文件的 treesitter 语法把每个
          -- label 解析一遍再上色，于是字段、函数、宏、类型各是各的颜色。
          -- 只对 'lsp' 源开（path/snippet 的 label 是路径和占位符，解析没意义）。
          treesitter = { 'lsp' },
          -- 列布局：只有图标 + 名字两列。
          -- 以前返回类型单独占右边一列（那排灰色 "→ Self"），现在整条
          -- "名字(参数) -> 返回类型" 全挤在第一列里，菜单能窄一截，
          -- 读的时候也不用左右来回跳。想再加回来的话就在末尾补
          -- { 'source_name' } 之类。
          columns = {
            { 'kind_icon' },
            { 'label' },
          },
          components = {
            -- 唯一一列：名字 + 真实参数表 + 返回类型。
            -- 参数从 labelDescription 那张签名里抠（把 rust-analyzer 的 "(… )" 占位
            -- 换掉），返回类型接在后面。参数能占多宽由这一行剩下的空位决定，
            -- 只有顶到 max 才会省略 —— 逻辑全在 lua/custom/blink_label.lua。
            -- max 从 blink_label.max_width 取，避免两边各写一个数。
            label = {
              width = { fill = true, max = blink_label.max_width },
              ellipsis = true,
              text = blink_label.text,
              highlight = blink_label.highlight,
            },
          },
        },
      },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets' },
      providers = {
        snippets = {
          opts = {
            -- friendly-snippets 每条都带 description。打开后它塞进 labelDetails.description，
            -- 由 custom/blink_label.lua 接在触发词后面显示（右列已经取消了）。
            -- 关掉的话菜单里只剩一堆触发词缩写，猜不出哪条是干什么的。
            use_label_description = true,
          },
        },
      },
    },

    snippets = { preset = 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See `:help blink-cmp-config-fuzzy` for more information
    fuzzy = { implementation = 'prefer_rust_with_warning' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  }
end

-- ============================================================
-- SECTION 9: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
  -- [[ Configure Treesitter ]]
  --  Used to highlight, edit, and navigate code
  --
  --  See `:help nvim-treesitter-intro`

  -- NOTE: You can also specify a branch or a specific commit
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Ensure basic parsers are installed
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'rust', 'toml' }
  require('nvim-treesitter').install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if the buffer is valid (might not be after install completes)
    if not vim.api.nvim_buf_is_valid(buf) then return end

    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then return end

    -- Enable syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds
    -- For more info on folds see `:help folds`
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.wo.foldmethod = 'expr'

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

    -- Enable treesitter based indentation
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable the parser if it is already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
        treesitter_try_attach(buf, language)
      end
    end,
  })
end

-- ============================================================
-- SECTION 10: OPTIONAL EXAMPLES / NEXT STEPS
-- kickstart.plugins.* examples
-- ============================================================
do
  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug'
  -- require 'kickstart.plugins.indent_line'
  -- require 'kickstart.plugins.lint'
  -- require 'kickstart.plugins.autopairs'
  -- require 'kickstart.plugins.neo-tree'

  -- NOTE: You can add your own plugins, configuration, etc. in `lua/custom/plugins/*.lua`.
  --
  -- For independent modules, uncomment the convenience loader:
  require 'custom.plugins'
  --
  -- `custom.plugins` automatically loads files from that directory, but their
  -- order is unspecified. If plugins depend on each other, keep them in the same
  -- file and put their `vim.pack.add()` and `setup()` calls in the required order.
  --
  -- If separate modules need a specific order, require them explicitly instead:
  -- require 'custom.plugins.colorscheme'
  -- require 'custom.plugins.ui'
  -- require 'custom.plugins.git'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
