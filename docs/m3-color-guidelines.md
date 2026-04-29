# Material 3 设计规范（本项目 / 精细版）

> 本文是“可执行的设计系统规范”：用于约束 **颜色、层级、组件样式、交互状态、深浅色模式与可访问性** 的实现方式。
>
> 目标是：任何新页面/新组件都能 **默认统一**、**自动适配深色**、**换主题色只改 seed**，且不会出现“局部写死颜色导致风格割裂”的问题。

---

## 目录

- [1. 规范范围与优先级](#1-规范范围与优先级)
- [2. 主题权威来源（唯一真相）](#2-主题权威来源唯一真相)
- [3. 总体设计原则](#3-总体设计原则)
- [4. 颜色系统：token 与语义映射](#4-颜色系统token-与语义映射)
- [5. 层级系统：容器、边框、阴影](#5-层级系统容器边框阴影)
- [6. 字体与排版规范（用 TextTheme）](#6-字体与排版规范用-texttheme)
- [7. 组件级规范（逐个组件说明）](#7-组件级规范逐个组件说明)
- [8. 交互与状态层（hover/pressed/focus/disabled）](#8-交互与状态层hoverpressedfocusdisabled)
- [9. 深色模式与动态色策略](#9-深色模式与动态色策略)
- [10. 可访问性（对比度/可点击区域/可读性）](#10-可访问性对比度可点击区域可读性)
- [11. 允许“组件自己配色”的边界](#11-允许组件自己配色的边界)
- [12. 代码模板（可复制）](#12-代码模板可复制)
- [13. Review Checklist（评审清单）](#13-review-checklist评审清单)
- [14. 组件清单补全（输入/选择/反馈/加载）](#14-组件清单补全输入选择反馈加载)
- [15. 语义扩展色（Success/Warning）策略](#15-语义扩展色successwarning策略)
- [16. 响应式与密度（手机/桌面）](#16-响应式与密度手机桌面)
- [17. 迁移与落地流程（从旧配色到新规范）](#17-迁移与落地流程从旧配色到新规范)

---

## 1. 规范范围与优先级

### 1.1 适用范围

- **所有 Flutter UI**：页面、组件、弹窗、底部面板、播放器控件、列表项、空状态等。
- **所有主题模式**：浅色/深色；未来如接入动态颜色（Android 12+）也应保持一致逻辑。

### 1.2 冲突时的优先级（从高到低）

1. **Flutter M3 组件默认行为 + 主题（ThemeData/ColorScheme/TextTheme）**
2. **本规范文档**
3. 单页临时覆盖（尽量避免；必须写清楚理由，并能证明不会破坏深色/换 seed）

---

## 2. 主题权威来源（唯一真相）

本项目主题由 `ThemeProvider` 构建，关键事实：

- `useMaterial3: true`
- `ColorScheme.fromSeed(seedColor, brightness, dynamicSchemeVariant: tonalSpot)`
- 项目中已对常见组件（如 `AppBarTheme`、`ListTileTheme`、`NavigationBarTheme`、`CardTheme` 等）做了全局一致化。

因此：**任何页面/组件的颜色选择都必须基于语义色**：

- `final cs = Theme.of(context).colorScheme;`
- `final tt = Theme.of(context).textTheme;`

### 2.1 强制禁止（全局）

- **禁止**：页面/组件里直接使用 `Colors.*` 做“主视觉”（背景/文字/按钮主色等）
- **禁止**：使用 `withOpacity()`（应改为 `.withValues(alpha: ...)`）
- **禁止**：为了“更鲜艳”在局部组件自定义 `primary/secondary` 的固定值

> 允许 `Colors.transparent`（透明本身不是“配色”），也允许极少数品牌色（见第 11 节）。

---

## 3. 总体设计原则

### 3.1 用“语义”而不是“色值”

- 你在代码里表达的应该是“这是一个**次要文字**”，而不是“它是灰色”。
- 语义色（如 `onSurfaceVariant`）会在深色/浅色、不同 seed 下自动调整。

### 3.2 用“容器层级”而不是“阴影”

M3 倡导通过容器色层级（`surfaceContainer*`）建立层次，而不是到处加 elevation。

### 3.3 少即是多：组件结构保持简单

- 优先组合：`Card.filled` + `ListTile` + `Padding` + `Row/Column`
- 避免：过多自绘、过多渐变、堆叠多个装饰层导致维护困难

---

## 4. 颜色系统：token 与语义映射

> 这一节的目标：你在实现任何 UI 时，都能“查表”得到正确的 `ColorScheme` 用法。

### 4.1 颜色 token 分组（记忆法）

- **Surface 系列**：背景/容器/层级（最常用）
- **OnSurface 系列**：文字/图标（可读性）
- **Primary/Secondary/Tertiary 系列**：强调/动作/选中态
- **Outline 系列**：分割线、边框
- **Error 系列**：错误/危险操作
- **Scrim/Shadow**：遮罩/阴影语义（尽量少用 shadow）

### 4.2 页面与背景（Scaffold / 大面积底色）

- **页面背景**：`cs.surface`
- **二级页面背景**（需要一点层级，但不想用卡片）：`cs.surfaceContainerLow`

### 4.3 容器（Card / Section / Panel）

优先从低到高建立层级（按使用频率推荐）：

- `cs.surfaceContainerLow`：轻量卡片/列表项容器
- `cs.surfaceContainer`：信息卡、播放器面板、设置分区
- `cs.surfaceContainerHigh`：需要更明显的抬升层级（少量）
- `cs.surfaceContainerHighest`：控件的 inactive 轨道/更明显分区（少量）

### 4.4 文字与图标（可读性）

- 主文本：默认不指定颜色（跟随 `TextTheme`）
- 次要说明：`cs.onSurfaceVariant`
- 最弱提示：`cs.onSurfaceVariant.withValues(alpha: 0.7)`（尽量少用，优先用字号/布局表达层级）
- 反色文本（放在 primary 容器上）：`cs.onPrimary` / `cs.onPrimaryContainer`

### 4.5 分割线与描边

- 细分割线（推荐）：`cs.outlineVariant`
- 强调边框：`cs.outline`

### 4.6 遮罩与叠层

- 图片/视频上的可读性遮罩：`cs.scrim.withValues(alpha: 0.4 ~ 0.7)`
- 禁止用 `Colors.black45` 当“万能遮罩”

### 4.7 交互强调色（选中/主要操作）

- `cs.primary`：主要操作、选中态、进度 active
- `cs.secondary`：次级强调
- `cs.tertiary`：第三层强调

> 具体选用以“表达语义”为准，不以“好看”为准。

---

## 5. 层级系统：容器、边框、阴影

### 5.1 阴影（elevation）的规则

- 默认 **0**（本项目 `cardTheme` 已设为 `elevation: 0`）
- 只有当“层级关系无法用容器色表达”时才使用 elevation（例如浮层/菜单/对话框）
- 不要在列表项 Card 上加阴影来“显眼”，那会破坏整体一致性

### 5.2 圆角（shape）的建议值（与现有页面一致）

- 小控件/列表项：12
- 普通卡片：16
- 快捷入口/中卡片：20
- 大卡片/头图容器：24

> 圆角不要在同一页面出现 6、14、18、22 这种“随机数”，应使用以上阶梯。

### 5.3 间距（spacing）建议值

- 页面左右边距：16
- 卡片内边距：16 或 20
- 列表项间距：6 ~ 12（按密度）
- 分区标题到内容：12 ~ 16

---

## 6. 字体与排版规范（用 TextTheme）

### 6.1 原则

- 默认使用 `tt.*`，避免手写 `TextStyle(fontSize: ...)`。
- 需要“更强调”时，优先 **提高字重（w600/w700）** 而不是改颜色。

### 6.2 推荐映射（常见场景）

- 页面标题：`tt.titleLarge`（必要时 `copyWith(fontWeight: FontWeight.w700)`）
- 分区标题：`tt.titleMedium` / `tt.titleLarge`
- 列表标题：`tt.titleMedium` 或 `tt.bodyLarge`
- 次要描述：`tt.bodyMedium` + `cs.onSurfaceVariant`
- 标签/按钮小字：`tt.labelLarge` / `tt.labelMedium`

---

## 7. 组件级规范（逐个组件说明）

> 这里的规则是“默认应该怎么做”。如果你要偏离，必须能说明理由，并验证深色/换 seed 不破。

### 7.1 Scaffold / 页面骨架

- 背景默认 `cs.surface`
- 不要在页面里随意设置 `backgroundColor` 为固定色

### 7.2 AppBar / SliverAppBar

- 背景、前景色由全局 `AppBarTheme` 控制（已统一）
- 如果要加分割线：用 `cs.outlineVariant.withValues(alpha: 0.6)`
- `scrolledUnderElevation` 建议保持 0（避免滚动时突兀阴影）

### 7.3 Card

- 优先使用 `Card.filled`（容器层级来自 `surfaceContainer*`）
- 一般内容卡：`cs.surfaceContainer` 或 `cs.surfaceContainerLow`
- 列表项卡：`cs.surfaceContainerLow`
- 避免 `Card(elevation: ...)`

### 7.4 ListTile / 列表

- 图标色、内边距、shape 由全局 `ListTileTheme` 统一（已配置）
- 不要在每个 `ListTile` 上单独指定 icon/文字颜色
- `subtitle` 使用 `maxLines: 1` + `ellipsis`，避免布局抖动

### 7.5 Button（Filled/Outlined/Text）

- 颜色交给主题，页面内不要 `styleFrom(backgroundColor: ...)`
- 语义建议：
  - `FilledButton`：主操作（“播放全部”“创建”）
  - `OutlinedButton`：次要操作（“取消”“更多”）
  - `TextButton`：弱操作/链接（“音乐库”）

### 7.6 FAB

- 默认由全局 `floatingActionButtonTheme` 控制
- 不要局部改成固定色

### 7.7 TabBar / NavigationBar / Drawer

- 交给全局主题控制（项目已配置），页面内不应重写颜色

### 7.8 Slider（播放进度 / 音量）

允许局部自定义 `SliderTheme`（因为属于“强交互控件”），但颜色仍应遵循：

- active：`cs.primary`
- inactive：`cs.surfaceContainerHighest`（或 `cs.outlineVariant`）
- 值指示气泡：`cs.primary`（或 `cs.secondary`，按语义）

并且：

- 不使用 `withOpacity()`；用 `.withValues(alpha: ...)`
- 不使用固定 RGB

### 7.9 Dialog / BottomSheet / Menu

- 这些属于“浮层”，允许适度 elevation（但要统一）
- 背景建议：`cs.surfaceContainer`（或默认）
- 分割线/边框：`cs.outlineVariant`

---

## 8. 交互与状态层（hover/pressed/focus/disabled）

### 8.1 原则

- 交互态应该通过 **状态层叠加（state layer）** 表达，而不是换一套颜色。
- 不要在 pressed 时把文字变成“随机深灰”，这会破坏主题一致性。

### 8.2 推荐做法（按钮/可点击卡片）

优先使用 `InkWell`/`InkResponse` 和 Material 默认的 splash/hover。

当确需自定义状态层（例如自绘卡片）：

- hover（桌面端）：alpha 0.08 ~ 0.12
- pressed：alpha 0.10 ~ 0.16
- focus：遵循 Material 默认 focus ring（尽量不自绘）

颜色来源：通常用 `cs.onSurface` 或 `cs.primary` 做轻透明叠层（根据语义决定）。

---

## 9. 深色模式与动态色策略

### 9.1 深色模式必须“自然工作”

以下做法会直接破坏深色模式，禁止：

- `Colors.black45` 作为文本/分割线/遮罩（深色下会不可读或过黑）
- 手写 `Color(0xFFxxxxxx)` 做主要容器色

### 9.2 换主题色的正确方式

只改 seed：

- `ThemeProvider.setSeedColor(color)`

不要在页面里“单点修色”，否则换 seed 后会出现风格割裂。

---

## 10. 可访问性（对比度/可点击区域/可读性）

### 10.1 对比度

- 文本与背景必须保持可读（尤其是 `subtitle`、`hint`、`disabled`）
- 图片上文字必须加遮罩（`scrim`），不要直接白字压在花图上

### 10.2 可点击区域

- IconButton/小按钮保证最小触控尺寸（一般 40x40 或更大）
- 列表项整行可点优先（`ListTile(onTap: ...)`）

### 10.3 信息层级

- 优先用字号/字重/间距体现层级
- 颜色只做“语义区分”（主/次/禁用），不要把同一层级做成彩虹

---

## 11. 允许“组件自己配色”的边界

> “自己配色”并不是“写固定色”。它的含义是：组件内部对语义颜色做最小映射，用于表达组件自身语义。

### 11.1 允许的场景（白名单）

1. **媒体内容组件**（封面、轮播、海报）
   - 允许使用 `scrim` 做可读性遮罩
2. **播放器强交互控件**（Slider/进度条/音量）
   - 允许自定义 `SliderTheme`，颜色使用 `cs.primary` / `cs.surfaceContainerHighest`
3. **错误/危险操作**
   - 使用 `cs.error` / `cs.errorContainer` / `cs.onErrorContainer`
4. **品牌色点缀（极少数）**
   - 只用于 logo/小标签，不能作为页面主背景/按钮主色

### 11.2 禁止的场景（黑名单）

- 页面骨架：`Scaffold/AppBar/Navigation*`
- 常规展示：`ListTile/Card/Text/Icon`
- 按钮大面积重写颜色（除非是“危险操作按钮”，且必须使用 error 语义）

---

## 12. 代码模板（可复制）

### 12.1 统一取色（每个 build 的第一件事）

```dart
final cs = Theme.of(context).colorScheme;
final tt = Theme.of(context).textTheme;
```

### 12.2 容器卡片（推荐）

```dart
return Card.filled(
  color: cs.surfaceContainerLow,
  clipBehavior: Clip.antiAlias,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          child: const Icon(Icons.library_music_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('标题', style: tt.titleMedium)),
      ],
    ),
  ),
);
```

### 12.3 图片遮罩（只用 scrim，不用黑色写死）

```dart
DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        cs.scrim.withValues(alpha: 0.55),
      ],
    ),
  ),
);
```

### 12.4 分割线（outlineVariant）

```dart
Divider(
  height: 1,
  thickness: 1,
  color: cs.outlineVariant.withValues(alpha: 0.6),
);
```

---

## 13. Review Checklist（评审清单）

### 13.1 颜色与主题

- 是否所有主要颜色都来自 `cs`（而非 `Colors.*` / 固定 `Color(0xFF...)`）
- 是否完全避免 `withOpacity()`（改用 `.withValues(alpha: ...)`）
- 是否避免页面内大量 `styleFrom(backgroundColor: ...)` 覆盖按钮
- 深色模式下是否仍可读（尤其 subtitle、hint、divider、overlay）

### 13.2 层级与布局

- 是否优先使用 `surfaceContainer*` 建立层级，而不是 elevation
- 是否使用了统一的圆角阶梯（12/16/20/24）
- 是否使用了统一的间距体系（16 边距、16/20 内边距、合理的 section spacing）

### 13.3 组件语义

- FilledButton 是否只用于主操作
- error 语义是否只用于危险/错误
- 媒体组件是否通过 scrim 保证文字可读

---

## 14. 组件清单补全（输入/选择/反馈/加载）

> 本节补齐第 7 节未逐一覆盖的“常用组件”。原则仍是：**默认吃主题**，只有在“表达语义”或“强交互控件”时才做最小覆盖。

### 14.1 TextField / 输入框（含搜索框）

- **必须**使用主题 `InputDecorationTheme`（本项目已在 `ThemeProvider` 里设置 `filled: true`、`fillColor: surfaceContainerHigh`、圆角 16、边框色 `outlineVariant`）
- 页面/组件层面：
  - 不要手写输入框背景色
  - 不要用固定灰色做 hint
  - 需要提示时，使用 `helperText/errorText`（颜色交给主题）

推荐：

- 普通表单：直接 `TextField(decoration: InputDecoration(...))`
- 搜索：优先使用 `SearchBar`（项目已设置 `searchBarTheme`）

### 14.2 Switch / Checkbox / Radio

- 默认颜色完全交给主题（M3 已对选中/未选中态做了合理对比度）
- **禁止**为“更像 iOS”而写死绿色
- 若需强调危险开关（极少数）：用文案/二次确认，不要把 Switch 变红

### 14.3 Chip（FilterChip / InputChip）

- 语义：
  - FilterChip：用于筛选（可取消）
  - ChoiceChip：用于单选
- 配色：默认吃主题；不要在每个 Chip 上手动指定背景色
- 文本：使用 `tt.labelLarge`，避免把 chip 文本做成 `bodyMedium`

### 14.4 SnackBar / Toast / Banner（反馈组件）

目标：反馈“可见但不刺眼”，并且深色/换 seed 不破。

- 普通提示：建议使用 `surfaceContainerHigh` + `onSurface`
- 错误提示：使用 `cs.errorContainer` + `cs.onErrorContainer`
- **不要**：`Colors.red` 纯红背景 + 白字（深色/浅色下都容易刺眼）

### 14.5 ProgressIndicator（加载态）

- `CircularProgressIndicator`：默认使用 `cs.primary`
- 列表骨架屏：
  - 背景容器：`surfaceContainerLow`
  - 占位条：`surfaceContainerHigh/Highest`（按层级）
- 不要用固定灰色（会破坏深色模式）

### 14.6 Empty State（空状态）

标准结构（推荐一致化）：

- 容器：`Card.filled(color: cs.surfaceContainerLow)`
- 图标：`cs.onSurfaceVariant`
- 文案：`tt.bodyMedium` + `cs.onSurfaceVariant`
- CTA：`FilledButton` 或 `TextButton`（按主次）

### 14.7 Icon / 图标

- 列表类图标默认 `cs.onSurfaceVariant`
- 强调图标（如快捷入口）：放在 `secondaryContainer` 容器里，用 `onSecondaryContainer`
- **不要**：同一页面出现 5 种不同彩色图标（除非是图表/数据可视化）

### 14.8 Avatar / 头像

- 默认：`CircleAvatar(backgroundColor: cs.surfaceContainerHighest)`
- 强调（如用户卡片）：外圈可用 `cs.primary`，内圈保持 surface 容器（避免纯色头像导致视觉过重）
- 网络头像加载失败要有 fallback（Icon），不要显示空白

---

## 15. 语义扩展色（Success/Warning）策略

### 15.1 为什么需要扩展

M3 `ColorScheme` 原生提供 `error` 语义，但 **success/warning** 并非标准字段。项目如果“到处用绿色/黄色”，会破坏统一与深色适配。

### 15.2 当前阶段的约束（不新增全局 token 时）

在不引入额外全局颜色 token 的情况下，规范如下：

- **Success（柔和成功）**：优先使用 `secondaryContainer`（文字/图标用 `onSecondaryContainer`）
- **Warning（柔和警告）**：优先使用 `tertiaryContainer`（文字/图标用 `onTertiaryContainer`）
- **Error（强语义错误）**：使用 `errorContainer/onErrorContainer`

适用：空状态提示、轻量反馈、非阻断提示。

### 15.3 需要“强成功/强警告”的场景（建议后续做全局扩展）

如果出现如下需求：

- 扫描完成/下载完成需要明显“成功绿”
- 权限风险/存储不足需要明显“警告黄”

建议不要在组件里写死色值，而是新增一层统一封装，例如：

- `lib/theme/app_semantic_colors.dart`（或类似位置）
- 给出 `successContainer/onSuccessContainer/warningContainer/onWarningContainer`
- 由 seedColor 推导或按深浅色分别定义，并统一评审

> 本文档目前先不强制落地该文件，只规定：**强语义色必须集中定义，禁止组件私自写死**。

---

## 16. 响应式与密度（手机/桌面）

### 16.1 密度策略

- 手机：信息密度中等（避免拥挤）
- 桌面：允许稍高密度，但保持触控目标不变（因为桌面也可能触屏）

建议：

- 列表项 `contentPadding` 交给全局 `ListTileTheme`，不要每页各自改
- Grid 卡片（如歌单）：优先使用 `SliverGridDelegateWithMaxCrossAxisExtent` 限制最大宽度，保证宽屏不会“超大卡片”

### 16.2 Hover（桌面端）

- hover 高亮必须轻（状态层 alpha 0.08~0.12）
- 不要 hover 时把背景换成完全不同的色块（会显得廉价）

---

## 17. 迁移与落地流程（从旧配色到新规范）

### 17.1 迁移顺序（推荐）

1. **先全局**：确保 `ThemeProvider` 的 `ColorScheme.fromSeed` 与常用 `*Theme` 都正确
2. **再页面骨架**：把 `Scaffold/AppBar/Navigation` 的硬编码清掉
3. **再组件**：逐个清理 `Colors.*`、`withOpacity()`、局部 `styleFrom(...)`
4. **最后微调**：只在“容器层级/排版”层面做收敛，不做“换色值”

### 17.2 PR/评审要求

- 每个 UI PR 必须附带：
  - 深色模式截图（或至少自测确认）
  - 是否新增/修改颜色规则（若有，必须先改本文档）
- 发现新场景无法归类：先在本文档补一条规则，再实现
