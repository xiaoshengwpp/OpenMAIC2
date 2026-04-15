[根目录](../../CLAUDE.md) > [packages](../) > **mathml2omml**

---

# mathml2omml

> MathML 到 Office Math Markup Language (OMML) 的转换器

**版本**: v0.5.0 | **许可证**: LGPL-3.0-or-later | **类型**: CommonJS + ESM | **构建工具**: Rollup

## 模块职责

将 MathML (W3C 数学标记语言) 转换为 Office Math Markup Language (OMML)，使 LaTeX 数学公式能够导出为 PowerPoint 可识别的格式。这是 OpenMAIC 导出功能 (`lib/export/`) 中 LaTeX 渲染链的关键一环: `LaTeX -> MathML -> OMML -> PPTX`。

## 入口文件

- **构建输出**: `dist/index.js` (ESM) / `dist/index.cjs` (CommonJS)
- **类型声明**: `dist/index.d.ts`
- **源入口**: `src/index.js`

## 目录结构

```
packages/mathml2omml/
  src/
    index.js                    # 主入口，导出所有转换函数
    walker.js                   # MathML 树遍历器
    helpers.js                  # 辅助工具函数
    mathml/
      index.js                  # MathML 标签处理器
      math.js                   # <math> 根元素
      menclose.js               # <menclose> 封装
      mfrac.js                  # <mfrac> 分数
      mglyph.js                 # <mglyph> 字形
      mmultiscripts.js          # <mmultiscripts> 多上标
      mroot.js                  # <mroot> 根号
      mrow.js                   # <mrow> 行
      mspace.js                 # <mspace> 空格
      msqrt.js                  # <msqrt> 平方根
      mstyle.js                 # <mstyle> 样式
      msub.js                   # <msub> 下标
      msubsup.js                # <msubsup> 上下标
      msup.js                   # <msup> 上标
      munderover.js             # <munderover> 上下标注
      table.js                  # 表格转换
      text.js                   # 文本节点
      text_container.js         # 文本容器
      text_style.js             # 文本样式
      under_or_over.js          # 上标下标通用逻辑
    ooml/
      index.js                  # OMML 生成器
      nary.js                   # n 元运算符 (求和、积分等)
      scriptlevel.js            # 脚本级别处理
    parse-stringify/
      index.js                  # 解析/序列化入口
      parse-tag.js              # 标签解析
      parse.js                  # MathML 解析器
      stringify.js              # OMML 序列化器
  dist/                          # 构建输出 (不提交)
  rollup.config.js               # Rollup 配置
```

## 关键依赖与配置

- **无运行时依赖** (纯转换工具库)
- **开发依赖**: `@rollup/plugin-node-resolve`, `rollup`, `xml-formatter`, `@biomejs/biome`, `jest`
- **构建**: `rollup -c && node -e "require('fs').copyFileSync(...)"`

## 数据模型

MathML 是 W3C 标准 XML 格式的数学标记语言，包含 30+ 元素标签。

OMML 是 Microsoft Office 的内部数学标记格式，基于 XML。

转换流程:
1. **Parse**: `parse-stringify/parse.js` 将 MathML 字符串解析为 DOM-like 对象树
2. **Walk**: `walker.js` 遍历 MathML 节点树
3. **Convert**: 各 `mathml/` 目录下的处理器将每个 MathML 标签转换为 OMML 等价结构
4. **Stringify**: `parse-stringify/stringify.js` 将 OMML 对象序列化为 XML 字符串

## 测试

- 框架: **Jest**
- 测试文件位置: `node_modules` 内 (子包自带的)
- OpenMAIC 中使用: `lib/export/latex-to-omml.ts` 调用此包的输出

## 常见问题 (FAQ)

**Q: 如何调试 MathML 转换?**
A: 使用 `xml-formatter` 格式化中间 OMML 输出，对比 MathML 输入与 OMML 输出结构。

**Q: 哪些 MathML 标签未支持?**
A: 需检查 `src/mathml/` 目录——若有未列出的标签，则尚未实现转换。

**Q: 与主应用的集成方式?**
A: 在 `lib/export/latex-to-omml.ts` 中调用，流程为: 用户 LaTeX -> `temml` 库转 MathML -> `mathml2omml` 转 OMML -> 插入 PPTX。

## 相关文件清单

| 文件 | 用途 |
|------|------|
| `src/index.js` | 包主入口，导出 `mathml2omml()` 函数 |
| `src/walker.js` | 核心遍历器，驱动整个转换流程 |
| `src/mathml/*.js` | MathML 标签到 OMML 的转换规则 (15 个文件) |
| `src/ooml/*.js` | OMML 结构生成 |
| `src/parse-stringify/*.js` | MathML 解析与 OMML 序列化 |
| `rollup.config.js` | Rollup 打包配置 |
| `dist/index.d.ts` | TypeScript 类型声明 |

## 在 OpenMAIC 中的使用

```
lib/export/latex-to-omml.ts
  -> 调用 mathml2omml (workspace:*)
     -> 转换 MathML -> OMML
        -> 传入 pptxgenjs 插入数学公式
```

## 变更记录 (Changelog)

- **2026-04-15** 首次生成模块文档
