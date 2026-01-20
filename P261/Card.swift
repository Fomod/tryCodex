//
//  Card.swift
//  P261
//
//  Created by Medivh on 1/20/26.
//

import SpriteKit

// 扑克牌花色枚举
enum Suit: String, CaseIterable {
    case spades = "♠"
    case hearts = "♥"
    case diamonds = "♦"
    case clubs = "♣"
    case joker = "🃏"

    var color: SKColor {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .spades, .clubs:
            return .black
        case .joker:
            return .purple
        }
    }
}

// 扑克牌点数枚举
enum Rank: Int, CaseIterable {
    case ace = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13
    case joker = 14

    var displayValue: String {
        switch self {
        case .ace: return "A"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .joker: return "JOKER"
        default: return "\(rawValue)"
        }
    }
}

// 扑克牌类
class Card {
    let suit: Suit
    let rank: Rank
    var isSelected: Bool = false
    var isFaceUp: Bool = true
    var node: SKSpriteNode?

    // 计算牌的数值（用于排序和比较）
    var value: Int {
        return rank.rawValue
    }

    init(suit: Suit, rank: Rank) {
        self.suit = suit
        self.rank = rank
    }

    // 创建卡牌的视觉节点
    func createNode(size: CGSize) -> SKSpriteNode {
        let cardNode = SKSpriteNode(color: .white, size: size)
        cardNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        // 添加边框
        let border = SKShapeNode(rectOf: size, cornerRadius: 8)
        border.strokeColor = .black
        border.lineWidth = 2
        border.fillColor = .clear
        cardNode.addChild(border)

        // 如果是正面朝上，显示牌面
        if isFaceUp {
            addCardFace(to: cardNode, size: size)
        } else {
            addCardBack(to: cardNode, size: size)
        }

        self.node = cardNode
        return cardNode
    }

    // 添加牌面内容
    private func addCardFace(to node: SKSpriteNode, size: CGSize) {
        // 左上角的花色和点数
        let topLeftLabel = SKLabelNode(text: suit.rawValue + rank.displayValue)
        topLeftLabel.fontSize = size.width * 0.15
        topLeftLabel.fontColor = suit.color
        topLeftLabel.position = CGPoint(x: -size.width * 0.35, y: size.height * 0.35)
        topLeftLabel.fontName = "Arial-BoldMT"
        node.addChild(topLeftLabel)

        // 右下角的花色和点数（旋转180度）
        let bottomRightLabel = SKLabelNode(text: suit.rawValue + rank.displayValue)
        bottomRightLabel.fontSize = size.width * 0.15
        bottomRightLabel.fontColor = suit.color
        bottomRightLabel.position = CGPoint(x: size.width * 0.35, y: -size.height * 0.35)
        bottomRightLabel.zRotation = .pi
        bottomRightLabel.fontName = "Arial-BoldMT"
        node.addChild(bottomRightLabel)

        // 居中的大花色符号（如果是小丑牌）
        if suit == .joker {
            let centerSymbol = SKLabelNode(text: suit.rawValue)
            centerSymbol.fontSize = size.width * 0.5
            centerSymbol.fontColor = suit.color
            centerSymbol.position = CGPoint(x: 0, y: size.height * 0.1)
            centerSymbol.fontName = "Arial-BoldMT"
            node.addChild(centerSymbol)

            // 小丑牌的特殊文字
            let jokerText = SKLabelNode(text: "JOKER")
            jokerText.fontSize = size.width * 0.12
            jokerText.fontColor = suit.color
            jokerText.position = CGPoint(x: 0, y: -size.height * 0.15)
            jokerText.fontName = "Arial-BoldMT"
            node.addChild(jokerText)

            // 添加装饰性星星
            let star1 = SKLabelNode(text: "⭐")
            star1.fontSize = size.width * 0.15
            star1.position = CGPoint(x: -size.width * 0.25, y: size.height * 0.25)
            node.addChild(star1)

            let star2 = SKLabelNode(text: "⭐")
            star2.fontSize = size.width * 0.15
            star2.position = CGPoint(x: size.width * 0.25, y: size.height * 0.25)
            node.addChild(star2)
        } else {
            // 普通牌的居中花色符号
            let centerSymbol = SKLabelNode(text: suit.rawValue)
            centerSymbol.fontSize = size.width * 0.6
            centerSymbol.fontColor = suit.color
            centerSymbol.position = CGPoint(x: 0, y: 0)
            centerSymbol.fontName = "Arial-BoldMT"
            node.addChild(centerSymbol)
        }
    }

    // 添加牌背面
    private func addCardBack(to node: SKSpriteNode, size: CGSize) {
        // 简单的牌背图案
        let backPattern = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: size.height * 0.8), cornerRadius: 4)
        backPattern.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        backPattern.strokeColor = .black
        backPattern.lineWidth = 1
        node.addChild(backPattern)

        // 添加装饰性图案
        let patternLabel = SKLabelNode(text: "♠♥♦♣")
        patternLabel.fontSize = size.width * 0.1
        patternLabel.fontColor = .white
        patternLabel.position = CGPoint(x: 0, y: 0)
        node.addChild(patternLabel)
    }

    // 更新选中状态的视觉效果
    func updateSelectionVisual() {
        guard let node = node else { return }

        if isSelected {
            // 添加选中边框
            if let existingBorder = node.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                existingBorder.strokeColor = .yellow
                existingBorder.lineWidth = 4
            }
            // 添加轻微的缩放效果
            node.setScale(1.05)
        } else {
            // 恢复正常状态
            if let existingBorder = node.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                existingBorder.strokeColor = .black
                existingBorder.lineWidth = 2
            }
            node.setScale(1.0)
        }
    }
}

// 便利扩展
extension Card: Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }
}

extension Card: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(suit)
        hasher.combine(rank)
    }
}

extension Card: Comparable {
    static func < (lhs: Card, rhs: Card) -> Bool {
        if lhs.rank != rhs.rank {
            return lhs.rank.rawValue < rhs.rank.rawValue
        }
        return lhs.suit.rawValue < rhs.suit.rawValue
    }
}