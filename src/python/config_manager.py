#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import toml
import json
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer
from typing import Dict, Any, List
import os

class ConfigManager(QObject):
    """配置管理器，负责读取和管理游戏配置"""
    
    # 信号
    configChanged = Signal()
    difficultyChanged = Signal(int)
    gameModeChanged = Signal(str)
    
    def __init__(self, config_file="config.toml"):
        super().__init__()
        self.config_file = config_file
        self.config = {}
        self._current_difficulty = 5  # 默认难度
        self._current_game_mode = "classic"  # 默认游戏模式
        self._save_data = {}
        
        # 配置文件路径
        self._config_path = Path(__file__).parent.parent.parent / "config.toml"
        self._save_path = Path(__file__).parent.parent.parent / "game_save.json"
        
        self.load_config()
        self.load_save_data()
    
    def get_game_config(self):
        """返回游戏基本配置"""
        return self.config.get("game", {})
    
    def load_config(self):
        """加载配置文件"""
        try:
            if os.path.exists(self.config_file):
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    self.config = toml.load(f)
                print(f"配置文件加载成功: {self.config_file}")
                
                # 加载保存的难度设置
                if 'user_settings' in self.config:
                    self._current_difficulty = self.config['user_settings'].get('difficulty', 5)
                    self._current_game_mode = self.config['user_settings'].get('game_mode', 'classic')
            else:
                print(f"配置文件不存在，使用默认配置: {self.config_file}")
                self.config = self._get_default_config()
                self.save_config()
        except Exception as e:
            print(f"加载配置文件失败: {e}")
            self.config = self._get_default_config()
        
        self.configChanged.emit()
    
    def save_config(self):
        """保存配置文件"""
        try:
            # 确保用户设置部分存在
            if 'user_settings' not in self.config:
                self.config['user_settings'] = {}
            
            # 保存当前难度和游戏模式
            self.config['user_settings']['difficulty'] = self._current_difficulty
            self.config['user_settings']['game_mode'] = self._current_game_mode
            
            with open(self.config_file, 'w', encoding='utf-8') as f:
                toml.dump(self.config, f)
            print(f"配置文件保存成功: {self.config_file}")
        except Exception as e:
            print(f"保存配置文件失败: {e}")
    
    def load_save_data(self):
        """加载游戏存档数据"""
        try:
            if self._save_path.exists():
                with open(self._save_path, 'r', encoding='utf-8') as f:
                    self._save_data = json.load(f)
            else:
                self._save_data = {
                    "high_scores": {},
                    "achievements": [],
                    "statistics": {}
                }
        except Exception as e:
            print(f"加载存档文件失败: {e}")
            self._save_data = {
                "high_scores": {},
                "achievements": [],
                "statistics": {}
            }
    
    def save_game_data(self):
        """保存游戏数据"""
        try:
            with open(self._save_path, 'w', encoding='utf-8') as f:
                json.dump(self._save_data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"保存游戏数据失败: {e}")
    
    def _get_default_config(self) -> Dict[str, Any]:
        """获取默认配置"""
        return {
            "game": {
                "title": "Snake Game",
                "version": "2.0.0",
                "window_width": 1280,
                "window_height": 720,
                "fps": 60
            },
            "difficulty": {
                "levels": [
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
            },
            "game_modes": {
                "classic": {"name": "经典模式", "description": "传统贪吃蛇游戏"},
                "maze": {"name": "迷宫模式", "description": "带有障碍物的挑战模式"},
                "freestyle": {"name": "自由模式", "description": "无边界限制的自由模式"},
                "time_attack": {"name": "限时模式", "description": "在限定时间内获得最高分"},
                "survival": {"name": "生存模式", "description": "食物会逐渐消失的生存挑战"}
            },
            "graphics": {
                "grid_size": 20,
                "snake_head_color": "#50FF80",
                "snake_body_color": "#3CCC60",
                "food_normal_color": "#FF6464",
                "food_speed_up_color": "#64C8FF",
                "food_speed_down_color": "#B464FF",
                "food_ghost_color": "#FFDC64",
                "background_color": "#0C141E",
                "obstacle_color": "#505A64"
            },
            "audio": {
                "enable_sound": True,
                "enable_music": True,
                "sound_volume": 0.7,
                "music_volume": 0.5
            },
            "controls": {
                "up_key": "W",
                "down_key": "S",
                "left_key": "A",
                "right_key": "D",
                "pause_key": "Space",
                "restart_key": "R"
            }
        }
    
    # Properties for QML
    @Property(int, notify=difficultyChanged)
    def currentDifficulty(self):
        return self._current_difficulty
    
    @currentDifficulty.setter
    def currentDifficulty(self, value):
        if self._current_difficulty != value:
            self._current_difficulty = value
            self.difficultyChanged.emit(value)
            self.save_config()  # 自动保存设置
            print(f"Difficulty changed to: {value}")
    
    @Property(str, notify=gameModeChanged)
    def currentGameMode(self):
        return self._current_game_mode
    
    @currentGameMode.setter
    def currentGameMode(self, value):
        if self._current_game_mode != value:
            self._current_game_mode = value
            self.gameModeChanged.emit(value)
            self.save_config()  # 自动保存设置
            print(f"Game mode changed to: {value}")
    
    @Slot(result=int)
    def getWindowWidth(self):
        return self.config.get("game", {}).get("window_width", 1280)
    
    @Slot(result=int)
    def getWindowHeight(self):
        return self.config.get("game", {}).get("window_height", 720)
    
    @Slot(result=int)
    def getFPS(self):
        return self.config.get("game", {}).get("fps", 60)
    
    @Slot(int, result='QVariant')
    def getDifficultyConfig(self, level):
        """获取指定难度等级的配置"""
        levels = self.config.get("difficulty", {}).get("levels", [])
        for level_config in levels:
            if level_config.get("level") == level:
                return level_config
        return levels[0] if levels else {}
    
    @Slot(str, result='QVariant')
    def getGameModeConfig(self, mode):
        """获取游戏模式配置"""
        return self.config.get("game_modes", {}).get(mode, {})
    
    @Slot(result='QVariant')
    def getGraphicsConfig(self):
        """获取图形配置"""
        return self.config.get("graphics", {})
    
    @Slot(result='QVariant')
    def getAudioConfig(self):
        """获取音频配置"""
        return self.config.get("audio", {})
    
    @Slot(result='QVariant')
    def getControlsConfig(self):
        """获取控制配置"""
        return self.config.get("controls", {})
    
    @Slot(str, int)
    def saveHighScore(self, mode, score):
        """保存最高分"""
        if "high_scores" not in self._save_data:
            self._save_data["high_scores"] = {}
        
        current_high = self._save_data["high_scores"].get(mode, 0)
        if score > current_high:
            self._save_data["high_scores"][mode] = score
            self.save_game_data()
    
    @Slot(str, result=int)
    def getHighScore(self, mode):
        """获取最高分"""
        return self._save_data.get("high_scores", {}).get(mode, 0)
    
    @Slot(result='QVariant')
    def getAllHighScores(self):
        """获取所有高分记录"""
        return self._save_data.get("high_scores", {})

    def get_achievements(self):
        """获取成就数据"""
        return self._save_data.get("achievements", {})

    def save_achievements(self, achievements_data):
        """保存成就数据"""
        self._save_data["achievements"] = achievements_data
        self.save_game_data()

    @Slot(result='QVariant')
    def getAllAchievements(self):
        """获取所有成就数据（供QML使用）"""
        return self._save_data.get("achievements", {})

    @Slot(str, result=bool)
    def isAchievementUnlocked(self, achievement_id):
        """检查成就是否已解锁"""
        achievements = self._save_data.get("achievements", {})
        return achievements.get(achievement_id, {}).get("unlocked", False)

    def get_statistics(self):
        """获取游戏统计数据"""
        return self._save_data.get("statistics", {})

    def save_statistics(self, stats_data):
        """保存游戏统计数据"""
        self._save_data["statistics"] = stats_data
        self.save_game_data()

    @Slot(str, int)
    def updateStatistic(self, stat_name, value):
        """更新统计数据"""
        if "statistics" not in self._save_data:
            self._save_data["statistics"] = {}
        self._save_data["statistics"][stat_name] = value
        self.save_game_data() 