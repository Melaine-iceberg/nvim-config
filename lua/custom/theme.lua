-- 明暗模式切换。
--
-- bamboo 的 style 不是自己记的，而是跟着 vim.o.background 走：
--   background=dark  → vulgaris（那套墨绿）
--   background=light → light
-- 所以这里只做两件事：改 background，然后把配色重新套一遍。
--
-- 用法：
--   <leader>tm        深/浅来回切
--   :ThemeToggle      同上
--   :Theme light      直接指定
--   :set background=light   手动改也接（见下面的 OptionSet 钩子）

local M = {}

local function reload()
  -- vim.cmd.colorscheme 'bamboo' 会重置所有高亮组，
  -- 然后触发 ColorScheme，custom.highlights 自动把补丁层再叠回去。
  vim.cmd.colorscheme 'bamboo'
end

--- 指定模式
---@param mode 'dark' | 'light'
function M.set(mode)
  if mode ~= 'dark' and mode ~= 'light' then
    vim.notify(('未知模式 "%s"，只能是 dark 或 light'):format(tostring(mode)), vim.log.levels.WARN)
    return
  end
  vim.o.background = mode
  reload()
end

--- 在深色和浅色之间来回切
function M.toggle()
  M.set(vim.o.background == 'dark' and 'light' or 'dark')
end

vim.keymap.set('n', '<leader>tm', M.toggle, { desc = '[T]oggle light/dark [M]ode' })

vim.api.nvim_create_user_command('Theme', function(opts) M.set(opts.args) end, {
  nargs = 1,
  complete = function() return { 'dark', 'light' } end,
  desc = 'Switch bamboo style: dark (vulgaris) / light',
})

vim.api.nvim_create_user_command('ThemeToggle', M.toggle, { desc = 'Toggle bamboo dark/light' })

-- 手动 `:set background=light` 时接住：background 变了就重套配色，
-- 不然 bamboo 的 style 会停在原来那套上（它只在 colorscheme 被调用时才读 background）。
vim.api.nvim_create_autocmd('OptionSet', {
  group = vim.api.nvim_create_augroup('custom-theme-background', { clear = true }),
  pattern = 'background',
  callback = function()
    if vim.g.colors_name == 'bamboo' then reload() end
  end,
})

return M
