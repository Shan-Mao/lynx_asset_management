# Lynx 资产管理

> [English](README.md)

基于 Flutter 构建的跨平台个人资产管理工具。追踪你的每一笔消费，一目了然查看**日均成本**。

## 功能特性

### 核心功能
- **日均成本**：自动计算 `(价格 + 附加成本) / 已购买天数`，按成本高低颜色分级
- **资产增删改查**：支持名称、价格、附加成本、购买日期、类别、标签、附加物品、备注等字段
- **资产状态**：可标记为已退役、已卖出、不计入总资产、不计入日均；支持设置到期日期
- **统计概览**：渐变色头部卡片展示资产总数、总价值、日均成本合计

### 界面
- **列表 / 网格布局**：自由切换列表和紧凑网格模式；网格支持配置宽高比（V:V / V:H / H:H）以及横竖屏列数
- **主题**：浅色、深色、跟随系统、AMOLED 纯黑、动态取色（Material You）、自定义种子颜色（RGB/HSV/HSL 滑块）
- **语言**：简体中文 / English，基于语言文件的国际化架构（新增语言只需创建一个 Map 文件）

### 数据管理
- **TXT 导出**：完全可配置——自定义文件命名模板（支持 `{export_date}` 和 `{user_name}` 变量）、可选字段分隔符、按字段勾选导出
- **TXT 导入**：解析导出文件恢复或迁移数据
- **持久化存储**：Android 端使用 `path_provider` 写入本地 JSON 文件；Web 端使用内存临时存储
- **导出格式设置**：独立配置页面，编码、分隔符、导出字段整合在可展开的"内容规则"中

### 个性定制
- **自定义显示名称**：点击编辑，导出时作为 `{user_name}` 使用
- **自定义头像**：16 种预设图标任选，或从相册选取图片，内置交互式 1:1 正方形裁剪编辑器
- **设备识别**：自动检测平台显示 For Android / For Web

### 平台
- **Android**：本地 JSON 文件持久化存储，原生文件保存/分享
- **Web**：支持 GitHub Pages 静态部署，内存临时数据，基于分享的导出

## 技术栈

| 层级 | 选型 |
|------|------|
| 框架 | Flutter 3.44 / Dart 3.12 |
| 状态管理 | Provider + ChangeNotifier |
| 持久化 | 抽象 `StorageService`（移动端 → JSON 文件，Web → 内存） |
| 导出格式 | 自定义结构化 TXT（`===ASSET===` / `===END===` 块） |
| 主题 | Material 3，`ColorScheme.fromSeed()` |
| 国际化 | 静态 Map 文件（`lib/lang/{locale}.dart`） |

## 快速开始

```bash
# Android 模拟器 / 真机运行
flutter run

# Chrome 浏览器运行（Web）
flutter run -d chrome

# 构建 GitHub Pages 部署包
flutter build web --base-href /lynx_asset_management/
```

## 项目结构

```
lib/
├── main.dart                      # 入口，MultiProvider 注册
├── app.dart                       # MaterialApp，主题与语言绑定
├── lang/                          # 国际化：zh.dart, en.dart
├── models/                        # AssetItem 数据模型
├── providers/                     # ChangeNotifier 状态管理
│   ├── asset_provider.dart        # 资产增删改查 + 持久化
│   ├── theme_provider.dart        # 主题模式、颜色
│   ├── locale_provider.dart       # 语言切换
│   ├── layout_provider.dart       # 列表/网格布局设置
│   ├── profile_provider.dart      # 显示名称、头像
│   └── save_format_provider.dart  # 导出格式配置
├── screens/                       # 所有页面
│   ├── home_screen.dart           # 资产列表 + 概览 + 悬浮按钮
│   ├── add_edit_asset_screen.dart # 添加/编辑表单
│   ├── asset_detail_screen.dart   # 资产详情
│   ├── profile_screen.dart        # 个人主页、设置入口
│   ├── settings_screen.dart       # 数据、主题、语言、布局
│   ├── personalization_screen.dart # 设备类型、保存格式、预览
│   ├── save_format_screen.dart    # 命名规则、内容规则、预览
│   ├── theme_screen.dart          # 主题模式标签页
│   ├── seed_color_screen.dart     # 颜色预设 + RGB/HSV/HSL
│   ├── about_screen.dart          # 软件说明
│   ├── image_editor_screen.dart   # 交互式 1:1 裁剪编辑器
│   └── shell_screen.dart          # 底部导航栏容器
├── services/                      # 存储抽象 + 导入导出逻辑
├── utils/                         # 格式化工具、国际化封装、常量
└── widgets/                       # 可复用组件
    ├── asset_card.dart            # 列表卡片
    ├── grid_asset_card.dart       # 网格卡片
    ├── daily_cost_chip.dart       # 日均成本指示器
    ├── summary_header.dart        # 统计概览头部
    └── empty_state.dart           # 空列表占位
```

