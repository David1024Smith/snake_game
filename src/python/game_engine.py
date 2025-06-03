#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import random
import math
import json
from enum import Enum
from dataclasses import dataclass, field
from typing import List, Tuple, Dict, Any, Optional, Set
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer, QPointF, QPropertyAnimation, QEasingCurve
from PySide6.QtGui import QColor
from PySide6.QtQml import qmlRegisterType

class Direction(Enum):
    UP = (0, -1)
    DOWN = (0, 1)
    LEFT = (-1, 0)
    RIGHT = (1, 0)

class FoodType(Enum):
    NORMAL = 1
    SPEED_UP = 2
    SPEED_DOWN = 3
    GHOST = 4
    BONUS = 5

class GameState(Enum):
    MENU = "menu"
    READY = "ready"  # 新增状态：准备开始但等待空格键
    PLAYING = "playing"
    PAUSED = "paused"
    GAME_OVER = "game_over"
    MULTIPLAYER_LOBBY = "multiplayer_lobby"
    MAP_EDITOR = "map_editor"
    ACHIEVEMENTS = "achievements"
    LEADERBOARD = "leaderboard"

class GameMode(Enum):
    CLASSIC = "classic"
    MODERN = "modern"
    TIME_ATTACK = "time_attack"
    FREESTYLE = "freestyle"
    MAZE = "maze"
    SURVIVAL = "survival"

class PowerUpType(Enum):
    SPEED_BOOST = "speed_boost"
    SLOW_MOTION = "slow_motion"
    INVINCIBILITY = "invincibility"
    DOUBLE_SCORE = "double_score"
    MAGNET = "magnet"
    TELEPORT = "teleport"
    SHRINK = "shrink"
    FREEZE_TIME = "freeze_time"
    SHIELD = "shield"
    MULTI_FOOD = "multi_food"

class SkillType(Enum):
    DASH = "dash"
    PHASE = "phase"
    BOMB = "bomb"
    HEAL = "heal"
    RADAR = "radar"

@dataclass
class Position:
    x: int
    y: int
    
    def __add__(self, other):
        return Position(self.x + other.x, self.y + other.y)
    
    def __eq__(self, other):
        return self.x == other.x and self.y == other.y

@dataclass
class Food:
    position: Position
    type: str = "normal"
    value: int = 10
    color: str = "#FF0000"
    effect: Optional[str] = None
    lifetime: int = -1  # -1 means permanent
    animation_phase: float = 0.0

@dataclass
class PowerUp:
    position: Position
    type: PowerUpType
    duration: float
    color: str
    effect_strength: float = 1.0
    lifetime: int = 300  # 5 seconds at 60fps

@dataclass
class Obstacle:
    position: Position
    type: str = "wall"
    destructible: bool = False
    health: int = 1

@dataclass
class Player:
    id: int
    name: str
    body: List[Position] = field(default_factory=list)
    direction: Direction = Direction.RIGHT
    next_direction: Direction = Direction.RIGHT
    score: int = 0
    lives: int = 3
    color: str = "#00FF00"
    active_effects: Dict[str, float] = field(default_factory=dict)
    skills: Dict[SkillType, float] = field(default_factory=dict)  # cooldowns
    is_ai: bool = False
    difficulty: int = 1

@dataclass
class Achievement:
    id: str
    name: str
    description: str
    icon: str
    unlocked: bool = False
    progress: int = 0
    target: int = 1
    hidden: bool = False

