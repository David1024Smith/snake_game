# 贪吃蛇游戏 (Snake Game) 🐍
现代化跨平台贪吃蛇游戏，使用 PySide6 和 QML 构建，支持 Windows、macOS、Linux、Android 和 iOS 平台。

## 🎮 游戏特色

- **跨平台支持**: Windows、macOS、Linux、Android、iOS
- **现代化界面**: 使用 QML 技术实现流畅动画和美观界面
- **多种游戏模式**: 经典、现代、限时、自由等多种模式
- **10级难度系统**: 从简单到困难，逐步提升挑战
- **丰富的游戏机制**: 特殊食物、不同游戏玩法
- **数据持久化**: 使用config.toml进行配置
- **优美的UI设计**: 现代化且直观的用户界面

## 🚀 快速开始

### 环境要求

- Python 3.8 或更高版本
- PySide6 6.6.0 或更高版本

### 安装依赖

```bash
pip install -r requirements.txt
```

### 运行游戏

#### Windows
```cmd
start_game.bat
```
或
```cmd
python snake_game_full.py
```

#### Linux/macOS
```bash
./start_game.sh
```
或
```bash
python3 snake_game_full.py
```

## 📦 构建发布版本

本项目提供了多种打包方式，可以根据需求选择：

### 1. 使用简易构建脚本(推荐)

使用cx_Freeze进行构建(Windows)，这是最简单的方式：

```cmd
package_snake.bat
```

这将创建一个完整的可执行文件，位于`build/exe.win-amd64-X.XX/`目录下。

### 2. 统一构建脚本

使用统一构建脚本可以选择构建各种平台：

```bash
cd scripts
python build_all.py
```

该脚本提供交互式菜单，可以选择构建不同平台的版本。

### 3. 各平台专用构建脚本

#### Windows (.exe)
```cmd
cd scripts
build_windows.bat
```

#### macOS (.app)
```bash
cd scripts
./build_macos.sh
```

#### Linux (executable)
```bash
cd scripts
./build_linux.sh
```

#### Android (.apk)
```bash
cd scripts
python build_android.py
```

#### iOS (.ipa)
```bash
cd scripts
python build_ios.py
```
*注意: iOS 构建需要在 macOS 上进行，并需要 Xcode*

### 构建工具对比

| 工具 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| cx_Freeze | 简单易用，生成体积较小 | 仅支持桌面平台 | 简单的桌面应用打包 |
| PyInstaller | 强大的资源打包，可定制性高 | 配置复杂，可能有误报 | 复杂的桌面应用打包 |
| Briefcase | 支持移动平台 | 设置复杂，依赖较多 | 移动平台打包 |

### 构建要求

#### 桌面平台
- **Windows**: Python 3.8+, PyInstaller 或 cx_Freeze
- **macOS**: Python 3.8+, PyInstaller, Xcode (可选)
- **Linux**: Python 3.8+, PyInstaller

#### 移动平台
- **Android**: Python 3.8+, Briefcase, Android SDK
- **iOS**: macOS, Python 3.8+, Briefcase, Xcode, Apple 开发者账号

## 🎯 游戏模式

### 经典模式 (Classic)
传统的贪吃蛇游戏玩法，简单易上手。

### 现代模式 (Modern)
更大的地图，更多的挑战。

### 限时模式 (Time Attack)
在限定时间内获得最高分数的挑战模式。

### 自由模式 (Freestyle)
无边界限制，蛇可以穿越屏幕边缘。

## 🎮 控制方式

- **WASD** 或 **方向键**: 控制蛇的移动
- **空格键**: 开始游戏/暂停游戏
- **R键**: 重新开始游戏
- **ESC键**: 返回主菜单

## ⚙️ 配置文件

游戏使用 `config.toml` 文件进行配置，包含：

- 游戏难度设置
- 游戏模式配置
- 图形和界面设置

## 📁 项目结构

