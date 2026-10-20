-- Rust 专属配置
--   rustaceanvim：接管 rust-analyzer，提供 runnables / 宏展开 / clippy 诊断 / inlay hints
--   crates.nvim ：Cargo.toml 里显示依赖版本、可用更新，支持跳转和替换

local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'mrcjkb/rustaceanvim', version = vim.version.range '^9.2' },
  { src = gh 'Saecki/crates.nvim', version = vim.version.range '^0.7' },
}

-- rust-analyzer 完全交给 rustaceanvim，阻止 lspconfig 再启动一份
vim.lsp.enable('rust_analyzer', false)

vim.g.rustaceanvim = {
  server = {
    on_attach = function(_, bufnr)
      local map = function(keys, fn, desc)
        vim.keymap.set('n', keys, fn, { buffer = bufnr, desc = 'Rust: ' .. desc })
      end

      -- 列出可运行目标（bin / example / test），选中即运行
      map('<leader>rr', function() vim.cmd.RustLsp 'runnables' end, 'Runnables')
      -- 展开光标处的宏，看懂 derive 生成的东西
      map('<leader>re', function() vim.cmd.RustLsp 'expandMacro' end, 'Expand Macro')
      -- 用人话解释光标处的编译错误
      map('<leader>rx', function() vim.cmd.RustLsp 'explainError' end, 'Explain Error')
      -- 列出测试
      map('<leader>rt', function() vim.cmd.RustLsp 'testables' end, 'Testables')

      -- 写 Rust 默认打开类型提示（看到 :i32 / -> Result<T> 这类推导结果）
      -- 嫌吵就用 init.lua 里已有的 <leader>th 随时关掉
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end,
    default_settings = {
      ['rust-analyzer'] = {
        cargo = { allFeatures = true },
        -- 用 clippy 代替 cargo check 做保存时检查，能提前抓到 idiomatic 问题
        -- 注意是新写法 check.onSave；旧版顶层的 checkOnSave 已废弃
        check = { command = 'clippy', onSave = true },
        procMacro = { enable = true },
        completion = {
          -- 补全项里带上完整的函数签名（含参数名）。
          -- 关着的时候 rust-analyzer 只发 "fn(i32, i32) -> i32"——参数名被它省掉了，
          -- 菜单右边那列看着就只有一个类型串；打开后变成
          -- "fn add(a: i32, b: i32) -> i32"，同名同类型的参数才分得清。
          -- 注意 label 本身永远是 "add(…)"，参数是写在 labelDetails 里给右列用的。
          fullFunctionSignatures = { enable = true },
        },
        inlayHints = {
          typeHints = { enable = true },
          closureReturnTypeHints = { enable = 'with_block' },
          lifetimeElisionHints = { enable = 'skip_trivial' },
          bindingModeHints = { enable = false },
        },
      },
    },
  },
}

-- Cargo.toml 增强：光标停在依赖上能看到版本/是否有更新
-- 补全走 crates 自带的内置 LSP（lsp.completion），blink 的 'lsp' 源会自动接住
pcall(function()
  require('crates').setup {
    lsp = { enabled = true, actions = true, completion = true, hover = true },
  }
end)
