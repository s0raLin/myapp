# Shared 组件文档

`lib/components/Shared/index.dart` 是项目里的通用 UI 组件集合，主要负责统一页面中的卡片、标题、封面、空状态和媒体列表样式。

## 组件清单

### `AppSectionHeader`

用于页面区块标题。

- 必填参数：`title`
- 可选参数：`subtitle`、`action`
- 适用场景：首页分组标题、用户页模块标题、列表区块头部

示例：

```dart
AppSectionHeader(
  title: '最近播放',
  subtitle: '按最近一次播放时间排序',
  action: TextButton(
    onPressed: () {},
    child: const Text('查看全部'),
  ),
)
```

### `AppPanel`

统一卡片容器，封装了圆角、边框、底色和点击反馈。

- 必填参数：`child`
- 可选参数：`padding`、`onTap`、`color`、`borderRadius`
- 适用场景：设置项容器、信息卡片、承载自定义布局的基础面板

建议：

- 默认用它承载业务内容，而不是每个页面各写一套 `Card`
- 如果内容本身已经有内边距，可以通过 `padding` 调整

### `ArtworkCover`

用于展示专辑封面、歌单封面或占位图。

- 必填参数：`fallbackIcon`
- 可选参数：`bytes`、`borderRadius`、`size`、`aspectRatio`、`iconSize`、`overlay`、`gradientColors`
- 适用场景：音乐封面、歌单封面、用户自定义图片占位

行为说明：

- `bytes` 有内容时显示真实图片
- `bytes` 为空时显示渐变背景和 `fallbackIcon`
- `overlay` 适合叠加播放按钮、遮罩或文本信息

### `MediaGridCard`

用于网格化媒体卡片展示，是当前项目里使用最广泛的列表卡片。

- 必填参数：`title`、`subtitle`、`fallbackIcon`
- 常用可选参数：`coverBytes`、`onTap`、`badge`、`trailing`、`width`、`coverAspectRatio`、`textLayout`
- 文本布局：
  - `MediaGridCardTextLayout.below`：封面下方显示标题和副标题
  - `MediaGridCardTextLayout.overlay`：文字叠加在封面底部

适用场景：

- 首页推荐卡片
- 专辑/歌单网格
- 文件页中的相册卡片

建议：

- 网格列表优先使用 `below`
- Banner、精选内容、视觉优先区域可以用 `overlay`

### `SongListCardTile`

用于纵向歌曲列表项。

- 必填参数：`title`、`subtitle`、`fallbackIcon`
- 可选参数：`coverBytes`、`onTap`、`trailing`、`highlighted`
- 适用场景：歌曲列表、最近播放、播放队列

行为说明：

- `highlighted: true` 时会使用更明显的容器颜色，适合当前播放项

### `QuickActionCard`

用于入口型操作卡片。

- 必填参数：`title`、`icon`
- 可选参数：`subtitle`、`onTap`
- 适用场景：用户页快捷入口、功能导航、工具面板

建议：

- 标题尽量短，副标题一句话内
- 适合成组展示，通常两列或三列布局效果更好

### `AppToast`

用于全局短消息提示，视觉风格参考 Android 上的 Material 3 浮层 Toast。

- 常用入口：`AppToast.show`、`AppToast.success`、`AppToast.warning`、`AppToast.error`
- 必填参数：`message`
- 可选参数：`title`、`tone`、`duration`
- 适用场景：轻量操作反馈、失败提示、开发中功能占位提示

示例：

```dart
AppToast.success(
  context,
  title: '已保存',
  message: '歌单信息已经更新',
);
```

建议：

- 只用于短反馈，不承载需要用户确认的关键操作
- 文案尽量控制在两行内，避免遮挡主界面
- 页面里优先调用 `AppToast`，不要再分散直接写 `SnackBar`

### `AppEmptyState`

普通布局下的空状态组件。

- 必填参数：`icon`、`title`、`subtitle`
- 可选参数：`action`、`padding`、`compact`
- 适用场景：列表为空、搜索无结果、未授权/未导入数据

### `AppEmptySliver`

`Sliver` 版本空状态，适用于 `CustomScrollView`。

- 必填参数：`icon`、`title`、`subtitle`
- 可选参数：`action`、`hasScrollBody`、`padding`、`compact`
- 适用场景：`CustomScrollView`、`NestedScrollView` 页面中的空态填充

## 项目中的典型用法

- `HomePage`：使用 `AppSectionHeader` 和 `MediaGridCard`
- `UserProfilePage`：使用 `AppSectionHeader`、`AppPanel`、`QuickActionCard`
- `LibraryTab` / `RecentlyPlayedPage`：使用 `SongListCardTile`
- `FilesPage`：使用 `MediaGridCard`、`AppEmptyState`
- 操作反馈：使用 `AppToast`

## 测试内演示

演示效果放在测试文件中，不接入正式路由，避免把组件调试入口混入业务页面。

- 文件：`test/shared/shared_widgets_test.dart`
- 演示容器：`_SharedDemoPage`

测试内演示包含：

- 标题区块示例
- 通用卡片和封面占位示例
- `MediaGridCard` 的 `below` / `overlay` 两种布局
- `SongListCardTile` 高亮与普通态
- `QuickActionCard` 入口卡片
- `AppToast` 浮层提示
- `AppEmptyState` 与 `AppEmptySliver`

## 测试说明

已新增 widget test：

- 文件：`test/shared/shared_widgets_test.dart`

覆盖内容：

- `AppSectionHeader` 文本与操作区渲染
- `ArtworkCover` 无封面时的 fallback 图标
- `MediaGridCard` overlay 模式渲染
- `AppEmptySliver` 在 `CustomScrollView` 中的展示
- `AppToast` 的 overlay 渲染
- 测试内 `_SharedDemoPage` 的渲染与 Toast 触发入口

运行：

```bash
flutter test test/shared/shared_widgets_test.dart
```
