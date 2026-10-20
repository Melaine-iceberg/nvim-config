-- 补全菜单第一列（label）的画法。
--
-- 起因：rust-analyzer 的补全项把参数缩成了省略号占位——
--   label            = "insert_mut(… )"
--   labelDescription = "pub fn insert_mut(&mut self, index: usize, element: T) -> &mut T"
-- 真实参数名就躺在 labelDescription 那张签名里，只是 blink 默认照着 label 原样画，
-- 于是菜单第一列只剩下没有信息量的 "(… )"。这里把签名里的括号那段抠出来填回去，
-- 得到 "insert_mut(&mut self, index: usize)"。
--
-- 返回类型也一起接在第一列末尾（"… -> &mut T"）。以前它是右列那块灰色文本，
-- 现在只留一列：菜单更窄，读一条补全只需要从左往右扫一遍，不用眼睛左右跳。
--
-- 两处细节：
--   1. 参数按"完整参数"截断，不会把一个参数拦腰切一半；超长时在末尾补 ", …"。
--   2. 语法高亮必须拿"补全后的整段"去解析 —— 只喂函数名的话，treesitter 会把它
--      当成一个普通变量（@variable），函数名就丢了本该有的颜色；带上括号参数和
--      "-> 返回类型"才会被识别成函数 / 类型，颜色才跟正文对得上。
--
-- 只在 Rust 里用：别的语言（返回类型写在前面的那种）不在这里做兼容。
-- 挂载点见 init.lua 的 completion.menu.draw.components.label。

local M = {}

--- 整行（名字 + 参数 + 返回类型 + 来源标注）最多占多少列。
--- 和 init.lua 里 label 组件的 width.max 是同一个数，那边直接引用这里，别改两处。
M.max_width = 64

--- 参数表再挤也至少留这么多列，免得函数名特别长时参数一个都不剩
M.min_param_width = 12

--- 参数表能占多少列 = 整行上限 - 已经占掉的部分（名字 + 两个括号 + 返回类型 + 标注）。
--- 之前这里是个死数（30 列），不管右边还剩多少空位，超过 30 就截 ——
--- 于是短签名后面明明还有一大截空白也照样出省略号。
---@param name string 函数名
---@param fixed_width integer 返回类型 / 来源标注这些已经确定要占的列数
---@return integer
function M.budget(name, fixed_width)
  local used = vim.api.nvim_strwidth(name) + 2 + fixed_width
  return math.max(M.max_width - used, M.min_param_width)
end

--- 从一张完整签名里抠出参数表。
---
--- 不能简单地取"第一个括号"或"最后一个括号"：签名里括号不止一处——
---   泛型约束  map<F: Fn(i32) -> (i32, i32)>(self, f: F)   ← Fn(...) 里有括号
---   返回值    -> (T, bool)                               ← 返回元组也有括号
--- 所以先跳过名字后面的 <...>，再从第一个"真正在顶层"的 '(' 开始配对。
--- 跳过尖括号时要小心 "->"：那个 '>' 不是闭合尖括号，得整体吃掉，
--- 否则计数会提前归零，后面的括号判断全乱。
---@param sig string 完整签名，例如 "pub fn add(a: i32, b: i32) -> i32"
---@param name string 函数名，例如 "add"
---@return string? 参数表（不含括号）；签名里找不到这个名字时返回 nil
---@return integer? 参数表结尾那个 ')' 的位置，给 M.ret() 接着切返回类型用
function M.params(sig, name)
  if sig == '' or name == '' then return nil end

  local i = sig:find(name, 1, true)
  if not i then return nil end
  i = i + #name

  local angle = 0
  while i <= #sig do
    local c = sig:sub(i, i)
    if c == '-' and sig:sub(i + 1, i + 1) == '>' then
      i = i + 1 -- "->"：连 '>' 一起跳过
    elseif c == '<' then
      angle = angle + 1
    elseif c == '>' then
      angle = angle - 1
    elseif c == '(' and angle <= 0 then
      break
    end
    i = i + 1
  end

  local depth, start = 0, nil
  for j = i, #sig do
    local c = sig:sub(j, j)
    if c == '(' then
      depth = depth + 1
      if depth == 1 then start = j end
    elseif c == ')' then
      depth = depth - 1
      if depth == 0 then return sig:sub(start + 1, j - 1), j end
    end
  end
  return nil
