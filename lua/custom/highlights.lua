-- 界面细节补充层（在 bamboo 之上）
--
-- bamboo 本身已经把"编辑器零件"配得挺全了：浮窗边框（紫）、分割线、搜索、
-- 补全菜单、诊断、彩虹括号、Pmenu 这些都自带，不需要再改。
--
-- 这一层只补它没管到的地方：
--   1. blink.cmp 的 kind 图标（bamboo 只配了菜单本体，没配图标那一列）
--   2. snacks 的启动页 / 缩进参考线（snacks 是后起插件，主题跟不上）
--   3. 两处观感微调（行号强调色、inlay hint 斜体）
--
-- 颜色全部来自 custom/palette.lua，深浅两套自动跟着 background 走。
-- 想恢复 bamboo 原样：把 init.lua 里的 `require 'custom.highlights'` 注释掉。

local p = require 'custom.palette'

local M = {}

local function hl(groups)
  for name, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, name, spec)
  end
end

function M.apply()
  hl {
    -- ── 行号 ──────────────────────────────────────────────────
    -- bamboo 给当前行号用的是正文色，光标那一行和别的行号没区别。
    -- 换成主题的绿色，视线会自然落回光标所在行。
    CursorLineNr = { fg = p.green, bold = true },

    -- ── 内联类型提示 ──────────────────────────────────────────
    -- rust-analyzer 的 :i32 / -> Result<T> 补出来的字原本是普通灰。
    -- 加斜体，读得清，又能一眼看出"这不是源码里的字"。
    LspInlayHint = { fg = p.dim, italic = true },

    -- ── 补全菜单 ──────────────────────────────────────────────
    -- bamboo 把补全菜单链到 NormalFloat，底色和正文一个样，只靠一圈紫边撑着。
    -- 这里给菜单和文档窗换一档浮起来的底色（深色更暗、浅色更沉），
    -- 边框沿用 bamboo 的紫，和 LSP hover 的框是一套。
    BlinkCmpMenu = { fg = p.fg, bg = p.float },
    BlinkCmpMenuBorder = { fg = p.purple, bg = p.float },
    BlinkCmpMenuSelection = { fg = p.fg, bg = p.bg3, bold = true },
    BlinkCmpDoc = { fg = p.fg, bg = p.float },
    BlinkCmpDocBorder = { fg = p.purple, bg = p.float },
    BlinkCmpSignatureHelp = { bg = p.float },
    BlinkCmpSignatureHelpBorder = { fg = p.purple, bg = p.float },

    -- kind 图标：只给 fg、不给 bg，颜色才会叠在原底色上（否则会糊成实心色块）。
    BlinkCmpKind = { fg = p.fg },
    BlinkCmpKindText = { fg = p.fg },
    BlinkCmpKindFile = { fg = p.fg },
    BlinkCmpKindVariable = { fg = p.fg },
    BlinkCmpKindReference = { fg = p.dim },
    BlinkCmpKindFunction = { fg = p.blue },
    BlinkCmpKindMethod = { fg = p.blue },
    BlinkCmpKindConstructor = { fg = p.blue },
    BlinkCmpKindClass = { fg = p.purple },
    BlinkCmpKindInterface = { fg = p.purple },
    BlinkCmpKindStruct = { fg = p.purple },
    BlinkCmpKindEnum = { fg = p.purple },
    BlinkCmpKindEnumMember = { fg = p.purple },
    BlinkCmpKindTypeParameter = { fg = p.purple },
    BlinkCmpKindField = { fg = p.teal },
    BlinkCmpKindProperty = { fg = p.teal },
    BlinkCmpKindModule = { fg = p.sky },
    BlinkCmpKindFolder = { fg = p.sky },
    BlinkCmpKindKeyword = { fg = p.pink },
    BlinkCmpKindConstant = { fg = p.pink },
    BlinkCmpKindValue = { fg = p.pink },
    BlinkCmpKindOperator = { fg = p.pink },
    BlinkCmpKindEvent = { fg = p.pink },
    BlinkCmpKindUnit = { fg = p.green },
    BlinkCmpKindSnippet = { fg = p.green },
    BlinkCmpKindColor = { fg = p.green },

    -- 匹配到的字符只加粗 + 下划线，不改颜色：
    -- 一改色就会把上面按 treesitter 上好的语法色盖掉，等于白开。
    BlinkCmpLabelMatch = { bold = true, underline = true },

    -- ── 缩进参考线 ────────────────────────────────────────────
    -- snacks.indent 默认四级全画成同一个灰，大段嵌套里看不出层次。
    -- 这里换成四级低饱和色循环（顺序在 init.lua 的 indent.hl 里指定）。
    SnacksIndent = { fg = p.indent1 },
    SnacksIndent1 = { fg = p.indent1 },
    SnacksIndent2 = { fg = p.indent2 },
    SnacksIndent3 = { fg = p.indent3 },
    SnacksIndent4 = { fg = p.indent4 },
    -- 光标所在的那个代码块，只有这一列是亮青色，光标一移就跟着换，
    -- 等于免费的"我现在在哪个函数体里"指示器。
    SnacksIndentScope = { fg = p.scope },

    -- ── 启动页 ────────────────────────────────────────────────
    -- 默认全链到 Title/Special/Number，跟正文一个灰，logo 立不起来。
    SnacksDashboardHeader = { fg = p.blue },
    SnacksDashboardIcon = { fg = p.purple },
    SnacksDashboardKey = { fg = p.teal, bold = true },
    SnacksDashboardDesc = { fg = p.fg },
    SnacksDashboardTitle = { fg = p.blue, bold = true },
    SnacksDashboardFooter = { fg = p.dim },
    SnacksDashboardSpecial = { fg = p.green },
    SnacksDashboardDir = { fg = p.dim },

    -- ── 面包屑（dropbar 画的 winbar）────────────────────────────
    -- bamboo 把 WinBar 给成 LightGrey，比正文还亮，一整条压在代码上方太抢眼。
    -- 压回 dim、底色跟正文同是 bg0：看起来像代码上方多出一行注解，
    -- 而不是又摞了一条状态栏。图标颜色不在这里管，dropbar 自己会跟语法色走。
    WinBar = { fg = p.dim, bg = p.bg0 },
    WinBarNC = { fg = p.dim, bg = p.bg0 },
  }
end

-- 首次加载就套一遍；之后每次 :colorscheme 结束也重套。
-- 所以 <leader>tm 切换明暗时，这一层会自动换成浅色版的颜色，不会残留。
M.apply()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('custom-highlights', { clear = true }),
  callback = M.apply,
})

return M
