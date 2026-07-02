# a_silky_smooth_ui_for_love2d

一个基于 [LÖVE2D](https://love2d.org/) 的 UI 框架，提供平滑动画与键盘导航的 GUI 组件。

A [LÖVE2D](https://love2d.org/)-based UI framework providing GUI components with silky-smooth animations and keyboard navigation.

## 特性 / Features

- **纯键盘交互的焦点导航系统 / Keyboard-Driven Focus Navigation**: 方向键导航 + Enter 激活。 / Intuitive navigation system using arrow keys + Enter to activate.
- **平滑缓动动画 / Smooth Easing Animations**: 适用于选中框、进度条、文本打印动画。 / Applied to the selection box, progress bars, and typewriter text effects.
- **多种 UI 组件开箱即用 / Out-of-the-Box Components**: 多种预建组件开箱即用。 / A variety of pre-built UI elements ready for use.
- **灵活的布局容器 / Flexible Layout Containers**: 网格布局、比例分组布局。 / Grid layouts and proportional group layouts for easy positioning.

## 组件 / Components

| 组件 / Component | 中文说明                                                 | English Description                                                                           |
| :--------------- | :------------------------------------------------------- | :-------------------------------------------------------------------------------------------- |
| `Button`         | 按钮，支持 idle / hover 状态切换                         | Button supporting idle and hover state switching.                                             |
| `Text`           | 文本标签                                                 | Text label.                                                                                   |
| `ProcessBar`     | 进度条，支持键盘左右键调节值 (0-100) 和动画填充          | Progress bar supporting left/right arrow adjustments (0-100) with smooth filling animations.  |
| `Choice`         | 多选项切换器，支持左右箭头导航与逐字打印动画             | Multi-option switcher supporting left/right arrow navigation and a typewriter text animation. |
| `RecordKey`      | 按键录制组件，可录制最多 2 个按键，含等待动画            | Key recording component capable of capturing up to 2 keys, featuring a waiting animation.     |
| `VolumeBar`      | 音量条组合组件 (Text + ProcessBar)                       | Composite component combining `Text` and `ProcessBar` for volume control.                     |
| `GroupBox`       | 比例分组容器，按比例分配子元素宽度                       | Proportional group container that allocates width to child elements based on ratios.          |
| `Container`      | 网格容器，支持上下左右焦点导航，配合选中框动画           | Grid container supporting 4-way focus navigation, integrated with selection box animations.   |
| `Layout`         | 简单布局包装器                                           | A simple layout wrapper.                                                                      |
| `square`         | 选中框，支持 `round` / `square` 两种样式，带惯性缓动动画 | Selection box supporting `round` and `square` styles with inertial easing animations.         |

## 输入模块 / Input Module

- `key/KeyPressing.lua` — 按键处理模块，支持单次触发 + 长按连发，可配置触发延迟和连发间隔。 / Key input processing module. Supports both single-trigger and key-repeat behaviors, with configurable initial delays and repeat intervals.

## 使用方式 / Getting Started

1. 安装 [LÖVE2D](https://love2d.org/) (版本 11.x) / Install [LÖVE2D](https://love2d.org/) (version 11.x).
2. 克隆本仓库 / Clone this repository.
3. 运行 `love .` / Run the project using `love .`

### 键盘操作 / Controls

| 按键 / Key                     | 操作 / Action (ZH) | Action (EN)                     |
| :----------------------------- | :----------------- | :------------------------------ |
| `方向键 / Arrow Keys` / `WASD` | 在容器中移动焦点   | Move focus within the container |
| `Enter`                        | 激活选中组件       | Activate the selected component |
| `Escape`                       | 退出               | Exit                            |
| `F1`                           | 重启               | Restart                         |

## 项目结构 / Project Structure

```
├── main.lua          # 入口，组装 UI 并覆写 love.run / Entry point; assembles UI and overrides love.run
├── key/
│   └── KeyPressing.lua   # 按键输入模块 / Key input module
└── ui/
    ├── Button.lua        # 按钮 / Button
    ├── Choice.lua        # 选项切换器 / Option switcher
    ├── Container.lua     # 网格容器（焦点导航） / Grid container (Focus navigation)
    ├── GroupBox.lua      # 比例分组容器 / Proportional group container
    ├── Layout.lua        # 布局包装器 / Layout wrapper
    ├── ProcessBar.lua    # 进度条 / Progress bar
    ├── RecordKey.lua     # 按键录制 / Key recorder
    ├── Text.lua          # 文本 / Text label
    ├── VolumeBar.lua     # 音量条组合 / Volume bar composite
    └── square.lua        # 选中框动画 / Selection box animation
```
## API 约定 / API Conventions

所有 UI 组件均实现以下标准 API 接口： / All UI components implement the following standard API interface:

- `api_setPos(x, y)` — 设置位置 / Sets the position.
- `api_setSize(w, h)` — 设置大小 / Sets the size.
- `api_getPos()` — 获取位置 / Returns the position.
- `api_getSize()` — 获取大小 / Returns the size.
- `api_getCenterPos()` — 获取中心坐标 / Returns the center coordinates.
- `api_setState(state)` — 设置状态 (`idle` / `hover` / `active`) / Sets the state (`idle` / `hover` / `active`).
- `api_showBorder(r, g, b, a)` — 显示边框 / Renders the bounding border.

## 依赖 / Dependencies

- [LÖVE2D](https://love2d.org/) 11.x
