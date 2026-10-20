-- bamboo 调色板的适配层。
--
-- 状态栏（init.lua 里的 lualine 主题）和界面细节（custom/highlights.lua）
-- 都从这里取色。
--
-- 和之前写死一套 hex 的做法不同：这里每次取色都去问 bamboo 当前是哪套 style
-- （vulgaris / light），所以 `:set background=light` 之后整条链路会一起变浅，
-- 不需要再维护两份颜色表。缓存按 style 分开存，切换来回也不会有旧值残留。

local M = {}

-- ── 小工具 ──────────────────────────────────────────────────
local function hex2rgb(hex)
  hex = hex:gsub('#', '')
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb2hex(r, g, b)
  return string.format('#%02x%02x%02x', math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5))
end

--- 把 fg 按 amount 的比例混进 bg。
--- 缩进参考线、当前代码块这些"只该露一点色相"的地方用它，
--- 免得手写一堆偏色 hex，换个风格就对不上底色。
---@param fg string
---@param bg string
---@param amount number 0~1，fg 的占比
---@return string
local function blend(fg, bg, amount)
  local fr, fg_, fb = hex2rgb(fg)
  local br, bg_, bb = hex2rgb(bg)
  return rgb2hex(fr * amount + br * (1 - amount), fg_ * amount + bg_ * (1 - amount), fb * amount + bb * (1 - amount))
end

-- ── 当前风格 ────────────────────────────────────────────────
local function current_style()
  local cfg = vim.g.bamboo_config
  if cfg and cfg.style then return cfg.style end
  return vim.o.background == 'light' and 'light' or 'vulgaris'
end

-- ── 色板 ────────────────────────────────────────────────────
local cache = {}

local function build()
  local style = current_style()
  if cache[style] then return cache[style] end

  -- 直接读 bamboo 自带的那张表，不经过 colors.lua：
  -- colors.lua 依赖 vim.g.bamboo_config 已经 setup 过，而配色可能在 setup 之前
  -- 就被摸到；palette 是静态表，任何时候都安全。
  local c = require('bamboo.palette')[style]
  local light = style == 'light'

  local p = {
    -- 底色层次：bg0 正文 → bg1 面板/光标行 → bg2 选中 → bg3 分割线
    bg0 = c.bg0,
    bg1 = c.bg1,
    bg2 = c.bg2,
    bg3 = c.bg3,

    -- 浮窗底色。深色模式下比正文再压一档（bg_d 是 bamboo 专门留的暗面）；
    -- 浅色模式没有更"暗一档但不脏"的现成色，就近取 bg1，反差小一点更耐看。
    float = light and c.bg1 or c.bg_d,

    fg = c.fg,
    dim = c.light_grey, -- 次要文字：类型签名、注释性提示
    border = c.bg3, -- 分割线 / 浮窗边框，只比底色亮一点点
    line = c.grey, -- 非当前行号

    -- 彩色：名字沿用原来那套，改主题时上层代码一行都不用动
    blue = c.blue,
    sky = c.light_blue,
    green = c.green,
    purple = c.purple,
    pink = c.red,
    teal = c.cyan,
    yellow = c.yellow,
    orange = c.orange,

    -- 缩进参考线的分级色：往底色里掺 26% 的色相，能看出层级但不抢代码
    indent1 = blend(c.blue, c.bg0, 0.26),
    indent2 = blend(c.cyan, c.bg0, 0.26),
    indent3 = blend(c.purple, c.bg0, 0.26),
    indent4 = blend(c.coral, c.bg0, 0.26),

    -- 光标所在代码块的那一条：直接用主题的青色，跟其它层级明显区分开
    scope = c.cyan,
  }

  cache[style] = p
  return p
end

-- 表本身是空的，所有键都走 __index 现取：
-- 这样 lualine 每次重画状态栏、ColorScheme 每次重套高亮，拿到的都是当前风格的颜色。
return setmetatable(M, {
  __index = function(_, key) return build()[key] end,
})
