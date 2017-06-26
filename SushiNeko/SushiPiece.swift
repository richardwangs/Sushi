//
//  SushiPiece.swift
//  SushiNeko
//
//  Created by Mr StealUrGirl on 6/26/17.
//  Copyright © 2017 Mr StealUrGirl. All rights reserved.
//

import SpriteKit

class SushiPiece: SKSpriteNode {
    
    /* Chopsticks objects */
    var rightChopstick: SKSpriteNode!
    var leftChopstick: SKSpriteNode!
    
    var side: Side = .none{
        didSet{
            switch side{
            case .left:
                leftChopstick.isHidden = false
            case .right:
                rightChopstick.isHidden = false
            case .none:
                leftChopstick.isHidden = true
                rightChopstick.isHidden = true
            }
        }
    }
    
    var rarity: Rarity = .common
    
    func connectChopsticks() {
        /* Connect our child chopstick nodes */
        rightChopstick = childNode(withName: "rightChopstick") as! SKSpriteNode
        leftChopstick = childNode(withName: "leftChopstick") as! SKSpriteNode
        side = .none
    }
    
    func flip(_ side: Side){
        
        var actionName : String = ""
        
        
        if side == .left{
            actionName = "FlipRight"
        }else if side == .right{
            actionName = "FlipLeft"
        }
        
        let flip = SKAction(named : actionName)!
        
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([flip,remove])
        run(sequence)
    }
    /* You are required to implement this for your subclass to work */
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
