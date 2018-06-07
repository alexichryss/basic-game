//
//  GameOverScene.swift
//  Wormhole2
//
//  Created by Alexi Chryssanthou on 6/6/18.
//  Copyright © 2018 mobi.uchicago. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    //MARK: - Properties
    var vcDelegate: MenuController!
    
    //MARK: - Initialization
    init(size: CGSize, won:Bool, delegate:MenuController) {
        super.init(size: size)
        var boom = "boom_2.m4a"
        let number = arc4random_uniform(3)
        if number == 0 { boom = "boom_1.m4a"}
        run(SKAction.playSoundFileNamed(boom, waitForCompletion: false))
        backgroundColor = SKColor.clear
        
        // get original ViewController
        vcDelegate = delegate
        
        // set up background
        let background = SKSpriteNode(imageNamed: "starry sky")
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size = frame.size
        addChild(background)

        let message = won ? "You Won!" : "You crashed..."
        
        // Setup and display label
        let label = SKLabelNode(fontNamed: "Virgo01")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor(red: 234/255, green: 72/255, blue: 168/255, alpha: 1.0)
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
    
    //MARK: - Life Cycle
    override func didMove(to view: SKView) {
        print("Showing Game Over Screen")
        
        // after displaying, wait, and then call dismiss from ViewController
        run(SKAction.sequence([
                SKAction.wait(forDuration: 1.5),
                SKAction.run() { () -> Void in
                            self.vcDelegate.dismissGameOver(view)
                        }
                    ]
                )
            )
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