class GameEngine(QObject):
    """游戏引擎核心类"""
    
    # 信号
    gameStateChanged = Signal(str)
    scoreChanged = Signal(int, int)  # player_id, score
    levelChanged = Signal(int)
    snakePositionsChanged = Signal('QVariant')
    foodPositionsChanged = Signal('QVariant')
    foodPositionChanged = Signal('QVariant')  # 兼容简化版本
    obstaclePositionsChanged = Signal('QVariant')
    gameOverSignal = Signal(int, str)  # score, reason
    achievementUnlocked = Signal(str, str)  # achievement_id, name
    powerUpCollected = Signal(str, int)  # type, player_id
    skillUsed = Signal(str, int)  # skill, player_id
    comboChanged = Signal(int, int)  # combo_count, player_id
    gameDataChanged = Signal()
    ghostModeChanged = Signal(bool)  # 添加幽灵模式变化信号
    livesChanged = Signal(int)  # 添加生命值变化信号
    gridSizeChanged = Signal()  # 添加网格大小变化信号
    gameModeChanged = Signal(str)  # 游戏模式变化信号
    difficultyChanged = Signal(int)  # 难度变化信号
    
    def __init__(self, config_manager=None):
        super().__init__()
        self.config_manager = config_manager
        
        # 设置默认难度，确保总是有有效值
        self._difficulty = 5  # 默认中等难度
        
        # 连接配置管理器的信号
        if self.config_manager:
            self.config_manager.difficultyChanged.connect(self.onDifficultyChanged)
            # 初始化时应用当前难度设置
            self._difficulty = self.config_manager.currentDifficulty
            print(f"GameEngine: Using config difficulty: {self._difficulty}")
        else:
            print(f"GameEngine: Using default difficulty: {self._difficulty}")
        
        # Game state
        self._game_state = GameState.MENU
        self._score = 0
        self._level = 1
        self._lives = 3
        self._game_mode = GameMode.CLASSIC
        
        # Game world
        self.grid_width = 30  # 简化版本默认值
        self.grid_height = 20  # 简化版本默认值
        self.players: List[Player] = []
        self.foods: List[Food] = []
        self.power_ups: List[PowerUp] = []
        self.obstacles: List[Obstacle] = []
        
        # 简化版本的蛇状态
        self._snake_positions = [(15, 10)]  # 中心位置
        self._snake_direction = Direction.RIGHT
        self._next_direction = Direction.RIGHT
        self._snake_growing = 0
        self._food_position = (20, 10)
        
        # Game mechanics - 根据难度计算初始速度
        self._calculate_speed_from_difficulty()
        print(f"GameEngine: Initial speed set to {self.current_speed}ms for difficulty {self._difficulty}")
        self.game_time = 0
        self.combo_multiplier = 1.0
        self.max_combo = 0
        
        # 游戏计时器
        self.game_timer = QTimer()
        self.game_timer.timeout.connect(self.update_game)
        
        # Multiplayer
        self.max_players = 4
        self.current_players = 1
        
        # Statistics
        self.stats = {
            'games_played': 0,
            'total_score': 0,
            'highest_score': 0,
            'total_food_eaten': 0,
            'total_power_ups': 0,
            'total_time_played': 0,
            'achievements_unlocked': 0
        }
        
        # Achievements system
        self.achievements = self._init_achievements()
        self.load_achievements()
        
        # Map editor
        self.custom_maps = []
        self.current_map = "default"
        
        # AI system
        self.ai_players = []
        
        self._init_game_modes()
        
        # 初始化食物
        self._spawn_food()
        print("GameEngine initialized!")

    # Properties
    @Property(str, notify=gameStateChanged)
    def gameState(self):
        return self._game_state.value

    @Property(int, notify=scoreChanged)
    def score(self):
        return self._score

    @Property(int, notify=levelChanged)
    def level(self):
        return self._level

    @Property('QVariant', notify=snakePositionsChanged)
    def snakePositions(self):
        # 兼容简化版本和完整版本
        if hasattr(self, '_snake_positions') and self._snake_positions:
            return [{"x": pos[0], "y": pos[1]} for pos in self._snake_positions]
        elif self.players:
            return [{"x": pos.x, "y": pos.y} for pos in self.players[0].body]
        return []

    @Property('QVariant', notify=foodPositionsChanged)
    def foodPositions(self):
        return [{"x": food.position.x, "y": food.position.y, "type": food.type} for food in self.foods]

    @Property('QVariant', notify=foodPositionChanged)
    def foodPosition(self):
        # 兼容简化版本
        if hasattr(self, '_food_position') and self._food_position:
            return {"x": self._food_position[0], "y": self._food_position[1]}
        elif self.foods:
            return {"x": self.foods[0].position.x, "y": self.foods[0].position.y}
        return {"x": 0, "y": 0}

    @Property('QVariant', notify=obstaclePositionsChanged)
    def obstaclePositions(self):
        return [{"x": obs.position.x, "y": obs.position.y, "type": obs.type} for obs in self.obstacles]

    @Property(int, notify=gridSizeChanged)
    def gridWidth(self):
        return self.grid_width

    @Property(int, notify=gridSizeChanged)
    def gridHeight(self):
        return self.grid_height

    @Property(int)
    def gridSize(self):
        return getattr(self, '_grid_size', 20)

    @Property(bool, notify=ghostModeChanged)
    def ghostMode(self):
        return getattr(self, '_ghost_mode', False)

    @Property(int, notify=livesChanged)
    def lives(self):
        return self._lives

    @Property(str, notify=gameModeChanged)
    def gameMode(self):
        return self._game_mode.value

    @Property(int, notify=difficultyChanged)
    def difficulty(self):
        return self._difficulty

    @Property(int)
    def currentSpeed(self):
        """获取当前游戏速度（毫秒）"""
        return getattr(self, 'current_speed', 200)

    @Property(int)
    def snakeLength(self):
        """获取蛇的长度"""
        return len(self._snake_positions)
    
    @Property(int)
    def foodCount(self):
        """获取已吃食物数量"""
        # 这里假设10分是一个食物
        return self._score // 10

    @Property(int)
    def gameTime(self):
        """获取游戏时间（毫秒）"""
        return self.game_time

    @Property(bool, notify=gameStateChanged)
    def isReady(self):
        """检查游戏是否处于准备状态"""
        return self._game_state == GameState.READY

    # Slots
    @Slot(str, int)
    def setGameMode(self, mode, difficulty):
        """设置游戏模式和难度 - 优化速度设置"""
        print(f"Setting game mode: {mode}, difficulty: {difficulty}")
        
        mode_map = {
            "classic": GameMode.CLASSIC,
            "modern": GameMode.MODERN,
            "time_attack": GameMode.TIME_ATTACK,
            "freestyle": GameMode.FREESTYLE,
            "maze": GameMode.MAZE,
            "survival": GameMode.SURVIVAL
        }
        
        if mode in mode_map:
            self._game_mode = mode_map[mode]
            self.gameModeChanged.emit(self._game_mode.value)
        
        # 设置难度并重新计算速度
        old_difficulty = self._difficulty
        old_speed = getattr(self, 'current_speed', 200)
        self._difficulty = max(1, min(10, difficulty))
        self._calculate_speed_from_difficulty()
        self.difficultyChanged.emit(self._difficulty)
        
        print(f"Mode set: {mode}, difficulty changed from {old_difficulty} to {self._difficulty}")
        print(f"Speed changed from {old_speed}ms to {self.current_speed}ms")
        
        # 如果游戏正在运行，立即更新定时器间隔
        if self._game_state == GameState.PLAYING and self.game_timer.isActive():
            print("Game is running, updating timer interval immediately")
            self.game_timer.stop()
            self.game_timer.start(self.current_speed)
        
        # 根据模式调整网格大小
        if self._game_mode == GameMode.MODERN:
            self.grid_width = 40
            self.grid_height = 25
        elif self._game_mode == GameMode.TIME_ATTACK:
            self.grid_width = 25
            self.grid_height = 15
        else:
            self.grid_width = 30
            self.grid_height = 20
        
        self.gridSizeChanged.emit()

    @Slot()
    def startGame(self):
        """开始游戏"""
        if self._game_state == GameState.READY:
            # 如果已经处于准备状态，按空格键后才真正开始游戏
            print("Starting game from READY state")
            self._game_state = GameState.PLAYING
            self.game_timer.start(self.current_speed)
        else:
            # 刚进入游戏界面，进入准备状态
            print(f"Entering READY state. Mode: {self._game_mode.value}, difficulty: {self._difficulty}")
            self._game_state = GameState.READY
            # 重置蛇的位置到中心
            self._snake_positions = [(self.grid_width // 2, self.grid_height // 2)]
            # 重置方向
            self._snake_direction = Direction.RIGHT
            self._next_direction = Direction.RIGHT
            # 生成食物
            self._spawn_food()
        
        # 发送状态变化信号
        self.gameStateChanged.emit(self._game_state.value)
        self.snakePositionsChanged.emit(self.snakePositions)

    @Slot()
    def pauseGame(self):
        """暂停/恢复游戏"""
        if self._game_state == GameState.PLAYING:
            print("Pausing game...")
            self._game_state = GameState.PAUSED
            self.game_timer.stop()
        elif self._game_state == GameState.PAUSED:
            print("Resuming game...")
            self._game_state = GameState.PLAYING
            self.game_timer.start(self.current_speed)
        self.gameStateChanged.emit(self._game_state.value)

    @Slot()
    def resetGame(self):
        """重置游戏"""
        print("Resetting game...")
        self._game_state = GameState.MENU
        self._score = 0
        self._snake_positions = [(self.grid_width // 2, self.grid_height // 2)]
        self._snake_direction = Direction.RIGHT
        self._next_direction = Direction.RIGHT
        self._snake_growing = 0
        
        self.game_timer.stop()
        self._spawn_food()
        
        # 发送信号
        self.gameStateChanged.emit(self._game_state.value)
        self.scoreChanged.emit(0, self._score)
        self.snakePositionsChanged.emit(self.snakePositions)
        self.foodPositionChanged.emit(self.foodPosition)

    @Slot(str)
    def setDirection(self, direction):
        """设置蛇的移动方向，简化逻辑提高响应性"""
        # 非游戏状态不处理输入
        if self._game_state != GameState.PLAYING:
            return
        
        direction_map = {
            "up": Direction.UP,
            "down": Direction.DOWN,
            "left": Direction.LEFT,
            "right": Direction.RIGHT
        }
        
        new_direction = direction_map.get(direction.lower())
        if not new_direction:
            return
        
        # 简化逻辑：直接设置方向，如果有效的话
        if self._is_valid_direction(new_direction):
            self._next_direction = new_direction
            print(f"Direction set to: {direction}")  # 调试信息

    def _is_valid_direction(self, direction: Direction) -> bool:
        """检查方向是否有效（不能反向移动）- 优化版本"""
        # 如果蛇长度小于2，任何方向都有效
        if len(self._snake_positions) < 2:
            return True
        
        # 简化的反向检查：直接比较方向值
        current_dx, current_dy = self._snake_direction.value
        new_dx, new_dy = direction.value
        
        # 如果新方向与当前方向相反，则无效
        return not (current_dx == -new_dx and current_dy == -new_dy)

    def _spawn_food(self):
        """生成食物"""
        if not hasattr(self, 'grid_width') or not hasattr(self, 'grid_height'):
            print("Error: Grid dimensions not set")
            return
        
        if self.grid_width <= 0 or self.grid_height <= 0:
            print(f"Error: Invalid grid dimensions ({self.grid_width}, {self.grid_height})")
            return
        
        print(f"Spawning food in grid: {self.grid_width}x{self.grid_height}")
        
        attempts = 0
        max_attempts = 100
        
        # 确保范围安全
        safe_width = max(5, self.grid_width)
        safe_height = max(5, self.grid_height)
        
        while attempts < max_attempts:
            # 限制在安全范围内生成食物，远离边界1格
            x = random.randint(1, safe_width - 2)
            y = random.randint(1, safe_height - 2)
            
            # 检查是否与蛇身重叠
            if (x, y) not in self._snake_positions:
                self._food_position = (x, y)
                print(f"Food spawned at ({x}, {y})")
                self.foodPositionChanged.emit(self.foodPosition)
                return True
            attempts += 1
        
        # 如果尝试多次仍无法生成，强制选择一个位置
        print("Warning: Could not find free space for food, forcing position")
        # 从中心位置开始搜索
        center_x = safe_width // 2
        center_y = safe_height // 2
        
        for x_offset in range(-5, 6):
            for y_offset in range(-5, 6):
                test_x = (center_x + x_offset) % safe_width
                test_y = (center_y + y_offset) % safe_height
                if (test_x, test_y) not in self._snake_positions:
                    self._food_position = (test_x, test_y)
                    print(f"Forced food spawn at ({test_x}, {test_y})")
                    self.foodPositionChanged.emit(self.foodPosition)
                    return True
        
        # 最后的备选方案：放在(1,1)位置
        self._food_position = (1, 1)
        print("Emergency food placement at (1, 1)")
        self.foodPositionChanged.emit(self.foodPosition)
        return False

    def _init_achievements(self):
        """初始化成就系统"""
        return {
            "first_food": Achievement(
                id="first_food",
                name="第一口食物",
                description="吃到第一个食物",
                icon="🍎"
            ),
            "score_100": Achievement(
                id="score_100",
                name="百分达人",
                description="得分达到100分",
                icon="💯",
                target=100
            ),
            "score_500": Achievement(
                id="score_500",
                name="五百强者",
                description="得分达到500分",
                icon="🏆",
                target=500
            ),
            "length_10": Achievement(
                id="length_10",
                name="长蛇出洞",
                description="蛇身长度达到10节",
                icon="🐍",
                target=10
            ),
            "speed_demon": Achievement(
                id="speed_demon",
                name="速度恶魔",
                description="在最高难度下获得100分",
                icon="⚡",
                target=100
            ),
            "survivor": Achievement(
                id="survivor",
                name="生存专家",
                description="在一局游戏中存活5分钟",
                icon="⏰",
                target=300  # 5 minutes in seconds
            )
        }

    def _init_game_modes(self):
        """初始化游戏模式"""
        self.game_modes = {
            GameMode.CLASSIC: {
                "name": "经典模式",
                "description": "传统贪吃蛇玩法",
                "grid_size": (30, 20),
                "features": ["basic_food", "wall_collision"]
            },
            GameMode.MODERN: {
                "name": "现代模式", 
                "description": "更大地图，更多功能",
                "grid_size": (40, 25),
                "features": ["special_food", "power_ups", "obstacles"]
            },
            GameMode.TIME_ATTACK: {
                "name": "限时模式",
                "description": "在限定时间内获得最高分",
                "grid_size": (25, 15),
                "features": ["time_limit", "bonus_food", "speed_increase"]
            },
            GameMode.FREESTYLE: {
                "name": "自由模式",
                "description": "穿越边界，无限空间",
                "grid_size": (30, 20),
                "features": ["wrap_around", "no_wall_collision"]
            }
        }

    def load_achievements(self):
        """加载成就数据"""
        if self.config_manager:
            saved_achievements = self.config_manager.get_achievements()
            # 处理旧格式（列表）和新格式（字典）
            if isinstance(saved_achievements, list):
                # 如果是列表格式，转换为字典格式
                saved_achievements = {}
            elif isinstance(saved_achievements, dict):
                for achievement_id, data in saved_achievements.items():
                    if achievement_id in self.achievements:
                        self.achievements[achievement_id].unlocked = data.get('unlocked', False)
                        self.achievements[achievement_id].progress = data.get('progress', 0)

    def save_achievements(self):
        """保存成就数据"""
        if self.config_manager:
            achievements_data = {}
            for achievement_id, achievement in self.achievements.items():
                achievements_data[achievement_id] = {
                    'unlocked': achievement.unlocked,
                    'progress': achievement.progress
                }
            self.config_manager.save_achievements(achievements_data)

    def check_achievements(self):
        """检查成就完成情况"""
        # 检查分数相关成就
        for achievement_id in ["score_100", "score_500"]:
            achievement = self.achievements[achievement_id]
            if not achievement.unlocked and self._score >= achievement.target:
                self._unlock_achievement(achievement_id)

        # 检查蛇身长度成就
        length_achievement = self.achievements["length_10"]
        if not length_achievement.unlocked and len(self._snake_positions) >= length_achievement.target:
            self._unlock_achievement("length_10")

        # 检查速度恶魔成就
        speed_achievement = self.achievements["speed_demon"]
        if (not speed_achievement.unlocked and 
            self._difficulty >= 10 and 
            self._score >= speed_achievement.target):
            self._unlock_achievement("speed_demon")

    def _unlock_achievement(self, achievement_id):
        """解锁成就"""
        if achievement_id in self.achievements:
            achievement = self.achievements[achievement_id]
            if not achievement.unlocked:
                achievement.unlocked = True
                self.achievementUnlocked.emit(achievement_id, achievement.name)
                self.save_achievements()
                print(f"Achievement unlocked: {achievement.name}")

    def update_game(self):
        """游戏主循环 - 优化性能和响应性"""
        if self._game_state != GameState.PLAYING:
            return
        
        # 更新蛇的方向（直接使用，无需缓冲区处理）
        self._snake_direction = self._next_direction
        
        # 移动蛇
        head_x, head_y = self._snake_positions[0]
        dx, dy = self._snake_direction.value
        new_head = (head_x + dx, head_y + dy)
        
        # 根据游戏模式处理边界
        if self._game_mode == GameMode.FREESTYLE:
            # 自由模式：穿越边界
            new_head = (new_head[0] % self.grid_width, new_head[1] % self.grid_height)
        else:
            # 其他模式：边界碰撞
            if (new_head[0] < 0 or new_head[0] >= self.grid_width or 
                new_head[1] < 0 or new_head[1] >= self.grid_height):
                self._game_over()
                return
        
        # 检查自身碰撞
        if new_head in self._snake_positions:
            self._game_over()
            return
        
        # 移动蛇头
        self._snake_positions.insert(0, new_head)
        
        # 检查食物碰撞
        if new_head == self._food_position:
            self._score += 10
            self._snake_growing += 1
            self.scoreChanged.emit(0, self._score)
            self._spawn_food()
        else:
            # 如果没有吃到食物且不在生长，移除尾部
            if self._snake_growing > 0:
                self._snake_growing -= 1
            else:
                self._snake_positions.pop()
        
        # 发送位置更新信号
        self.snakePositionsChanged.emit(self.snakePositions)

    def _game_over(self):
        """游戏结束"""
        print(f"Game Over! Final Score: {self._score}")
        self._game_state = GameState.GAME_OVER
        self.game_timer.stop()
        self.gameStateChanged.emit(self._game_state.value)

    def _calculate_speed_from_difficulty(self):
        """根据难度计算初始速度 - 优化版本"""
        # 使用更合理的速度范围：难度1=500ms（很慢），难度10=100ms（较快）
        # 使用线性递减公式：500 - (difficulty-1) * 44.4
        self.base_speed = max(100, 500 - (self._difficulty - 1) * 44)
        self.current_speed = self.base_speed
        print(f"Speed calculated: difficulty={self._difficulty}, speed={self.current_speed}ms")

    def onDifficultyChanged(self, new_difficulty):
        """处理难度变化 - 增强版本"""
        print(f"Difficulty changing from {self._difficulty} to {new_difficulty}")
        self._difficulty = new_difficulty
        self.difficultyChanged.emit(self._difficulty)
        
        # 重新计算速度
        old_speed = getattr(self, 'current_speed', 200)
        self._calculate_speed_from_difficulty()
        
        # 如果游戏正在运行，立即更新定时器间隔
        if self._game_state == GameState.PLAYING and self.game_timer.isActive():
            print(f"Updating game speed from {old_speed}ms to {self.current_speed}ms")
            self.game_timer.stop()
            self.game_timer.start(self.current_speed)
        
        print(f"Difficulty changed to {self._difficulty}, new speed: {self.current_speed}ms")

def register_qml_types():
    """注册QML类型，使GameEngine类可以在QML中使用"""
    # 不使用qmlRegisterType方式，改为使用setContextProperty方式 
    pass 