import QtQuick 2.15

Canvas {
    id: canvas
    
    property var gameEngine: parent.gameEngine || null
    
    onPaint: {
        if (!gameEngine) return
        
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        
        var gridSize = Math.min(width / gameEngine.gridWidth, height / gameEngine.gridHeight)
        var offsetX = (width - gameEngine.gridWidth * gridSize) / 2
        var offsetY = (height - gameEngine.gridHeight * gridSize) / 2
        
        // 绘制障碍物
        drawObstacles(ctx, gridSize, offsetX, offsetY)
        
        // 绘制食物
        drawFood(ctx, gridSize, offsetX, offsetY)
        
        // 绘制蛇
        drawSnake(ctx, gridSize, offsetX, offsetY)
    }
    
    function drawSnake(ctx, gridSize, offsetX, offsetY) {
        var positions = gameEngine.snakePositions
        if (!positions || positions.length === 0) return
        
        for (var i = 0; i < positions.length; i++) {
            var pos = positions[i]
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
        ctx.fillStyle = gameEngine.ghostMode ? "#80FF80AA" : "#50FF80"
        ctx.beginPath()
        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
        ctx.fill()
        
        // 边框
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
        if (gameEngine.ghostMode) {
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
        var color = gameEngine.ghostMode ? 
            "rgba(60, 204, 96, " + (alpha * 0.7) + ")" : 
            "rgba(60, 204, 96, " + alpha + ")"
        
        ctx.fillStyle = color
        ctx.beginPath()
        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
        ctx.fill()
        
        // 边框
        ctx.strokeStyle = gameEngine.ghostMode ? "#80CCCCAA" : "#CCCCCC"
        ctx.lineWidth = 1
        ctx.stroke()
    }
    
    function drawFood(ctx, gridSize, offsetX, offsetY) {
        var foods = gameEngine.foodPositions
        if (!foods) return
        
        for (var i = 0; i < foods.length; i++) {
            var food = foods[i]
            var x = offsetX + food.x * gridSize
            var y = offsetY + food.y * gridSize
            
            drawFoodItem(ctx, x, y, gridSize, food.type)
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
        
        // 发光效果
        ctx.shadowColor = color
        ctx.shadowBlur = 8
        ctx.beginPath()
        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
        ctx.fill()
        ctx.shadowBlur = 0
        
        // 边框
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
        var obstacles = gameEngine.obstaclePositions
        if (!obstacles) return
        
        for (var i = 0; i < obstacles.length; i++) {
            var obstacle = obstacles[i]
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
        
        // 纹理线条
        ctx.strokeStyle = "#666666"
        ctx.lineWidth = 0.5
        var lineSpacing = size * 0.2
        for (var i = 1; i < 4; i++) {
            var lineY = y + margin + i * lineSpacing
            ctx.beginPath()
            ctx.moveTo(x + margin, lineY)
            ctx.lineTo(x + size - margin, lineY)
            ctx.stroke()
        }
    }
    
    // 监听游戏状态变化
    Connections {
        target: gameEngine
        function onSnakePositionsChanged() {
            canvas.requestPaint()
        }
        function onFoodPositionsChanged() {
            canvas.requestPaint()
        }
        function onObstaclePositionsChanged() {
            canvas.requestPaint()
        }
    }
} 