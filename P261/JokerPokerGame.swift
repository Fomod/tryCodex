//
//  JokerPokerGame.swift
//  P261
//
//  Created by Medivh on 1/20/26.
//

import Foundation

// 牌型枚举（从小到大排序）
enum PokerHand: Int, Comparable {
    case highCard = 0          // 高牌
    case pair = 1              // 一对
    case twoPair = 2           // 两对
    case threeOfAKind = 3      // 三条
    case straight = 4          // 顺子
    case flush = 5             // 同花
    case fullHouse = 6         // 葫芦
    case fourOfAKind = 7       // 四条
    case straightFlush = 8     // 同花顺
    case royalFlush = 9        // 皇家同花顺

    var name: String {
        switch self {
        case .highCard: return "高牌"
        case .pair: return "一对"
        case .twoPair: return "两对"
        case .threeOfAKind: return "三条"
        case .straight: return "顺子"
        case .flush: return "同花"
        case .fullHouse: return "葫芦"
        case .fourOfAKind: return "四条"
        case .straightFlush: return "同花顺"
        case .royalFlush: return "皇家同花顺"
        }
    }

    var score: Int {
        switch self {
        case .highCard: return 0
        case .pair: return 10
        case .twoPair: return 20
        case .threeOfAKind: return 30
        case .straight: return 40
        case .flush: return 50
        case .fullHouse: return 60
        case .fourOfAKind: return 70
        case .straightFlush: return 80
        case .royalFlush: return 100
        }
    }

    static func < (lhs: PokerHand, rhs: PokerHand) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// 游戏状态枚举
enum GameState {
    case dealing     // 发牌中
    case selecting   // 选择要换的牌
    case drawing     // 换牌中
    case evaluating  // 评估牌型
    case gameOver    // 游戏结束
}

// 小丑牌游戏核心逻辑
class JokerPokerGame {
    private var deck: [Card] = []
    private(set) var playerHand: [Card] = []
    private(set) var gameState: GameState = .dealing
    private(set) var score: Int = 0
    private(set) var gamesPlayed: Int = 0

    // 初始化游戏
    init() {
        resetDeck()
    }

    // 重置牌堆
    private func resetDeck() {
        deck.removeAll()
        // 创建52张标准扑克牌 + 2张小丑牌
        for suit in Suit.allCases where suit != .joker {
            for rank in Rank.allCases where rank != .joker {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        // 添加两张小丑牌
        deck.append(Card(suit: .joker, rank: .joker))
        deck.append(Card(suit: .joker, rank: .joker))

        // 洗牌
        deck.shuffle()
    }

    // 开始新游戏
    func startNewGame() {
        resetDeck()
        playerHand.removeAll()
        gameState = .dealing

        // 发5张牌
        for _ in 0..<5 {
            if let card = deck.popLast() {
                playerHand.append(card)
            }
        }

        gameState = .selecting
    }

    // 切换牌的选中状态
    func toggleCardSelection(at index: Int) {
        guard gameState == .selecting, index >= 0, index < playerHand.count else { return }
        playerHand[index].isSelected.toggle()
    }

    // 换牌
    func drawCards() {
        guard gameState == .selecting else { return }

        gameState = .drawing

        // 收集要换的牌的索引
        let cardsToReplace = playerHand.enumerated()
            .filter { $0.element.isSelected }
            .map { $0.offset }

        // 换牌
        for index in cardsToReplace.reversed() {
            if let newCard = deck.popLast() {
                playerHand[index] = newCard
            }
        }

        // 取消所有选中状态
        playerHand.forEach { $0.isSelected = false }

        gameState = .evaluating
        gamesPlayed += 1
    }

    // 评估当前手牌
    func evaluateHand() -> (hand: PokerHand, score: Int) {
        let hand = evaluatePokerHand(playerHand)
        let handScore = hand.score
        score += handScore
        return (hand, handScore)
    }

    // 评估牌型
    private func evaluatePokerHand(_ cards: [Card]) -> PokerHand {
        let sortedCards = cards.sorted(by: >)

        // 检查是否为同花
        let isFlush = Set(cards.map { $0.suit }).count == 1

        // 检查是否为顺子
        let isStraight = checkStraight(cards)

        // 统计每种点数的牌数
        var rankCounts: [Rank: Int] = [:]
        for card in cards {
            rankCounts[card.rank, default: 0] += 1
        }

        // 特殊处理小丑牌（可以作为任何牌）
        let jokerCount = rankCounts[.joker] ?? 0
        if jokerCount > 0 {
            // 移除小丑牌，重新计算最佳牌型
            return evaluateHandWithJokers(cards.filter { $0.suit != .joker })
        }

        // 检查各种牌型
        let counts = Array(rankCounts.values).sorted(by: >)

        // 皇家同花顺
        if isFlush && isStraight && sortedCards.first!.rank == .ace && sortedCards.last!.rank == .ten {
            return .royalFlush
        }

        // 同花顺
        if isFlush && isStraight {
            return .straightFlush
        }

        // 四条
        if counts.contains(4) {
            return .fourOfAKind
        }

        // 葫芦
        if counts == [3, 2] {
            return .fullHouse
        }

        // 同花
        if isFlush {
            return .flush
        }

        // 顺子
        if isStraight {
            return .straight
        }

        // 三条
        if counts.contains(3) {
            return .threeOfAKind
        }

        // 两对
        if counts == [2, 2, 1] {
            return .twoPair
        }

        // 一对
        if counts.contains(2) {
            return .pair
        }

        // 高牌
        return .highCard
    }

    // 检查是否为顺子
    private func checkStraight(_ cards: [Card]) -> Bool {
        let sortedRanks = cards.map { $0.rank.rawValue }.sorted()

        // 检查常规顺子
        for i in 0..<sortedRanks.count-1 {
            if sortedRanks[i+1] != sortedRanks[i] + 1 {
                return false
            }
        }
        return true
    }

    // 使用小丑牌评估牌型（小丑牌可以作为任何牌）
    private func evaluateHandWithJokers(_ nonJokerCards: [Card]) -> PokerHand {
        let jokerCount = 2 - nonJokerCards.count // 计算小丑牌数量

        // 如果没有小丑牌，返回普通评估
        if jokerCount == 0 {
            return evaluatePokerHand(nonJokerCards)
        }

        // 生成所有可能的牌型组合（小丑牌可以替代任何牌）
        var bestHand: PokerHand = .highCard

        // 递归尝试不同的牌型
        func tryHandType(_ remainingCards: [Card], _ jokersUsed: Int) -> PokerHand {
            if remainingCards.count == 5 {
                return evaluatePokerHand(remainingCards)
            }

            var currentBest: PokerHand = .highCard

            // 尝试添加一张牌
            for suit in Suit.allCases where suit != .joker {
                for rank in Rank.allCases where rank != .joker {
                    let newCard = Card(suit: suit, rank: rank)
                    var newHand = remainingCards + [newCard]
                    let handType = tryHandType(newHand, jokersUsed + 1)
                    if handType > currentBest {
                        currentBest = handType
                    }
                }
            }

            return currentBest
        }

        bestHand = tryHandType(nonJokerCards, 0)
        return bestHand
    }

    // 获取当前手牌的描述
    func getHandDescription() -> String {
        let (hand, _) = evaluateHand()
        return hand.name
    }

    // 获取当前分数
    func getCurrentScore() -> Int {
        return score
    }

    // 获取游戏次数
    func getGamesPlayed() -> Int {
        return gamesPlayed
    }
}