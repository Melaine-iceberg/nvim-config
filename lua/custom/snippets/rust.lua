-- Rust 补充片段：只放"上游确实没给"的那几条
--
-- 这个文件原先写了 5 条（impl / pubfn / dbg / pld / tmod），只按 friendly-snippets
-- 去重了。后来发现 rust-analyzer 自己也会往补全菜单里塞片段（CompletionItem 的
-- insertTextFormat=Snippet），于是 impl / dbg / tmod 三条在菜单里各出现两份：
--   自定义 LuaSnip 一份 + rust-analyzer 一份，内容几乎一样，纯噪音。
--
-- 实测（rust-analyzer 1.99.1，在真实 cargo 工程里直接要 textDocument/completion）：
--   impl  → "impl $1 {\n $0\n}"            顶层和函数体内都有
--   tmod  → "#[cfg(test)]\nmod tests { … }" 顶层（item 位置）有
--   dbg   → "dbg!($0)"                     宏补全，函数体内有
-- 所以这三条删掉，交给 rust-analyzer 提供，菜单里不再重复。
--
-- 留下的两条是有理由的：
--   pubfn：rust-analyzer 只有 pub / pub(crate) / pub(super)（正文就一个 "pub "）
--          和 fn（不带可见性），没有 "pub fn" 这个组合。
--   pld  ：rust-analyzer 只给 println!($0)，没有带 {:?} 格式符的版本。
--
-- 想自己复查上游有哪些片段，可以在 rust 工程里对某个前缀拉一次原始补全项，
-- 看 label 和 insertTextFormat 就行：
--   :lua =vim.lsp.buf_request_sync(0, 'textDocument/completion',
--     { textDocument = vim.lsp.util.make_text_document_params(0),
--       position = { line = vim.fn.line('.') - 1, character = vim.fn.col('.') - 1 } })
-- 只看 insertTextFormat == 2（Snippet）的那些。
--
-- 想加自己的片段：照着下面的格式抄一条，存盘后新开一个 rust buffer 就生效
-- （from_lua 的 lazy_load 按 filetype 加载，改完不用重启 nvim）。
--
-- fmt 的两个坑：
--   1) 占位符是 {}，Rust 自己的花括号必须写成 {{ 和 }} 转义；
--   2) 默认 strict = true，传进去的 insert_node 必须全部用到，否则报错。

local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

return {
  -- pub fn（rust-analyzer 有 fn 但没有带可见性的版本）
  s(
    { trig = 'pubfn', dscr = 'pub fn 函数' },
    fmt(
      [[pub fn {name}({args}) -> {ret} {{
    {body}
}}]],
      { name = i(1, 'name'), args = i(2), ret = i(3, '()'), body = i(4) }
    )
  ),

  -- 带 {:?} 的 println，打结构体/枚举时不用每次手敲格式符
  s(
    { trig = 'pld', dscr = 'println! 调试输出 {:?}' },
    fmt('println!("{{{spec}}}", {args});', {
      spec = i(1, ':?'),
      args = i(2, 'value'),
    })
  ),
}
