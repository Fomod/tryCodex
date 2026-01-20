//
//  GameScene.swift
//  P261
//
//  Created by Medivh on 1/15/26.
//

import SpriteKit

class GameScene: SKScene {

    // 游戏逻辑
    private var game: JokerPokerGame!

    // UI 元素
    private var cardNodes: [SKSpriteNode] = []
    private var startButton: SKSpriteNode!
    private var drawButton: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var handLabel: SKLabelNode!
    private var gamesLabel: SKLabelNode!
    private var statusLabel: SKLabelNode!

    // 常量
    private let cardSize = CGSize(width: 80, height: 120)
    private let cardSpacing: CGFloat = 100
    private let buttonSize = CGSize(width: 150, height: 50)

    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
        initializeGame()
    }

    // 设置背景
    private func setupBackground() {
        // 深绿色桌面背景
        let background = SKSpriteNode(color: SKColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0),
                                     size: self.size)
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = -10
        self.addChild(background)

        // 添加装饰性边框
        let border = SKShapeNode(rectOf: CGSize(width: self.size.width - 40, height: self.size.height - 40),
                                cornerRadius: 20)
        border.strokeColor = SKColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0)
        border.lineWidth = 4
        border.fillColor = .clear
        border.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(border)

        // 标题
        let titleLabel = SKLabelNode(text: "小丑牌游戏")
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.fontName = "PingFangSC-Semibold"
        titleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 60)
        self.addChild(titleLabel)

        // 游戏说明
        let instructionsLabel = SKLabelNode(text: "规则：获得最佳5张牌组合，点击牌选择换牌")
        instructionsLabel.fontSize = 16
        instructionsLabel.fontColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        instructionsLabel.fontName = "PingFangSC-Regular"
        instructionsLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 90)
        self.addChild(instructionsLabel)
    }

    // 设置UI元素
    private func setupUI() {
        // 分数显示
        scoreLabel = SKLabelNode(text: "分数: 0")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .yellow
        scoreLabel.fontName = "PingFangSC-Regular"
        scoreLabel.position = CGPoint(x: 120, y: self.size.height - 120)
        scoreLabel.horizontalAlignmentMode = .left
        self.addChild(scoreLabel)

        // 游戏次数显示
        gamesLabel = SKLabelNode(text: "游戏次数: 0")
        gamesLabel.fontSize = 20
        gamesLabel.fontColor = .white
        gamesLabel.fontName = "PingFangSC-Regular"
        gamesLabel.position = CGPoint(x: 120, y: self.size.height - 150)
        gamesLabel.horizontalAlignmentMode = .left
        self.addChild(gamesLabel)

        // 牌型显示
        handLabel = SKLabelNode(text: "牌型: 无")
        handLabel.fontSize = 28
        handLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        handLabel.fontName = "PingFangSC-Medium"
        handLabel.position = CGPoint(x: self.size.width / 2, y: 200)
        self.addChild(handLabel)

        // 状态提示
        statusLabel = SKLabelNode(text: "点击开始游戏")
        statusLabel.fontSize = 22
        statusLabel.fontColor = .cyan
        statusLabel.fontName = "PingFangSC-Regular"
        statusLabel.position = CGPoint(x: self.size.width / 2, y: 160)
        self.addChild(statusLabel)

        // 开始游戏按钮
        startButton = createButton(text: "开始游戏", position: CGPoint(x: self.size.width / 2 - 100, y: 100))
        self.addChild(startButton)

        // 换牌按钮
        drawButton = createButton(text: "换牌", position: CGPoint(x: self.size.width / 2 + 100, y: 100))
        drawButton.alpha = 0.5 // 初始禁用状态
        self.addChild(drawButton)
    }

    // 创建按钮
    private func createButton(text: String, position: CGPoint) -> SKSpriteNode {
        let button = SKSpriteNode(color: SKColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1.0),
                                 size: buttonSize)
        button.position = position
        button.name = text // 用于标识按钮

        // 按钮边框
        let border = SKShapeNode(rectOf: buttonSize, cornerRadius: 8)
        border.strokeColor = .white
        border.lineWidth = 2
        border.fillColor = .clear
        border.name = "border"
        button.addChild(border)

        // 按钮文字
        let label = SKLabelNode(text: text)
        label.fontSize = 18
        label.fontColor = .white
        label.fontName = "PingFangSC-Medium"
        label.verticalAlignmentMode = .center
        label.name = "label"
        button.addChild(label)

        return button
    }

    // 初始化游戏
    private func initializeGame() {
        game = JokerPokerGame()
        updateUI()
    }

    // 开始新游戏
    private func startNewGame() {
        game.startNewGame()
        dealCards()
        updateUI()
    }

    // 发牌动画
    private func dealCards() {
        // 清除现有牌
        cardNodes.forEach { $0.removeFromParent() }
        cardNodes.removeAll()

        // 计算牌的位置
        let startX = self.size.width / 2 - (cardSpacing * 2)
        let cardY: CGFloat = 300

        for (index, card) in game.playerHand.enumerated() {
            let cardNode = card.createNode(size: cardSize)
            let finalPosition = CGPoint(x: startX + CGFloat(index) * cardSpacing, y: cardY)

            // 从上方飞入的动画
            cardNode.position = CGPoint(x: finalPosition.x, y: self.size.height + cardSize.height)
            cardNode.alpha = 0

            self.addChild(cardNode)
            cardNodes.append(cardNode)

            // 发牌动画
            let moveAction = SKAction.move(to: finalPosition, duration: 0.3)
            let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
            let scaleAction = SKAction.scale(to: 1.1, duration: 0.1)
            let scaleBackAction = SKAction.scale(to: 1.0, duration: 0.1)

            let dealSequence = SKAction.sequence([
                SKAction.wait(forDuration: Double(index) * 0.1),
                SKAction.group([moveAction, fadeInAction]),
                scaleAction,
                scaleBackAction
            ])

            cardNode.run(dealSequence)
        }
    }

    // 换牌动画
    private func drawCards() {
        game.drawCards()

        // 更新牌面
        for (index, cardNode) in cardNodes.enumerated() {
            let newCard = game.playerHand[index]
            let newCardNode = newCard.createNode(size: cardSize)

            // 换牌动画
            let scaleOut = SKAction.scale(to: 0.1, duration: 0.2)
            let replaceAction = SKAction.run {
                cardNode.removeFromParent()
                newCardNode.position = cardNode.position
                newCardNode.alpha = 0
                self.addChild(newCardNode)
                self.cardNodes[index] = newCardNode
            }
            let scaleIn = SKAction.scale(to: 1.0, duration: 0.2)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)

            let sequence = SKAction.sequence([
                scaleOut,
                replaceAction,
                SKAction.group([scaleIn, fadeIn])
            ])

            cardNode.run(sequence)
        }

        // 延迟更新UI，等待动画完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.updateUI()
        }
    }

    // 更新UI显示
    private func updateUI() {
        let currentScore = game.getCurrentScore()
        let currentGames = game.getGamesPlayed()

        // 检查分数是否有变化，添加动画
        if let previousScore = Int(scoreLabel.text?.components(separatedBy: ": ").last ?? "0"),
           previousScore != currentScore && currentScore > previousScore {
            animateScoreIncrease(from: previousScore, to: currentScore)
        } else {
            scoreLabel.text = "分数: \(currentScore)"
        }

        gamesLabel.text = "游戏次数: \(currentGames)"

        switch game.gameState {
        case .selecting:
            statusLabel.text = "点击选择要换的牌，然后点击换牌"
            startButton.alpha = 0.5
            drawButton.alpha = 1.0
            handLabel.text = "牌型: 选择中..."
        case .evaluating:
            let (hand, handScore) = game.evaluateHand()
            handLabel.text = "牌型: \(hand.name)"
            statusLabel.text = "点击开始游戏开始新回合"
            startButton.alpha = 1.0
            drawButton.alpha = 0.5

            // 添加牌型评价动画
            animateHandEvaluation(hand, score: handScore)
        default:
            statusLabel.text = "点击开始游戏"
            startButton.alpha = 1.0
            drawButton.alpha = 0.5
            handLabel.text = "牌型: 无"
        }

        // 更新牌的选中状态
        for (index, cardNode) in cardNodes.enumerated() {
            if index < game.playerHand.count {
                game.playerHand[index].updateSelectionVisual()
            }
        }
    }

    // 分数增加动画
    private func animateScoreIncrease(from oldScore: Int, to newScore: Int) {
        let increase = newScore - oldScore

        // 创建分数增加的标签
        let scoreIncreaseLabel = SKLabelNode(text: "+\(increase)")
        scoreIncreaseLabel.fontSize = 24
        scoreIncreaseLabel.fontColor = .green
        scoreIncreaseLabel.fontName = "PingFangSC-Bold"
        scoreIncreaseLabel.position = scoreLabel.position
        scoreIncreaseLabel.position.y += 30
        self.addChild(scoreIncreaseLabel)

        // 动画序列
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let remove = SKAction.removeFromParent()

        let sequence = SKAction.sequence([SKAction.group([moveUp, fadeOut]), remove])
        scoreIncreaseLabel.run(sequence)

        // 更新分数标签
        scoreLabel.text = "分数: \(newScore)"
    }

    // 牌型评价动画
    private func animateHandEvaluation(_ hand: PokerHand, score: Int) {
        // 闪烁效果
        let originalColor = handLabel.fontColor
        let highlightColor = SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)

        let colorSequence = SKAction.sequence([
            SKAction.run { self.handLabel.fontColor = highlightColor },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { self.handLabel.fontColor = originalColor },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { self.handLabel.fontColor = highlightColor },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { self.handLabel.fontColor = originalColor }
        ])

        handLabel.run(colorSequence)

        // 如果是好牌型，添加庆祝效果
        if hand.rawValue >= PokerHand.threeOfAKind.rawValue {
            showCelebrationEffect()
        }
    }

    // 庆祝效果
    private func showCelebrationEffect() {
        // 创建星星效果
        for i in 0..<8 {
            let star = SKLabelNode(text: "⭐")
            star.fontSize = 30
            star.position = CGPoint(x: self.size.width / 2, y: 250)

            let angle = Double(i) * .pi / 4
            let radius: CGFloat = 100
            let endPosition = CGPoint(
                x: star.position.x + cos(angle) * radius,
                y: star.position.y + sin(angle) * radius
            )

            self.addChild(star)

            let moveAction = SKAction.move(to: endPosition, duration: 0.8)
            let scaleAction = SKAction.scale(to: 0.5, duration: 0.8)
            let fadeAction = SKAction.fadeOut(withDuration: 0.8)
            let removeAction = SKAction.removeFromParent()

            let sequence = SKAction.sequence([
                SKAction.group([moveAction, scaleAction, fadeAction]),
                removeAction
            ])

            star.run(sequence)
        }
    }

    // 处理触摸事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 检查是否点击了牌
        for (index, cardNode) in cardNodes.enumerated() {
            if cardNode.contains(location) && game.gameState == .selecting {
                game.toggleCardSelection(at: index)
                animateCardSelection(at: index)
                updateUI()
                return
            }
        }

        // 检查是否点击了按钮
        if startButton.contains(location) && startButton.alpha == 1.0 {
            animateButtonPress(startButton)
            startNewGame()
            return
        }

        if drawButton.contains(location) && drawButton.alpha == 1.0 {
            animateButtonPress(drawButton)
            drawCards()
            return
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 按钮悬停效果
        updateButtonHover(startButton, at: location)
        updateButtonHover(drawButton, at: location)

        // 牌悬停效果
        for (index, cardNode) in cardNodes.enumerated() {
            updateCardHover(cardNode, at: index, location: location)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 清除所有悬停效果
        clearButtonHover(startButton)
        clearButtonHover(drawButton)

        for cardNode in cardNodes {
            clearCardHover(cardNode)
        }
    }

    // 按钮按下动画
    private func animateButtonPress(_ button: SKSpriteNode) {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        button.run(sequence)
    }

    // 更新按钮悬停状态
    private func updateButtonHover(_ button: SKSpriteNode, at location: CGPoint) {
        if button.contains(location) && button.alpha == 1.0 {
            if button.xScale == 1.0 {
                let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
                button.run(scaleUp)

                // 高亮边框
                if let border = button.childNode(withName: "border") as? SKShapeNode {
                    border.strokeColor = .yellow
                }
            }
        } else {
            clearButtonHover(button)
        }
    }

    // 清除按钮悬停效果
    private func clearButtonHover(_ button: SKSpriteNode) {
        if button.xScale != 1.0 {
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            button.run(scaleDown)

            // 恢复边框颜色
            if let border = button.childNode(withName: "border") as? SKShapeNode {
                border.strokeColor = .white
            }
        }
    }

    // 牌选择动画
    private func animateCardSelection(at index: Int) {
        guard index < cardNodes.count else { return }
        let cardNode = cardNodes[index]

        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])

        cardNode.run(bounce)
    }

    // 更新牌悬停状态
    private func updateCardHover(_ cardNode: SKSpriteNode, at index: Int, location: CGPoint) {
        if cardNode.contains(location) && game.gameState == .selecting {
            if cardNode.xScale == 1.0 {
                let scaleUp = SKAction.scale(to: 1.08, duration: 0.1)
                cardNode.run(scaleUp)
            }
        } else {
            clearCardHover(cardNode)
        }
    }

    // 清除牌悬停效果
    private func clearCardHover(_ cardNode: SKSpriteNode) {
        if cardNode.xScale != 1.0 {
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            cardNode.run(scaleDown)
        }
    }
}