```
snake_game/
├── snake_game_full.py       # 完整的游戏代码（主程序）
├── config.toml              # 游戏配置文件
├── requirements.txt         # Python依赖
├── README.md                # 项目说明
├── start_game.bat           # Windows启动脚本
├── start_game.sh            # Linux/macOS启动脚本
├── package_snake.bat        # 简易构建脚本(cx_Freeze)
├── setup.py                 # cx_Freeze构建配置
├── src/                     # 源代码目录
│   └── qml/                 # QML前端界面
│       ├── main.qml         # 主界面
│       ├── MainMenu.qml     # 主菜单
│       ├── GameView.qml     # 游戏界面
│       ├── GameRenderer.qml # 游戏渲染器
│       ├── ParticleBackground.qml  # 粒子背景
│       ├── SettingsView.qml        # 设置界面
│       ├── HighScoresView.qml      # 高分界面
│       ├── AchievementsView.qml    # 成就界面
│       ├── LeaderboardView.qml     # 排行榜界面
│       ├── GameOverDialog.qml      # 游戏结束对话框
│       ├── AchievementPopup.qml    # 成就提示
│       ├── components/     # 界面组件目录
│       └── styles/         # 样式文件目录
├── assets/                 # 资源文件
│   └── images/            # 图片资源
│       └── icon.ico       # 应用图标
├── scripts/               # 构建脚本
│   ├── build_all.py       # 统一构建脚本
│   ├── build_windows.bat  # Windows构建脚本
│   ├── build_macos.sh     # macOS构建脚本
│   ├── build_linux.sh     # Linux构建脚本
│   ├── build_android.py   # Android构建脚本
│   └── build_ios.py       # iOS构建脚本
└── build/                 # 构建输出目录
    ├── windows/           # Windows构建输出
    ├── macos/             # macOS构建输出
    └── linux/             # Linux构建输出
```

## 🔧 开发说明

### 技术栈
- **前端**: QML + JavaScript
- **后端**: Python 3.8+ + PySide6
- **配置**: TOML 格式
- **打包**: PyInstaller/cx_Freeze (桌面) + Briefcase (移动端)

### 项目设计
本项目采用了一体化设计方案，所有代码都集成在单个Python文件中，同时使用QML文件进行界面设计。这种设计的优点是：

1. **简化部署** - 更容易打包和分发
2. **减少依赖** - 减少文件间依赖关系的复杂性
3. **跨平台一致性** - 确保在所有平台上行为一致

### 开发环境设置

1. 克隆项目
```bash
git clone <repository-url>
cd snake_game
```

2. 创建虚拟环境
```bash
python -m venv venv
source venv/bin/activate  # Linux/macOS
# 或
venv\Scripts\activate     # Windows
```

3. 安装依赖
```bash
pip install -r requirements.txt
```

4. 运行游戏
```bash
python snake_game_full.py
```

## 🐛 故障排除

### 常见问题

1. **ImportError: No module named 'PySide6'**
   ```bash
   pip install PySide6
   ```

2. **构建失败: PyInstaller not found**
   ```bash
   pip install pyinstaller
   ```

3. **构建失败: cx_Freeze not found**
   ```bash
   pip install cx_Freeze
   ```

4. **脚本乱码问题**
   - 请确保脚本文件使用正确的编码格式:
     - Windows批处理文件(.bat): ANSI或UTF-8(无BOM)
     - Shell脚本(.sh): UTF-8(无BOM)
     - Python脚本(.py): UTF-8

5. **构建失败: Icon not found**
   - 确保assets/images/icon.ico文件存在
   - 使用package_snake.bat脚本进行构建(更简单可靠)

6. **QML文件未找到**
   - 确保src/qml目录下的所有QML文件都存在
   - 确保构建后的应用程序可以访问QML文件

### 性能优化

- 如果游戏运行缓慢，可以在代码中降低蛇的移动速度
- 在低配置设备上，建议关闭特效

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

享受游戏！🎮
