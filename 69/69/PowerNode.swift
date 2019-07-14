//
//  PowerNode.swift
//  69
//
//  Created by Vlados iOS on 7/14/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import SpriteKit

final class PowerNode: SKNode {
    private let scoreKey = "RAINCAT_HIGHSCORE"
    private let scoreNode = SKLabelNode(fontNamed: "PixelDigivolve")
    private(set) var score : Int = 0
    private var highScore : Int = 0
    private var showingHighScore = false
    
    /// Set up HUD here.
    public func setup(size: CGSize) {
        let defaults = UserDefaults.standard
        
        highScore = defaults.integer(forKey: scoreKey)
        
        scoreNode.text = "\(score)"
        scoreNode.fontSize = 70
        scoreNode.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreNode.zPosition = 1
        
        addChild(scoreNode)
    }
    
    /// Add point.
    /// - Increments the score.
    /// - Saves to user defaults.
    /// - If a high score is achieved, then enlarge the scoreNode and update the color.
    public func addPoint() {
        score += 1
        
        updateScoreboard()
        
        if score > highScore {
            
            let defaults = UserDefaults.standard
            
            defaults.set(score, forKey: scoreKey)
            
            if !showingHighScore {
                showingHighScore = true
                
                scoreNode.run(SKAction.scale(to: 1.5, duration: 0.25))
                scoreNode.fontColor = SKColor(red:0.99, green:0.92, blue:0.55, alpha:1.0)
            }
        }
    }
    
    func startAnimation() {
        let upPoint = CGPoint(x: scoreNode.xScale, y: scoreNode.yScale + 40)
        let downPoint = CGPoint(x: scoreNode.xScale, y: scoreNode.yScale - 40)
        let moveUpAction = SKAction.move(to: upPoint, duration: 1)
        let moveDownAction = SKAction.move(to: downPoint, duration: 2)

        let scaleActionSequence = SKAction.sequence([moveUpAction, moveDownAction])
        
        let repeatAction = SKAction.repeatForever(scaleActionSequence)
        
        let actionSequence = SKAction.sequence([repeatAction])
        
        scoreNode.run(actionSequence)
    }
    
    /// Reset points.
    /// - Sets score to zero.
    /// - Updates score label.
    /// - Resets color and size to default values.
    public func resetPoints() {
        score = 0
        
        updateScoreboard()
        
        if showingHighScore {
            showingHighScore = false
            
            scoreNode.run(SKAction.scale(to: 1.0, duration: 0.25))
            scoreNode.fontColor = SKColor.white
        }
    }
    
    /// Updates the score label to show the current score.
    private func updateScoreboard() {
        scoreNode.text = "\(score)"
    }
}
