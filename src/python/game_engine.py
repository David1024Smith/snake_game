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
    PLAYING = "playing"
    PAUSED = "paused"
    GAME_OVER = "game_over"
    MULTIPLAYER_LOBBY = "multiplayer_lobby"
    MAP_EDITOR = "map_editor"
    ACHIEVEMENTS = "achievements"
    LEADERBOARD = "leaderboard"

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
    
    def __init__(self, config_manager=None):
        super().__init__()
        self.config_manager = config_manager
        # Fix: Replace the call to get_game_config with direct access to config properties
        # self.game_config = config_manager.get_game_config()
        
        # Game state
        self._game_state = GameState.MENU
        self._score = 0
        self._level = 1
        self._lives = 3
        
        # Game world
        self.grid_width = 64  # Default value
        self.grid_height = 36  # Default value
        self.players: List[Player] = []
        self.foods: List[Food] = []
        self.power_ups: List[PowerUp] = []
        self.obstacles: List[Obstacle] = []
        
        # Game mechanics
        self.base_speed = 150  # ms between moves
        self.current_speed = self.base_speed
        self.game_time = 0
        self.combo_multiplier = 1.0
        self.max_combo = 0
        
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
        
        # 游戏配置
        self._grid_width = 64
        self._grid_height = 36
        self._grid_size = 20
        self._game_speed = 8
        
        # 蛇的状态
        self._snake_positions = [(32, 18)]  # 中心位置
        self._snake_direction = Direction.RIGHT
        self._next_direction = Direction.RIGHT
        self._snake_growing = 0
        self._ghost_mode = False
        self._ghost_timer = 0
        
        # 食物和障碍物
        self._food_positions = []
        self._obstacle_positions = []
        self._food_types = {}
        
        # 游戏模式和难度
        self._game_mode = "classic"
        self._difficulty_level = 1
        
        # 特殊效果
        self._speed_boost = 1.0
        self._speed_boost_timer = 0
        
        # 计时器
        self.game_timer = QTimer()
        self.game_timer.timeout.connect(self.update_game)
        
        # 统计数据
        self._foods_eaten = 0
        self._time_played = 0
        self._max_length = 1
        
        self.resetGame()
    
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
        return [{"x": pos[0], "y": pos[1]} for pos in self._snake_positions]
    
    @Property('QVariant', notify=foodPositionsChanged)
    def foodPositions(self):
        return [{"x": pos[0], "y": pos[1], "type": self._food_types.get(pos, FoodType.NORMAL.value)} 
                for pos in self._food_positions]
    
    @Property('QVariant', notify=obstaclePositionsChanged)
    def obstaclePositions(self):
        return [{"x": pos[0], "y": pos[1]} for pos in self._obstacle_positions]
    
    @Property(int, notify=gridSizeChanged)
    def gridWidth(self):
        return self._grid_width
    
    @Property(int, notify=gridSizeChanged)
    def gridHeight(self):
        return self._grid_height
    
    @Property(int)
    def gridSize(self):
        return self._grid_size
    
    @Property(bool, notify=ghostModeChanged)
    def ghostMode(self):
        return self._ghost_mode
    
    @Property(int, notify=livesChanged)
    def lives(self):
        return self._lives
    
    # Slots
    @Slot()
    def startGame(self):
        """开始游戏"""
        self._game_state = GameState.PLAYING
        self.game_timer.start(1000 // self._game_speed)
        self.gameStateChanged.emit(self._game_state.value)
    
    @Slot()
    def pauseGame(self):
        """暂停游戏"""
        if self._game_state == GameState.PLAYING:
            self._game_state = GameState.PAUSED
            self.game_timer.stop()
            self.gameStateChanged.emit(self._game_state.value)
        elif self._game_state == GameState.PAUSED:
            self._game_state = GameState.PLAYING
            self.game_timer.start(1000 // int(self._game_speed * self._speed_boost))
            self.gameStateChanged.emit(self._game_state.value)
    
    @Slot()
    def resetGame(self):
        """重置游戏"""
        self._game_state = GameState.MENU
        self._score = 0
        self._level = 1
        self._lives = 3
        
        # 重置蛇的位置
        center_x = self._grid_width // 2
        center_y = self._grid_height // 2
        self._snake_positions = [(center_x, center_y)]
        self._snake_direction = Direction.RIGHT
        self._next_direction = Direction.RIGHT
        self._snake_growing = 0
        self._ghost_mode = False
        self._ghost_timer = 0
        
        # 重置特殊效果
        self._speed_boost = 1.0
        self._speed_boost_timer = 0
        
        # 重置统计
        self._foods_eaten = 0
        self._time_played = 0
        self._max_length = 1
        
        # 清空游戏对象
        self.foods.clear()
        self.power_ups.clear()
        self.obstacles.clear()
        self._food_positions.clear()
        self._obstacle_positions.clear()
        self._food_types.clear()
        
        # 根据模式初始化游戏
        self._init_game_mode(self._game_mode)
        
        # 生成初始食物
        self._spawn_food()
        
        self.game_timer.stop()
        
        # 发送信号
        self.gameStateChanged.emit(self._game_state.value)
        self.scoreChanged.emit(0, self._score)
        self.levelChanged.emit(self._level)
        self.ghostModeChanged.emit(self._ghost_mode)
        self.livesChanged.emit(self._lives)
        snake_positions_var = [{"x": pos[0], "y": pos[1]} for pos in self._snake_positions]
        self.snakePositionsChanged.emit(snake_positions_var)
        self.foodPositionsChanged.emit([{"x": pos[0], "y": pos[1], "type": self._food_types.get(pos, FoodType.NORMAL.value)} 
                for pos in self._food_positions])
        self.obstaclePositionsChanged.emit([{"x": pos[0], "y": pos[1]} for pos in self._obstacle_positions])
    
    @Slot(str)
    def setDirection(self, direction):
        """设置蛇的移动方向"""
        if self._game_state != GameState.PLAYING:
            return
        
        direction_map = {
            "up": Direction.UP,
            "down": Direction.DOWN,
            "left": Direction.LEFT,
            "right": Direction.RIGHT
        }
        
        new_direction = direction_map.get(direction.lower())
        if new_direction and self._is_valid_direction(new_direction):
            self._next_direction = new_direction
    
    @Slot(str, int)
    def setGameMode(self, mode, difficulty):
        """设置游戏模式和难度"""
        self._game_mode = mode
        self._difficulty_level = difficulty
        self._apply_difficulty_settings()
        self._generate_obstacles()
    
    @Slot(int, int)
    def setGridSize(self, width, height):
        """设置网格大小"""
        old_width = self._grid_width
        old_height = self._grid_height
        self._grid_width = max(20, width // self._grid_size)
        self._grid_height = max(15, height // self._grid_size)
        
        if old_width != self._grid_width or old_height != self._grid_height:
            self.gridSizeChanged.emit()
            self.resetGame()
    
    def _is_valid_direction(self, direction: Direction) -> bool:
        """检查方向是否有效（不能反向移动）"""
        if len(self._snake_positions) < 2:
            return True
        
        opposite_directions = {
            Direction.UP: Direction.DOWN,
            Direction.DOWN: Direction.UP,
            Direction.LEFT: Direction.RIGHT,
            Direction.RIGHT: Direction.LEFT
        }
        
        return direction != opposite_directions.get(self._snake_direction)
    
    def _move_snake(self):
        """移动蛇"""
        head_x, head_y = self._snake_positions[0]
        dx, dy = self._snake_direction.value
        
        new_head = (head_x + dx, head_y + dy)
        
        # 处理边界（根据游戏模式）
        if self._game_mode == "freestyle":
            # 自由模式：穿越边界
            new_head = (new_head[0] % self._grid_width, new_head[1] % self._grid_height)
        
        self._snake_positions.insert(0, new_head)
        
        # 如果不需要增长，移除尾部
        if self._snake_growing > 0:
            self._snake_growing -= 1
        else:
            self._snake_positions.pop()
        
        # 发送蛇位置更新信号
        snake_positions_var = [{"x": pos[0], "y": pos[1]} for pos in self._snake_positions]
        self.snakePositionsChanged.emit(snake_positions_var)
    
    def _check_collisions(self) -> bool:
        """检查碰撞"""
        head_x, head_y = self._snake_positions[0]
        
        # 检查边界碰撞（非自由模式）
        if self._game_mode != "freestyle":
            if head_x < 0 or head_x >= self._grid_width or head_y < 0 or head_y >= self._grid_height:
                self._game_over("撞墙了！")
                return True
        
        # 检查自身碰撞（非幽灵模式）
        if not self._ghost_mode and len(self._snake_positions) > 1:
            if (head_x, head_y) in self._snake_positions[1:]:
                self._game_over("咬到自己了！")
                return True
        
        # 检查障碍物碰撞（非幽灵模式）
        if not self._ghost_mode and (head_x, head_y) in self._obstacle_positions:
            self._game_over("撞到障碍物了！")
            return True
        
        return False
    
    def _check_food_collision(self, pos: Position) -> Optional[Food]:
        """检查食物碰撞"""
        for food in self.foods:
            if food.position.x == pos.x and food.position.y == pos.y:
                return food
        return None
    
    def _handle_food_eaten(self, player: Player, food: Food):
        """处理食物被吃"""
        # 增加分数
        score_bonus = int(food.value * self.combo_multiplier)
        player.score += score_bonus
        self._score += score_bonus  # 更新主分数
        
        # 更新连击
        self.combo_multiplier = min(self.combo_multiplier + 0.1, 5.0)
        
        # 应用食物效果
        if food.effect:
            self._apply_food_effect(player, food.effect)
        
        # 移除食物
        self.foods.remove(food)
        
        # 生成新食物
        self._spawn_food()
        
        # 更新统计
        self.stats['total_food_eaten'] += 1
        self.stats['total_score'] += score_bonus
        
        # 检查成就
        self._check_achievements(player)
        
        self.scoreChanged.emit(player.id, player.score)
        self.gameDataChanged.emit()
    
    def _handle_food_eaten_simple(self, food_type):
        """简化的食物处理（单人模式）"""
        # 增加分数
        score_bonus = 10
        if food_type == FoodType.SPEED_UP:
            score_bonus = 15
            self._speed_boost = 1.5
            self._speed_boost_timer = 300
        elif food_type == FoodType.SPEED_DOWN:
            score_bonus = 20
            self._speed_boost = 0.7
            self._speed_boost_timer = 300
        elif food_type == FoodType.GHOST:
            score_bonus = 25
            self._ghost_mode = True
            self._ghost_timer = 300
            self.ghostModeChanged.emit(self._ghost_mode)
        elif food_type == FoodType.BONUS:
            score_bonus = 50
        
        self._score += score_bonus
        self._snake_growing += 1
        self._foods_eaten += 1
        
        # 更新最大长度
        if len(self._snake_positions) > self._max_length:
            self._max_length = len(self._snake_positions)
        
        # 更新游戏速度
        self._update_game_speed()
        
        # 发送分数更新信号
        self.scoreChanged.emit(0, self._score)
        
        print(f"吃到食物！分数: {self._score}, 类型: {food_type}")
    
    def _apply_food_effect(self, player: Player, effect: str):
        """应用食物效果"""
        if effect == "speed_up":
            # 加速效果
            self._speed_boost = 1.5
            self._speed_boost_timer = 300  # 5秒（假设60FPS）
            player.active_effects["speed_boost"] = 5.0
            
        elif effect == "speed_down":
            # 减速效果
            self._speed_boost = 0.7
            self._speed_boost_timer = 300  # 5秒
            player.active_effects["speed_down"] = 5.0
            
        elif effect == "ghost":
            # 幽灵模式
            self._ghost_mode = True
            self._ghost_timer = 300  # 5秒
            player.active_effects["ghost"] = 5.0
            self.ghostModeChanged.emit(self._ghost_mode)
            
        elif effect == "invincibility":
            # 无敌效果
            player.active_effects["invincibility"] = 3.0
            
        elif effect == "double_score":
            # 双倍分数
            player.active_effects["double_score"] = 10.0
            
        elif effect == "magnet":
            # 磁铁效果（吸引食物）
            player.active_effects["magnet"] = 15.0
        
        # 更新游戏速度
        self._update_game_speed()
    
    def _spawn_food(self):
        """生成食物"""
        if len(self._food_positions) >= 3:  # 最多3个食物
            return
        
        # 找一个空位置
        max_attempts = 100
        for attempt in range(max_attempts):
            x = random.randint(2, self._grid_width - 3)
            y = random.randint(2, self._grid_height - 3)
            
            # 检查位置是否被占用（简化版本）
            if ((x, y) not in self._snake_positions and 
                (x, y) not in self._food_positions and 
                (x, y) not in self._obstacle_positions):
                
                food_type = self._get_random_food_type()
                
                # 添加到简化的食物列表
                self._food_positions.append((x, y))
                self._food_types[(x, y)] = food_type
                
                # 同时添加到复杂的食物对象列表（为了兼容性）
                pos = Position(x, y)
                food = self._create_food(pos, food_type)
                self.foods.append(food)
                
                print(f"生成食物在位置: ({x}, {y}), 类型: {food_type}")
                
                # 发送食物位置更新信号
                self.foodPositionsChanged.emit([{"x": pos[0], "y": pos[1], "type": self._food_types.get(pos, FoodType.NORMAL.value)} 
                        for pos in self._food_positions])
                break
        else:
            print("警告: 无法找到合适的位置生成食物")
    
    def _get_random_food_type(self):
        """随机选择食物类型"""
        # 获取当前难度的特殊食物概率
        difficulty_config = self._get_difficulty_config()
        special_food_chance = difficulty_config.get("special_food_chance", 0.1)
        
        # 随机决定是否生成特殊食物
        if random.random() < special_food_chance:
            # 特殊食物类型的概率分布
            special_types = [
                FoodType.SPEED_UP,
                FoodType.SPEED_DOWN,
                FoodType.GHOST,
                FoodType.BONUS
            ]
            return random.choice(special_types)
        else:
            return FoodType.NORMAL
    
    def _create_food(self, pos: Position, food_type: FoodType) -> Food:
        """创建食物对象"""
        food_configs = {
            FoodType.NORMAL: {"value": 10, "color": "#FF6464", "effect": None},
            FoodType.SPEED_UP: {"value": 15, "color": "#64C8FF", "effect": "speed_up"},
            FoodType.SPEED_DOWN: {"value": 20, "color": "#B464FF", "effect": "speed_down"},
            FoodType.GHOST: {"value": 25, "color": "#FFDC64", "effect": "ghost"},
            FoodType.BONUS: {"value": 50, "color": "#FF9864", "effect": None}
        }
        
        config = food_configs.get(food_type, food_configs[FoodType.NORMAL])
        return Food(
            position=pos,
            type=food_type.name.lower(),
            value=config["value"],
            color=config["color"],
            effect=config["effect"],
            lifetime=300 if food_type == FoodType.BONUS else -1  # 奖励食物5秒后消失
        )
    
    def _is_position_occupied(self, pos: Position) -> bool:
        """检查位置是否被占用"""
        # 检查玩家身体
        for player in self.players:
            for body_part in player.body:
                if body_part.x == pos.x and body_part.y == pos.y:
                    return True
        
        # 检查食物
        for food in self.foods:
            if food.position.x == pos.x and food.position.y == pos.y:
                return True
        
        # 检查道具
        for power_up in self.power_ups:
            if power_up.position.x == pos.x and power_up.position.y == pos.y:
                return True
        
        # 检查障碍物
        for obstacle in self.obstacles:
            if obstacle.position.x == pos.x and obstacle.position.y == pos.y:
                return True
        
        return False
    
    def _update_player(self, player: Player):
        """更新单个玩家"""
        # 更新方向
        if self._is_valid_direction_change(player.direction, player.next_direction):
            player.direction = player.next_direction
        
        # 移动蛇头
        head = player.body[0]
        new_head = Position(
            head.x + player.direction.value[0],
            head.y + player.direction.value[1]
        )
        
        # 检查边界（根据游戏模式）
        if self._is_out_of_bounds(new_head):
            if hasattr(self, '_game_mode') and 'no_walls' in self.game_modes.get(self._game_mode, {}).get('features', []):
                # 穿越边界
                new_head = self._wrap_position(new_head)
            else:
                self._handle_collision(player)
                return
        
        # 检查碰撞
        if self._check_collision(new_head, player):
            self._handle_collision(player)
            return
        
        # 移动蛇身
        player.body.insert(0, new_head)
        
        # 检查食物碰撞
        eaten_food = self._check_food_collision(new_head)
        if eaten_food:
            print(f"玩家 {player.id} 吃到食物: {eaten_food.type} 在位置 ({new_head.x}, {new_head.y})")
            self._handle_food_eaten(player, eaten_food)
        else:
            # 没吃到食物，移除尾巴
            if len(player.body) > 1:
                player.body.pop()
        
        # 检查道具碰撞
        collected_power_up = self._check_power_up_collision(new_head)
        if collected_power_up:
            self._handle_power_up_collected(player, collected_power_up)
        
        # 更新技能冷却
        for skill in player.skills:
            if player.skills[skill] > 0:
                player.skills[skill] -= 1/60  # 假设60FPS
    
    def _check_collision(self, pos: Position, player: Player) -> bool:
        """检查碰撞"""
        # 检查是否撞到自己
        if pos in player.body:
            return True
        
        # 检查是否撞到其他玩家
        for other_player in self.players:
            if other_player != player and pos in other_player.body:
                return True
        
        # 检查是否撞到障碍物
        for obstacle in self.obstacles:
            if obstacle.position == pos:
                return True
        
        return False
    
    def _handle_collision(self, player: Player):
        """处理碰撞"""
        if 'invincibility' in player.active_effects:
            return  # 无敌状态
        
        player.lives -= 1
        self._lives -= 1
        self.livesChanged.emit(player.id, player.lives)
        
        if player.lives <= 0:
            # 玩家死亡
            if not player.is_ai:
                self._game_state = GameState.GAME_OVER
                self.gameStateChanged.emit(self._game_state.value)
        else:
            # 重置玩家位置
            self._respawn_player(player)
    
    def _respawn_player(self, player: Player):
        """重生玩家"""
        # 找一个安全的位置
        for _ in range(100):  # 最多尝试100次
            x = random.randint(5, self._grid_width - 6)
            y = random.randint(5, self._grid_height - 6)
            pos = Position(x, y)
            if not self._is_position_occupied(pos):
                player.body = [pos]
                break
    
    def _update_special_effects(self):
        """更新特殊效果"""
        # 更新速度加成
        if self._speed_boost_timer > 0:
            self._speed_boost_timer -= 1
            if self._speed_boost_timer == 0:
                self._speed_boost = 1.0
        
        # 更新幽灵模式
        if self._ghost_timer > 0:
            self._ghost_timer -= 1
            if self._ghost_timer == 0:
                self._ghost_mode = False
                self.ghostModeChanged.emit(self._ghost_mode)
    
    def _update_game_speed(self):
        """更新游戏速度"""
        new_interval = int(1000 / (self._game_speed * self._speed_boost))
        if self.game_timer.interval() != new_interval:
            self.game_timer.setInterval(new_interval)
    
    def _check_level_up(self):
        """检查是否升级"""
        new_level = (self._score // 100) + 1
        if new_level > self._level and new_level <= 10:
            self._level = new_level
            self._apply_difficulty_settings()
            self.levelChanged.emit(self._level)
            self.achievementUnlocked.emit('level_up', f"达到等级 {self._level}!")
    
    def _apply_difficulty_settings(self):
        """应用难度设置"""
        difficulty_config = self._get_difficulty_config()
        self._game_speed = difficulty_config.get("speed", 8)
        
        # 重新生成障碍物
        if self._game_mode == "maze":
            self._generate_obstacles()
    
    def _get_difficulty_config(self) -> Dict[str, Any]:
        """获取当前难度配置"""
        # 这里应该从ConfigManager获取，暂时使用默认值
        default_configs = [
            {"level": 1, "speed": 8, "food_count": 1, "obstacles": 0, "special_food_chance": 0.1},
            {"level": 2, "speed": 10, "food_count": 2, "obstacles": 5, "special_food_chance": 0.15},
            {"level": 3, "speed": 12, "food_count": 2, "obstacles": 10, "special_food_chance": 0.2},
            {"level": 4, "speed": 14, "food_count": 3, "obstacles": 15, "special_food_chance": 0.25},
            {"level": 5, "speed": 16, "food_count": 3, "obstacles": 20, "special_food_chance": 0.3},
            {"level": 6, "speed": 18, "food_count": 4, "obstacles": 25, "special_food_chance": 0.35},
            {"level": 7, "speed": 20, "food_count": 4, "obstacles": 30, "special_food_chance": 0.4},
            {"level": 8, "speed": 22, "food_count": 5, "obstacles": 35, "special_food_chance": 0.45},
            {"level": 9, "speed": 24, "food_count": 5, "obstacles": 40, "special_food_chance": 0.5},
            {"level": 10, "speed": 26, "food_count": 6, "obstacles": 50, "special_food_chance": 0.6}
        ]
        
        for config in default_configs:
            if config["level"] == self._difficulty_level:
                return config
        
        return default_configs[0]
    
    def _game_over(self, reason: str):
        """游戏结束"""
        self._game_state = GameState.GAME_OVER
        self.game_timer.stop()
        
        self.gameStateChanged.emit(self._game_state.value)
        self.gameOverSignal.emit(self._score, reason)
    
    @Slot(result='QVariant')
    def getGameStatistics(self):
        """获取游戏统计信息"""
        return {
            "score": self._score,
            "level": self._level,
            "foods_eaten": self._foods_eaten,
            "time_played": self._time_played,
            "max_length": self._max_length,
            "snake_length": len(self._snake_positions)
        }
    
    def _init_achievements(self) -> Dict[str, Achievement]:
        return {
            'first_game': Achievement('first_game', '初次游戏', '完成第一局游戏', 'trophy', target=1),
            'score_100': Achievement('score_100', '百分达人', '单局得分达到100分', 'star', target=100),
            'score_500': Achievement('score_500', '五百强者', '单局得分达到500分', 'star', target=500),
            'score_1000': Achievement('score_1000', '千分王者', '单局得分达到1000分', 'crown', target=1000),
            'combo_10': Achievement('combo_10', '连击高手', '达成10连击', 'fire', target=10),
            'combo_20': Achievement('combo_20', '连击大师', '达成20连击', 'fire', target=20),
            'power_up_master': Achievement('power_up_master', '道具大师', '收集100个道具', 'magic', target=100),
            'survivor': Achievement('survivor', '生存专家', '在生存模式中存活5分钟', 'shield', target=300),
            'speed_demon': Achievement('speed_demon', '速度恶魔', '在最高速度下得分200分', 'lightning', target=200),
            'multiplayer_winner': Achievement('multiplayer_winner', '多人之王', '赢得10场多人游戏', 'crown', target=10),
            'map_creator': Achievement('map_creator', '地图创造者', '创建5个自定义地图', 'map', target=5),
            'skill_master': Achievement('skill_master', '技能大师', '使用技能100次', 'skill', target=100),
            'perfectionist': Achievement('perfectionist', '完美主义者', '完成所有其他成就', 'diamond', target=1, hidden=True),
        }
    
    def _init_game_modes(self):
        self.game_modes = {
            'classic': {
                'name': '经典模式',
                'description': '传统贪吃蛇游戏',
                'features': ['basic_food', 'walls'],
                'time_limit': None,
                'power_ups': False
            },
            'modern': {
                'name': '现代模式',
                'description': '带有道具和技能的现代版本',
                'features': ['all_food_types', 'power_ups', 'skills', 'combos'],
                'time_limit': None,
                'power_ups': True
            },
            'battle_royale': {
                'name': '大逃杀模式',
                'description': '多人竞技，最后一条蛇获胜',
                'features': ['multiplayer', 'shrinking_map', 'power_ups'],
                'time_limit': None,
                'power_ups': True,
                'multiplayer': True
            },
            'time_attack': {
                'name': '限时挑战',
                'description': '在限定时间内获得最高分',
                'features': ['time_limit', 'bonus_food', 'power_ups'],
                'time_limit': 120,  # 2 minutes
                'power_ups': True
            },
            'survival': {
                'name': '生存模式',
                'description': '食物会消失，考验生存技巧',
                'features': ['disappearing_food', 'increasing_speed', 'power_ups'],
                'time_limit': None,
                'power_ups': True
            },
            'zen': {
                'name': '禅意模式',
                'description': '无边界，放松心情',
                'features': ['no_walls', 'peaceful_music', 'slow_speed'],
                'time_limit': None,
                'power_ups': False
            }
        }
    
    def _init_game_mode(self, mode: str):
        """根据游戏模式初始化"""
        mode_config = self.game_modes.get(mode, self.game_modes['modern'])
        
        if 'walls' in mode_config['features']:
            self._generate_walls()
        
        if 'shrinking_map' in mode_config['features']:
            # 大逃杀模式的缩圈机制
            pass
    
    def _generate_walls(self):
        """生成墙壁"""
        # 边界墙
        for x in range(self._grid_width):
            self._obstacle_positions.append((x, 0))
            self._obstacle_positions.append((x, self._grid_height - 1))
        
        for y in range(self._grid_height):
            self._obstacle_positions.append((0, y))
            self._obstacle_positions.append((self._grid_width - 1, y))
        
        # 随机内部障碍物
        for _ in range(random.randint(5, 15)):
            x = random.randint(5, self._grid_width - 6)
            y = random.randint(5, self._grid_height - 6)
            if (x, y) not in self._snake_positions and (x, y) not in self._food_positions and (x, y) not in self._obstacle_positions:
                self._obstacle_positions.append((x, y))
    
    def _generate_obstacles(self):
        """根据难度和游戏模式生成障碍物"""
        # 清空现有障碍物
        self._obstacle_positions.clear()
        self.obstacles.clear()
        
        # 获取难度配置
        difficulty_config = self._get_difficulty_config()
        obstacle_count = difficulty_config.get("obstacles", 0)
        
        # 根据游戏模式生成不同类型的障碍物
        if self._game_mode == "classic":
            # 经典模式：只有边界墙
            self._generate_boundary_walls()
        elif self._game_mode == "modern":
            # 现代模式：边界墙 + 随机障碍物
            self._generate_boundary_walls()
            self._generate_random_obstacles(obstacle_count)
        elif self._game_mode == "battle_royale":
            # 大逃杀模式：更多障碍物
            self._generate_boundary_walls()
            self._generate_random_obstacles(obstacle_count * 2)
        elif self._game_mode == "time_attack":
            # 限时挑战：中等数量障碍物
            self._generate_boundary_walls()
            self._generate_random_obstacles(obstacle_count)
        elif self._game_mode == "survival":
            # 生存模式：动态障碍物
            self._generate_boundary_walls()
            self._generate_random_obstacles(obstacle_count)
        elif self._game_mode == "zen":
            # 禅意模式：无障碍物
            pass
        
        # 发送障碍物位置更新信号
        self.obstaclePositionsChanged.emit([{"x": pos[0], "y": pos[1]} for pos in self._obstacle_positions])
    
    def _generate_boundary_walls(self):
        """生成边界墙"""
        # 上下边界
        for x in range(self._grid_width):
            self._obstacle_positions.append((x, 0))
            self._obstacle_positions.append((x, self._grid_height - 1))
            
            # 创建障碍物对象
            self.obstacles.append(Obstacle(Position(x, 0), "wall"))
            self.obstacles.append(Obstacle(Position(x, self._grid_height - 1), "wall"))
        
        # 左右边界
        for y in range(1, self._grid_height - 1):  # 避免重复角落
            self._obstacle_positions.append((0, y))
            self._obstacle_positions.append((self._grid_width - 1, y))
            
            # 创建障碍物对象
            self.obstacles.append(Obstacle(Position(0, y), "wall"))
            self.obstacles.append(Obstacle(Position(self._grid_width - 1, y), "wall"))
    
    def _generate_random_obstacles(self, count):
        """生成随机障碍物"""
        attempts = 0
        generated = 0
        max_attempts = count * 10  # 防止无限循环
        
        while generated < count and attempts < max_attempts:
            attempts += 1
            
            # 随机位置（避免边界和蛇的起始位置）
            x = random.randint(3, self._grid_width - 4)
            y = random.randint(3, self._grid_height - 4)
            
            # 检查位置是否可用
            if self._is_obstacle_position_valid(x, y):
                self._obstacle_positions.append((x, y))
                
                # 随机选择障碍物类型
                obstacle_type = random.choice(["wall", "destructible", "moving"])
                destructible = obstacle_type == "destructible"
                
                self.obstacles.append(Obstacle(
                    Position(x, y), 
                    obstacle_type, 
                    destructible=destructible
                ))
                
                generated += 1
    
    def _is_obstacle_position_valid(self, x, y):
        """检查障碍物位置是否有效"""
        # 检查是否与现有障碍物重叠
        if (x, y) in self._obstacle_positions:
            return False
        
        # 检查是否与蛇的位置重叠
        if (x, y) in self._snake_positions:
            return False
        
        # 检查是否与食物位置重叠
        if (x, y) in self._food_positions:
            return False
        
        # 检查是否在蛇的起始区域附近（给蛇留出安全空间）
        center_x, center_y = self._grid_width // 2, self._grid_height // 2
        if abs(x - center_x) <= 2 and abs(y - center_y) <= 2:
            return False
        
        return True
    
    def update_game(self):
        """游戏主循环"""
        if self._game_state != GameState.PLAYING:
            return
        
        self.game_time += 1
        
        # 更新蛇的方向
        self._snake_direction = self._next_direction
        
        # 移动蛇
        self._move_snake()
        
        # 检查碰撞
        if self._check_collisions():
            return
        
        # 检查食物碰撞
        head_x, head_y = self._snake_positions[0]
        if (head_x, head_y) in self._food_positions:
            # 吃到食物
            food_type = self._food_types.get((head_x, head_y), FoodType.NORMAL)
            self._handle_food_eaten_simple(food_type)
            
            # 移除食物
            self._food_positions.remove((head_x, head_y))
            if (head_x, head_y) in self._food_types:
                del self._food_types[(head_x, head_y)]
            
            # 生成新食物
            self._spawn_food()
        
        # 更新特殊效果
        self._update_special_effects()
        
        # 检查升级
        self._check_level_up()
        
        # 更新所有玩家（如果有的话）
        for player in self.players:
            if player.is_ai:
                self._update_ai_player(player)
            self._update_player(player)
        
        # 更新游戏对象
        self._update_foods()
        self._update_power_ups()
        self._update_effects()
        
        # 检查游戏结束条件
        self._check_game_over()
        
        # 随机生成道具
        if random.random() < 0.01:  # 1% 概率
            self._spawn_power_up()
        
        # 更新动画
        for food in self.foods:
            food.animation_phase += 0.1
        
        # 发送信号更新UI
        snake_positions_var = [{"x": pos[0], "y": pos[1]} for pos in self._snake_positions]
        self.snakePositionsChanged.emit(snake_positions_var)
        self.foodPositionsChanged.emit([{"x": pos[0], "y": pos[1], "type": self._food_types.get(pos, FoodType.NORMAL.value)} 
                for pos in self._food_positions])
        self.obstaclePositionsChanged.emit([{"x": pos[0], "y": pos[1]} for pos in self._obstacle_positions])
    
    def _update_ai_player(self, player: Player):
        """更新AI玩家"""
        # 简单的AI逻辑：寻找最近的食物
        if not self.foods:
            return
        
        head = player.body[0]
        nearest_food = min(self.foods, key=lambda f: abs(f.position.x - head.x) + abs(f.position.y - head.y))
        
        # 计算到食物的方向
        dx = nearest_food.position.x - head.x
        dy = nearest_food.position.y - head.y
        
        # 选择最优方向
        if abs(dx) > abs(dy):
            new_direction = Direction.RIGHT if dx > 0 else Direction.LEFT
        else:
            new_direction = Direction.DOWN if dy > 0 else Direction.UP
        
        # 检查是否会撞到自己
        next_pos = head + Position(*new_direction.value)
        if next_pos not in player.body[:-1]:
            player.next_direction = new_direction
    
    def _is_valid_direction_change(self, current: Direction, new: Direction) -> bool:
        """检查方向改变是否有效"""
        opposite_directions = {
            Direction.UP: Direction.DOWN,
            Direction.DOWN: Direction.UP,
            Direction.LEFT: Direction.RIGHT,
            Direction.RIGHT: Direction.LEFT
        }
        return new != opposite_directions.get(current)
    
    def _is_out_of_bounds(self, pos: Position) -> bool:
        """检查位置是否超出边界"""
        return pos.x < 0 or pos.x >= self._grid_width or pos.y < 0 or pos.y >= self._grid_height
    
    def _wrap_position(self, pos: Position) -> Position:
        """边界穿越"""
        return Position(
            pos.x % self._grid_width,
            pos.y % self._grid_height
        )
    
    def _check_power_up_collision(self, pos: Position) -> Optional[PowerUp]:
        """检查道具碰撞"""
        for power_up in self.power_ups:
            if power_up.position == pos:
                return power_up
        return None
    
    def _handle_power_up_collected(self, player: Player, power_up: PowerUp):
        """处理道具收集"""
        # 应用道具效果
        player.active_effects[power_up.type.value] = power_up.duration
        
        # 移除道具
        self.power_ups.remove(power_up)
        
        # 更新统计
        self.stats['total_power_ups'] += 1
        
        self.powerUpCollected.emit(power_up.type.value, player.id)
    
    def _spawn_power_up(self):
        """生成道具"""
        if len(self.power_ups) >= 3:  # 最多3个道具
            return
        
        # 找一个空位置
        for _ in range(50):
            x = random.randint(1, self._grid_width - 2)
            y = random.randint(1, self._grid_height - 2)
            pos = Position(x, y)
            
            if not self._is_position_occupied(pos):
                power_up_type = random.choice(list(PowerUpType))
                power_up = self._create_power_up(pos, power_up_type)
                self.power_ups.append(power_up)
                break
    
    def _create_power_up(self, pos: Position, power_up_type: PowerUpType) -> PowerUp:
        """创建道具"""
        power_up_configs = {
            PowerUpType.SPEED_BOOST: {"duration": 5.0, "color": "#00FFFF"},
            PowerUpType.SLOW_MOTION: {"duration": 8.0, "color": "#8000FF"},
            PowerUpType.INVINCIBILITY: {"duration": 3.0, "color": "#FFFF00"},
            PowerUpType.DOUBLE_SCORE: {"duration": 10.0, "color": "#FFD700"},
            PowerUpType.MAGNET: {"duration": 15.0, "color": "#FF69B4"},
            PowerUpType.TELEPORT: {"duration": 1.0, "color": "#9400D3"},
            PowerUpType.SHRINK: {"duration": 5.0, "color": "#32CD32"},
            PowerUpType.FREEZE_TIME: {"duration": 3.0, "color": "#87CEEB"},
            PowerUpType.SHIELD: {"duration": 10.0, "color": "#4169E1"},
            PowerUpType.MULTI_FOOD: {"duration": 20.0, "color": "#FF1493"}
        }
        
        config = power_up_configs.get(power_up_type, {"duration": 5.0, "color": "#FFFFFF"})
        return PowerUp(
            position=pos,
            type=power_up_type,
            duration=config["duration"],
            color=config["color"]
        )
    
    def _update_foods(self):
        """更新食物"""
        # 移除过期的食物
        self.foods = [food for food in self.foods if food.lifetime != 0]
        for food in self.foods:
            if food.lifetime > 0:
                food.lifetime -= 1
    
    def _update_power_ups(self):
        """更新道具"""
        # 移除过期的道具
        self.power_ups = [power_up for power_up in self.power_ups if power_up.lifetime > 0]
        for power_up in self.power_ups:
            power_up.lifetime -= 1
    
    def _update_effects(self):
        """更新效果"""
        for player in self.players:
            expired_effects = []
            for effect, duration in player.active_effects.items():
                player.active_effects[effect] = duration - 1/60
                if player.active_effects[effect] <= 0:
                    expired_effects.append(effect)
            
            for effect in expired_effects:
                del player.active_effects[effect]
    
    def _check_game_over(self):
        """检查游戏结束"""
        alive_players = [p for p in self.players if p.lives > 0]
        if len(alive_players) == 0:
            self._game_state = GameState.GAME_OVER
            self.gameStateChanged.emit(self._game_state.value)
            self._save_high_score()
    
    def _save_high_score(self):
        """保存最高分"""
        if self.players:
            max_score = max(player.score for player in self.players)
            if max_score > self.stats['highest_score']:
                self.stats['highest_score'] = max_score
                self.config_manager.save_stats(self.stats)
    
    def _check_achievements(self, player: Player):
        """检查成就"""
        # 分数成就
        if player.score >= 100 and not self.achievements['score_100'].unlocked:
            self._unlock_achievement('score_100')
        if player.score >= 500 and not self.achievements['score_500'].unlocked:
            self._unlock_achievement('score_500')
        if player.score >= 1000 and not self.achievements['score_1000'].unlocked:
            self._unlock_achievement('score_1000')
        
        # 连击成就
        if self.combo_multiplier >= 2.0 and not self.achievements['combo_10'].unlocked:
            self._unlock_achievement('combo_10')
        if self.combo_multiplier >= 3.0 and not self.achievements['combo_20'].unlocked:
            self._unlock_achievement('combo_20')
    
    def _unlock_achievement(self, achievement_id: str):
        """解锁成就"""
        achievement = self.achievements[achievement_id]
        if not achievement.unlocked:
            achievement.unlocked = True
            self.stats['achievements_unlocked'] += 1
            self.achievementUnlocked.emit(achievement_id, achievement.name)
            self.save_achievements()
    
    def load_achievements(self):
        """加载成就"""
        try:
            with open('achievements.json', 'r', encoding='utf-8') as f:
                data = json.load(f)
                for achievement_id, achievement_data in data.items():
                    if achievement_id in self.achievements:
                        self.achievements[achievement_id].unlocked = achievement_data.get('unlocked', False)
                        self.achievements[achievement_id].progress = achievement_data.get('progress', 0)
        except FileNotFoundError:
            pass
    
    def save_achievements(self):
        """保存成就"""
        data = {}
        for achievement_id, achievement in self.achievements.items():
            data[achievement_id] = {
                'unlocked': achievement.unlocked,
                'progress': achievement.progress
            }
        
        with open('achievements.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    # 游戏控制方法
    def change_direction(self, player_id: int, direction: str):
        """改变玩家方向"""
        if player_id < len(self.players):
            try:
                new_direction = Direction[direction.upper()]
                self.players[player_id].next_direction = new_direction
            except KeyError:
                pass
    
    def use_skill(self, player_id: int, skill: str):
        """使用技能"""
        if player_id >= len(self.players):
            return
        
        player = self.players[player_id]
        try:
            skill_type = SkillType[skill.upper()]
            if player.skills[skill_type] <= 0:  # 技能可用
                self._execute_skill(player, skill_type)
                player.skills[skill_type] = 10.0  # 设置冷却时间
                self.skillUsed.emit(skill, player_id)
        except KeyError:
            pass
    
    def _execute_skill(self, player: Player, skill: SkillType):
        """执行技能"""
        if skill == SkillType.DASH:
            # 冲刺：快速移动3格
            for _ in range(3):
                head = player.body[0]
                new_head = head + Position(*player.direction.value)
                if not self._check_collision(new_head, player):
                    player.body.insert(0, new_head)
                    player.body.pop()
        
        elif skill == SkillType.PHASE:
            # 相位：短暂穿透能力
            player.active_effects["phase"] = 2.0
        
        elif skill == SkillType.BOMB:
            # 炸弹：清除周围障碍物
            head = player.body[0]
            for dx in range(-2, 3):
                for dy in range(-2, 3):
                    pos = Position(head.x + dx, head.y + dy)
                    self.obstacles = [obs for obs in self.obstacles if obs.position != pos or not obs.destructible]
        
        elif skill == SkillType.HEAL:
            # 治疗：恢复生命
            player.lives = min(player.lives + 1, 3)
            self.livesChanged.emit(player.id, player.lives)
        
        elif skill == SkillType.RADAR:
            # 雷达：显示隐藏食物
            player.active_effects["radar"] = 10.0
    
    def pause_game(self):
        """暂停游戏"""
        if self._game_state == GameState.PLAYING:
            self._game_state = GameState.PAUSED
            self.game_timer.stop()
            self.gameStateChanged.emit(self._game_state.value)
    
    def resume_game(self):
        """恢复游戏"""
        if self._game_state == GameState.PAUSED:
            self._game_state = GameState.PLAYING
            self.game_timer.start(self.current_speed)
            self.gameStateChanged.emit(self._game_state.value)
    
    def restart_game(self):
        """重新开始游戏"""
        self.game_timer.stop()
        self.start_game()
    
    def return_to_menu(self):
        """返回主菜单"""
        self.game_timer.stop()
        self._game_state = GameState.MENU
        self.gameStateChanged.emit(self._game_state.value)

# 注册QML类型
def register_qml_types():
    qmlRegisterType(GameEngine, "GameEngine", 1, 0, "GameEngine") 