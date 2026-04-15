[根目录](../../CLAUDE.md) > [packages](../) > **pptxgenjs**

---

# pptxgenjs

> JavaScript / TypeScript PowerPoint 生成库

**版本**: v4.0.1 | **许可证**: MIT | **类型**: CommonJS + ESM | **构建工具**: Rollup + Gulp

## 模块职责

生成 PowerPoint (.pptx) 文件，支持图表、表格、文本、形状、图片、音频等元素。本包是 OpenMAIC 导出功能 (`lib/export/use-export-pptx.ts`) 的底层依赖，负责将场景内容渲染为可下载的 PPTX 文件。

本包是 [gitbrent/PptxGenJS](https://github.com/gitbrent/PptxGenJS) 的本地 fork，在 OpenMAIC 中以 `workspace:*` 引用。

## 入口文件

- **主模块**: `src/pptxgen.ts`
- **构建输出**: `dist/pptxgen.cjs.js` (CommonJS) / `dist/pptxgen.es.js` (ESM)
- **类型声明**: `types/index.d.ts`
- **核心接口**: `src/core-interfaces.ts`, `src/core-enums.ts`

## 目录结构

```
packages/pptxgenjs/
  src/
    pptxgen.ts           # 主类 PptxGenJS 入口
    slide.ts             # 单个幻灯片类
    core-enums.ts        # 枚举类型
    core-interfaces.ts   # 接口类型
    gen-charts.ts        # 图表生成
    gen-media.ts         # 媒体 (图片/音频/视频) 生成
    gen-objects.ts       # 对象 (形状/线条/表格) 生成
    gen-tables.ts        # 表格生成
    gen-utils.ts         # 通用生成工具
    gen-xml.ts           # XML 生成 (PPTX 内部 XML)
  types/
    index.d.ts           # TypeScript 类型声明 (构建后生成)
  dist/                  # 构建输出 (不提交)
  rollup.config.mjs      # Rollup 配置
  tsconfig.json          # TypeScript 配置
```

## 关键依赖与配置

- **运行时依赖**: `jszip` (PPTX 本质是 ZIP), `image-size` (图片尺寸), `https` (远程图片)
- **开发依赖**: `rollup`, `@rollup/plugin-*`, `typescript`, `gulp`, `express`, `@typescript-eslint/*`
- **构建输出**: CJS + ESM 双格式，通过 Rollup 打包

## 数据模型

PPTX 文件本质上是一个 ZIP 压缩包，包含多个 XML 文件:

- `ppt/presentation.xml` - 演示文稿元数据
- `ppt/slides/slideN.xml` - 每张幻灯片内容
- `ppt/slides/_rels/slideN.xml.rels` - 幻灯片关系
- `ppt/media/imageN.png` - 嵌入图片
- `ppt/charts/chartN.xml` - 图表定义
- `[Content_Types].xml` - 内容类型声明

包的核心类:

- `PptxGenJS` - 主类，管理整个演示文稿
- `Slide` - 单张幻灯片，管理元素添加

## 构建与发布

```bash
pnpm --filter pptxgenjs run build   # Rollup 打包
pnpm --filter pptxgenjs run watch  # 监视模式
pnpm --filter pptxgenjs run ship   # Gulp 发布任务
```

## 测试

- 本包暂无独立测试
- 集成测试通过 OpenMAIC 的 `lib/export/use-export-pptx.ts` 的 E2E 测试覆盖

## 常见问题 (FAQ)

**Q: PPTX 文件无法在 PowerPoint 中打开?**
A: 检查 `[Content_Types].xml` 是否完整，确保所有关系文件正确声明。

**Q: 图片显示为空白?**
A: 确认图片已通过 `addImage()` 添加到媒体池，并通过 `image` 属性引用正确的 `mediaIdx`。

**Q: 如何支持数学公式?**
A: 通过 `lib/export/latex-to-omml.ts` 将 LaTeX 转为 OMML XML，再嵌入 PPTX。

**Q: 与 pptxgenjs 官方库的区别?**
A: OpenMAIC 使用本地 fork 版本 (`workspace:*`)，可自由修改以适配项目需求。

## 相关文件清单

| 文件 | 用途 |
|------|------|
| `src/pptxgen.ts` | PptxGenJS 主类 |
| `src/slide.ts` | Slide 幻灯片类 |
| `src/core-interfaces.ts` | 接口定义 |
| `src/core-enums.ts` | 枚举定义 |
| `src/gen-xml.ts` | XML 生成核心 |
| `src/gen-charts.ts` | 图表元素生成 |
| `src/gen-media.ts` | 媒体元素生成 |
| `src/gen-tables.ts` | 表格元素生成 |
| `src/gen-objects.ts` | 形状/线条生成 |
| `src/gen-utils.ts` | 通用工具函数 |
| `types/index.d.ts` | TypeScript 类型声明 |

## 在 OpenMAIC 中的使用

```
lib/export/use-export-pptx.ts
  -> 导入 pptxgenjs (workspace:*)
     -> 创建 PptxGenJS 实例
        -> 添加幻灯片、文本、图片、表格、图表
           -> 插入 OMML 数学公式 (来自 mathml2omml)
              -> 调用 slide.addSlide() 和 pptx.writeFile()
                 -> 生成 .pptx 文件供用户下载
```

## 变更记录 (Changelog)

- **2026-04-15** 首次生成模块文档