end

--- 把参数表压到 limit 列以内，只在参数之间下刀。
--- 例如 limit = 24 时：
---   "&mut self, index: usize, element: i32"  →  "&mut self, index: usize, …"
--- 而不是拦腰截成 "&mut self, index: us…"。
--- limit 是硬上限：末尾的 ", …" 也算在里面。
---@param params string
---@param limit integer
---@return string
function M.shorten(params, limit)
  limit = limit or M.max_width
  if vim.api.nvim_strwidth(params) <= limit then return params end

  -- 要截断了，先把末尾 ", …" 这 3 列扣出来，免得输出比 limit 还宽
  local room = math.max(limit - 3, 1)

  -- 按顶层逗号切开（括号 / 尖括号 / 方括号里的逗号不算分隔符）。
  -- 用 while 而不是 for：遇到 "->" 要一次吃掉两个字符，for 改不动循环变量。
  local parts, depth, start, i = {}, 0, 1, 1
  while i <= #params do
    local c = params:sub(i, i)
    if c == '-' and params:sub(i + 1, i + 1) == '>' then
      i = i + 2 -- "->" 整体跳过，里头的 '>' 不是闭合尖括号
    else
      if c == '(' or c == '<' or c == '[' then
        depth = depth + 1
      elseif c == ')' or c == '>' or c == ']' then
        depth = depth - 1
      elseif c == ',' and depth <= 0 then
        parts[#parts + 1] = params:sub(start, i) -- 连逗号一起留下
        start = i + 1
      end
      i = i + 1
    end
  end
  parts[#parts + 1] = params:sub(start)

  -- 逐个往里塞，塞不下就停
  local out = ''
  for _, part in ipairs(parts) do
    local candidate = out .. part
    if vim.api.nvim_strwidth(candidate) > room then break end
    out = candidate
  end
  out = out:gsub('[%s,]+$', '')

  -- 一个参数都塞不下（参数名特别长）：退化成硬切
  if out == '' then
    local first = (parts[1]:gsub('[%s,]+$', ''))
    return vim.fn.strcharpart(first, 0, math.max(room - 1, 1)) .. '…'
  end

  return out .. ', …'
end

--- 签名里 ')' 之后那段，就是返回类型。
--- 非函数签名（字段 / 结构体 / 模块……）没有 ')'，调用方会传 nil 进来。
---@param sig string 完整签名
---@param stop integer 参数表结尾 ')' 的位置
---@return string 返回类型（空字符串表示没有）
function M.ret(sig, stop)
  local ret = sig:sub(stop + 1):gsub('^%s+', '')
  -- 签名自带的 "->" 不要，前缀由 render 统一补，免得出现 "-> -> T"
  ret = ret:gsub('^%-+>%s*', '')
  -- 泛型约束（where T: Copy, ...）在文档弹窗里有，这里切掉
  ret = ret:match('^(.-)%s+where%s') or ret
  -- 只写了 where 没写返回类型的（比如 set_var），干脆空着
  if ret:match '^where' then return '' end
  return ret
end

--- 算出这一行长什么样：文本 + 每段的字节区间
---@param ctx blink.cmp.DrawItemContext
---@return { text: string, spans: blink.cmp.DrawHighlight[] }
function M.render(ctx)
  -- "insert_mut(… )" → "insert_mut"
  local name = ctx.label:gsub('%s*%(.*$', '')
  local desc = ctx.label_description or ''
  local params, stop = M.params(desc, name)

  -- 返回类型：接在参数表后面，跟正文里写 "fn f(..) -> T" 的读法一致
  local ret = stop and M.ret(desc, stop) or ''
  local ret_part = ret ~= '' and (' -> ' .. ret) or ''
  local detail_part = #ctx.label_detail > 0 and (' ' .. ctx.label_detail) or ''

  local head = ctx.label
  local params_start -- 参数表从第几列开始；没抠到参数就是 nil（保持原样）
  if params ~= nil then
    -- 参数能占多宽，看这一行还剩多少空位：名字、括号、返回类型、来源标注先扣掉，
    -- 剩下的全给参数。这样只有真的顶到整行上限时才会出现省略号。
    local room = M.budget(
      name,
      vim.api.nvim_strwidth(ret_part) + vim.api.nvim_strwidth(detail_part)
    )
    head = name .. '(' .. M.shorten(params, room) .. ')'
    params_start = #name + 1
  end

  local text = head

  local ret_start, ret_end
  if ret_part ~= '' then
    ret_start = #text
    text = text .. ret_part
    ret_end = #text
  end

  -- label_detail 是 rust-analyzer 给的来源标注，比如 trait 方法的 "(as PartialEq)"
  local detail_start = #text
  text = text .. detail_part
  local detail_end = #text

  -- 片段（snippets 源）没有签名可抠，它的 description 是"这条片段干什么用"的说明。
  -- 右列取消后这层信息会丢，所以直接接在触发词后面，用暗色标出来。
  local desc_start
  if ret == '' and ctx.kind == 'Snippet' and #desc > 0 then
    desc_start = #text
    text = text .. '  ' .. desc
  end

  local spans = {
    { 0, #name, group = ctx.deprecated and 'BlinkCmpLabelDeprecated' or 'BlinkCmpLabel' },
  }
  if params_start then
    -- 参数整段先压成暗色，下面 treesitter 认得的词再盖回各自的颜色
    spans[#spans + 1] = { params_start, #head, group = 'BlinkCmpLabelDescription' }
  end
  if ret_start then
    -- 返回类型同理：先给个中性的底色，类型名交给 treesitter 上色
    spans[#spans + 1] = { ret_start, ret_end, group = 'BlinkCmpLabelDescription' }
  end
  if detail_end > detail_start then
    spans[#spans + 1] = { detail_start, detail_end, group = 'BlinkCmpLabelDetail' }
  end
  if desc_start then
    spans[#spans + 1] = { desc_start, #text, group = 'BlinkCmpLabelDescription' }
  end

  -- 语法高亮：喂给 treesitter 的是一段"能真正解析成函数"的文本。
  -- 为什么不直接喂 "名字(参数) -> T"：rust 里那不是函数定义，解析器会把 Vec 既标成
  -- @variable 又标 @type，泛型参数 T 还会被标成 @constant（颜色跳出来很乱），
  -- '->' 也落到 @operator 上。前面补一个 "fn " 之后一切正常：
  --   Vec<T, A> 只算 @type，'->' 是 @punctuation.delimiter（暗色），跟正文一致。
  -- 代价是区间整体偏移 3 个字节，补回去时把落在 "fn " 里的区间丢掉。
  if vim.list_contains(ctx.self.treesitter, ctx.source_id) and not ctx.deprecated then
    local ts = require('blink.cmp.completion.windows.render.treesitter')
    local prefix = params ~= nil and 'fn ' or ''
    local feed = prefix .. text:sub(1, ret_end or #head)
    for _, hl in ipairs(ts.highlight { label = feed }) do
      if hl[2] > #prefix then
        spans[#spans + 1] = { math.max(hl[1] - #prefix, 0), hl[2] - #prefix, group = hl.group }
      end
    end
  end

  -- 模糊匹配到的字符最后盖上去，保证看得见
  for _, idx in ipairs(ctx.label_matched_indices) do
    spans[#spans + 1] = { idx, idx + 1, group = 'BlinkCmpLabelMatch' }
  end

  return { text = text, spans = spans }
end

---@param ctx blink.cmp.DrawItemContext
---@return string
function M.text(ctx) return M.render(ctx).text end

---@param ctx blink.cmp.DrawItemContext
---@return blink.cmp.DrawHighlight[]
function M.highlight(ctx) return M.render(ctx).spans end

return M
