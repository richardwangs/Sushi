//
//  GameScene.swift
//  SushiNeko
//
//  Created by Mr StealUrGirl on 6/26/17.
//  Copyright © 2017 Mr StealUrGirl. All rights reserved.
//

import SpriteKit

enum Side {
    case left,right,none
}
enum GameState{
    case title, ready, playing, gameOver
}
enum Rarity{
    case common ,rare, epic, legendary
}
class GameScene: SKScene {
    
    var sushiBasePiece : SushiPiece!
    var character : Character!
    var sushiTower: [SushiPiece] = []
    var state : GameState = .title
    var playButton : MSButtonNode!
    var healthBar : SKSpriteNode!
    var scoreLabel : SKLabelNode!
    var health: CGFloat = 1.0 {
        didSet {
            /* Scale health bar between 0.0 -> 1.0 e.g 0 -> 100% */
            if health > 1.0 { health = 1.0 }
            healthBar.xScale = health
        }
    }
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        sushiBasePiece = childNode(withName: "sushiBasePiece") as! SushiPiece
        character = childNode(withName: "character") as! Character
        playButton = childNode(withName: "playButton") as! MSButtonNode
        healthBar = childNode(withName: "healthBar") as! SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        sushiBasePiece.connectChopsticks()
        addTowerPiece(side: .none , rarity: .common)
        addTowerPiece(side: .right, rarity: .common)
        addRandomPieces(total: 10)
        playButton.selectedHandler = {
            self.state = .ready
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .gameOver || state == .title { return }
        /* Game begins on first touch */
        if state == .ready {
            state = .playing
        }
        
        let touch = touches.first!
        
        let location = touch.location(in: self)
        
        if location.x > size.width/2{
            character.side = .right
        }
        else {
            character.side = .left
        }
        if let firstPiece = sushiTower.first {
            
            /* Check character side against sushi piece side (this is our death collision check)*/
            if character.side == firstPiece.side {
                
                /* Drop all the sushi pieces down a place (visually) */
                moveTowerDown()
                
                gameOver()
                
                /* No need to continue as player is dead */
                return
            }

            sushiTower.removeFirst()
            firstPiece.flip(character.side)
            switch firstPiece.rarity {
            case .rare:
                score += 2
            case .epic:
                score += 3
            case .legendary:
                score += 4
            default:
                score += 1
            }
            healthBar.zPosition += 1
            scoreLabel.zPosition += 1
            health += 0.1
            addRandomPieces(total: 1)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if state != .playing {
            return
        }
        /* Decrease Health */
        health -= 0.01 * CGFloat(score)/50
        /* Has the player ran out of health? */
        if health < 0 {
            gameOver()
        }
        moveTowerDown()

    }
    

    func gameOver(){
        
        state = .gameOver
        
        for sushiPiece in sushiTower{
            sushiPiece.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0.5))
        }
        sushiBasePiece.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0.5))
        
        character.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0.5))
        
        playButton.selectedHandler = {
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                return
            }
            
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)

    }
    }

    
    func moveTowerDown() {
        var n: CGFloat = 0
        for piece in sushiTower {
            let y = (n * 55) + 215
            piece.position.y -= (piece.position.y - y) * 0.5
            n += 1
        }
    }



    func addTowerPiece(side: Side , rarity : Rarity) {
        /* Add a new sushi piece to the sushi tower */
        
        /* Copy original sushi piece */
        let newPiece = sushiBasePiece.copy() as! SushiPiece
        newPiece.connectChopsticks()
        
        /* Access last piece properties */
        let lastPiece = sushiTower.last
        
        /* Add on top of last piece, default on first piece */
        let lastPosition = lastPiece?.position ?? sushiBasePiece.position
        newPiece.position.x = lastPosition.x
        newPiece.position.y = lastPosition.y + 55
        
        /* Increment Z to ensure it's on top of the last piece, default on first piece*/
        let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
        newPiece.zPosition = lastZPosition + 1
        
        /* Set side */
        newPiece.side = side
        newPiece.rarity = rarity
        
        switch newPiece.rarity {
        case .common:
            newPiece.run(SKAction.colorize(with: UIColor.gray, colorBlendFactor: 1, duration: 0.5))
        case .rare:
            newPiece.run(SKAction.colorize(with: UIColor.blue, colorBlendFactor: 1, duration: 0.5))
        case .epic:
            newPiece.run(SKAction.colorize(with: UIColor.purple, colorBlendFactor: 1, duration: 0.5))
        default:
            newPiece.run(SKAction.colorize(with: UIColor.orange, colorBlendFactor: 1, duration: 0.5))

        }

        
        /* Add sushi to scene */
        addChild(newPiece)
        
        /* Add sushi piece to the sushi tower */
        sushiTower.append(newPiece)
    }
    
    func randomRarity() -> Rarity{
        var rarity : Rarity
        let random = arc4random_uniform(100)
        
        if random < 65{
            rarity = .common
        }
        else if random < 87{
            rarity = .rare
        }
        else if random < 95{
            rarity = .epic
        }
        else{
            rarity = .legendary
        }
        return rarity
    }
    

    
    func addRandomPieces(total : Int){
        
        for _ in 1...total{
            let rarity = randomRarity()
            let lastPiece = sushiTower.last as! SushiPiece
            
            if lastPiece.side != .none {
                addTowerPiece(side: .none , rarity: rarity)
            } else {
                
                let rand = arc4random_uniform(100)
                
                if rand < 45{
                    addTowerPiece(side: .left , rarity: rarity)
                }else if rand < 90 {
                    addTowerPiece(side: .right , rarity: rarity)
                }else{
                    addTowerPiece(side: .none , rarity: rarity)
                }
                
            }
            
        }
    }
    
}
