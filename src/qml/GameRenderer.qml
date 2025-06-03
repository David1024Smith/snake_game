import QtQuick 2.15

Canvas {
    id: canvas
    
    property var gameEngine: null
    onGameEngineChanged: {
        if (gameEngine !== null) {
            console.log("GameRenderer received gameEngine:", gameEngine)
            requestPaint()
        }
    }
    
    // 添加帧率控制变量
    property int lastFrameTime: 0
    property bool needsUpdate: false
    
    onPaint: {
        // 当前时间
        var currentTime = new Date().getTime()
        
        if (!gameEngine) {
            // 如果游戏引擎为空，绘制占位符或提示
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            ctx.fillStyle = "#2A3442"
            ctx.fillRect(0, 0, width, height)
            
            ctx.font = "20px sans-serif"
            ctx.fillStyle = "#50FF80"
            ctx.textAlign = "center"
            ctx.fillText("游戏引擎加载中...", width / 2, height / 2)
            return
        }
        
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        
        var gridSize = Math.min(width / (gameEngine.gridWidth || 30), height / (gameEngine.gridHeight || 20))
        var offsetX = (width - (gameEngine.gridWidth || 30) * gridSize) / 2
        var offsetY = (height - (gameEngine.gridHeight || 20) * gridSize) / 2
        
        // 绘制网格背景
        drawGrid(ctx, gridSize, offsetX, offsetY)
        
        // 绘制障碍物
        drawObstacles(ctx, gridSize, offsetX, offsetY)
        
        // 绘制食物
        drawFood(ctx, gridSize, offsetX, offsetY)
        
        // 绘制蛇
        drawSnake(ctx, gridSize, offsetX, offsetY)
        
        // 更新帧时间
        lastFrameTime = currentTime
        needsUpdate = false
    }
    
    function drawGrid(ctx, gridSize, offsetX, offsetY) {
        var gridWidth = gameEngine.gridWidth || 30
        var gridHeight = gameEngine.gridHeight || 20
        
        // 绘制背景 - 简单的纯色背景
        ctx.fillStyle = "#0C141E"
        ctx.fillRect(offsetX, offsetY, gridWidth * gridSize, gridHeight * gridSize)
        
        // 绘制主网格线 - 确保设置正确的样式
        ctx.strokeStyle = "#2A3A4A"  // 适中的网格线颜色
        ctx.lineWidth = 0.5  // 细线条，减少视觉干扰
        
        // 绘制水平线
        for (var y = 0; y <= gridHeight; y++) {
            ctx.beginPath()
            ctx.moveTo(offsetX, offsetY + y * gridSize)
            ctx.lineTo(offsetX + gridWidth * gridSize, offsetY + y * gridSize)
            ctx.stroke()
        }
        
        // 绘制垂直线
        for (var x = 0; x <= gridWidth; x++) {
            ctx.beginPath()
            ctx.moveTo(offsetX + x * gridSize, offsetY)
            ctx.lineTo(offsetX + x * gridSize, offsetY + gridHeight * gridSize)
            ctx.stroke()
        }
        
        // 绘制游戏区域边框 - 重新设置样式确保正确
        ctx.strokeStyle = "#50FF80"  // 使用游戏主题色
        ctx.lineWidth = 3
        ctx.strokeRect(offsetX, offsetY, gridWidth * gridSize, gridHeight * gridSize)
    }
    
    function drawSnake(ctx, gridSize, offsetX, offsetY) {
        if (!gameEngine) return
        
        var positions = gameEngine.snakePositions
        if (!positions || positions.length === 0) return
        
        for (var i = 0; i < positions.length; i++) {
            var pos = positions[i]
            if (!pos || pos.x === undefined || pos.y === undefined) continue
            
            var x = offsetX + pos.x * gridSize
            var y = offsetY + pos.y * gridSize
            
            if (i === 0) {
                // 绘制蛇头
                drawSnakeHead(ctx, x, y, gridSize)
            } else {
                // 绘制蛇身
                drawSnakeBody(ctx, x, y, gridSize, i)
            }
        }
    }
    
    function drawSnakeHead(ctx, x, y, size) {
        var centerX = x + size / 2
        var centerY = y + size / 2
        var radius = size * 0.4
        
        // 主体
        ctx.fillStyle = gameEngine && gameEngine.ghostMode ? "#80FF80AA" : "#50FF80"
        ctx.beginPath()
        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
        ctx.fill()
        
        // 边框 - 确保设置正确的样式
        ctx.strokeStyle = "#FFFFFF"
        ctx.lineWidth = 2
        ctx.stroke()
        
        // 眼睛
        ctx.fillStyle = "#0C141E"
        var eyeSize = size * 0.08
        var eyeOffset = size * 0.15
        
        // 左眼
        ctx.beginPath()
        ctx.arc(centerX - eyeOffset, centerY - eyeOffset, eyeSize, 0, 2 * Math.PI)
        ctx.fill()
        
        // 右眼
        ctx.beginPath()
        ctx.arc(centerX + eyeOffset, centerY - eyeOffset, eyeSize, 0, 2 * Math.PI)
        ctx.fill()
        
        // 发光效果（幽灵模式）
        if (gameEngine && gameEngine.ghostMode) {
            ctx.shadowColor = "#50FF80"
            ctx.shadowBlur = 10
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
            ctx.stroke()
            ctx.shadowBlur = 0
        }
    }
    
    function drawSnakeBody(ctx, x, y, size, index) {
        var centerX = x + size / 2
        var centerY = y + size / 2
        var radius = size * 0.35
        
        // 渐变色
        var alpha = Math.max(0.6, 1 - index * 0.05)
        var color = gameEngine && gameEngine.ghostMode ? 
            "rgba(60, 204, 96, " + (alpha * 0.7) + ")" : 
            "rgba(60, 204, 96, " + alpha + ")"
        
        ctx.fillStyle = color
        ctx.beginPath()
        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
        ctx.fill()
        
        // 边框
        ctx.strokeStyle = gameEngine && gameEngine.ghostMode ? "#80CCCCAA" : "#CCCCCC"
        ctx.lineWidth = 1
        ctx.stroke()
    }
    
    function drawFood(ctx, gridSize, offsetX, offsetY) {
        if (!gameEngine) return
        
        // 尝试使用foodPositions数组(完整版本)
        var foods = gameEngine.foodPositions
        if (foods && foods.length > 0) {
            for (var i = 0; i < foods.length; i++) {
                var food = foods[i]
                if (!food || food.x === undefined || food.y === undefined) continue
                
                var x = offsetX + food.x * gridSize
                var y = offsetY + food.y * gridSize
                
                drawFoodItem(ctx, x, y, gridSize, food.type || 1)
            }
        } 
        // 如果没有食物数组，尝试使用单个食物位置(简化版本)
        else if (gameEngine.foodPosition) {
            var singleFood = gameEngine.foodPosition
            if (singleFood && singleFood.x !== undefined && singleFood.y !== undefined) {
                console.log("Drawing single food at:", singleFood.x, singleFood.y)
                var x = offsetX + singleFood.x * gridSize
                var y = offsetY + singleFood.y * gridSize
                
                drawFoodItem(ctx, x, y, gridSize, 1) // 默认类型为1
            } else {
                console.warn("Invalid food position:", singleFood)
            }
        } else {
            console.warn("No food available to draw")
        }
    }
    
    function drawFoodItem(ctx, x, y, size, type) {
        var centerX = x + size / 2
        var centerY = y + size / 2
        var radius = size * 0.3
        
        // 根据食物类型选择颜色
        var color = "#FF6464" // 默认红色
        
        switch (type) {
            case 1: // NORMAL
                color = "#FF6464"
                break
            case 2: // SPEED_UP
                color = "#64C8FF"
                break
            case 3: // SPEED_DOWN
                color = "#B464FF"
                break
            case 4: // GHOST
                color = "#FFDC64"
                break
            case 5: // BONUS
                color = "#FF9864"
                break
        }
        
        // 主体
        ctx.fillStyle = color
        ctx.beginPath()
        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
        ctx.fill()
        
        // 边框 - 确保设置正确的样式
        ctx.strokeStyle = "#FFFFFF"
        ctx.lineWidth = 1
        ctx.stroke()
        
        // 特殊食物的额外效果
        if (type !== 1) {
            // 内圈
            ctx.fillStyle = "#FFFFFF"
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius * 0.4, 0, 2 * Math.PI)
            ctx.fill()
        }
    }
    
    function drawObstacles(ctx, gridSize, offsetX, offsetY) {
        if (!gameEngine) return
        
        var obstacles = gameEngine.obstaclePositions
        if (!obstacles || obstacles.length === 0) return
        
        for (var i = 0; i < obstacles.length; i++) {
            var obstacle = obstacles[i]
            if (!obstacle || obstacle.x === undefined || obstacle.y === undefined) continue
            
            var x = offsetX + obstacle.x * gridSize
            var y = offsetY + obstacle.y * gridSize
            
            drawObstacle(ctx, x, y, gridSize)
        }
    }
    
    function drawObstacle(ctx, x, y, size) {
        var margin = size * 0.1
        
        // 主体
        ctx.fillStyle = "#505A64"
        ctx.fillRect(x + margin, y + margin, size - 2 * margin, size - 2 * margin)
        
        // 边框
        ctx.strokeStyle = "#AAAAAA"
        ctx.lineWidth = 1
        ctx.strokeRect(x + margin, y + margin, size - 2 * margin, size - 2 * margin)
        
        // 图案
        ctx.strokeStyle = "#606A74"
        ctx.lineWidth = 1
        
        // 交叉线
        ctx.beginPath()
        ctx.moveTo(x + margin, y + margin)
        ctx.lineTo(x + size - margin, y + size - margin)
        ctx.moveTo(x + size - margin, y + margin)
        ctx.lineTo(x + margin, y + size - margin)
        ctx.stroke()
    }
    
    // 优化Connections，避免过度重绘
    Connections {
        target: gameEngine
        enabled: gameEngine !== null
        function onSnakePositionsChanged() { 
            needsUpdate = true
            canvas.requestPaint() 
        }
        function onFoodPositionsChanged() { 
            needsUpdate = true
            canvas.requestPaint() 
        }
        function onFoodPositionChanged() { 
            needsUpdate = true
            canvas.requestPaint() 
        }
        function onObstaclePositionsChanged() { 
            needsUpdate = true
            canvas.requestPaint() 
        }
        function onGhostModeChanged() { 
            needsUpdate = true
            canvas.requestPaint() 
        }
        function onGridSizeChanged() { 
            needsUpdate = true
            canvas.requestPaint() 
        }
    }
    
   
    Timer {
        interval: 60
        running: canvas.visible
        repeat: true
        onTriggered: {
            // 只在需要更新时重绘
            if (needsUpdate) {
                canvas.requestPaint()
            }
        }
    }
} 