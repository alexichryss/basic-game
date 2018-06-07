//
//  GameScene.swift
//  Wormhole2
//
//  Created by Alexi Chryssanthou on 5/30/18.
//  Copyright © 2018 mobi.uchicago. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK: - Properties
    
    //var gameSceneDelegate: GameSceneDelegate?
    weak var vcDelegate: MenuController!
    var entities = [GKEntity]()
    var moving: SKNode!
    var ship: SKSpriteNode!
    var walls: SKNode!
    var port: SKNode!
    var stars: SKEmitterNode!
    var moveAndRemoveWalls: SKAction!
    var moveAndRemovePort: SKAction!
    var wallGap: CGFloat = 300.0
    var minGap: CGFloat!
    var maxGap: CGFloat!
    var wallWidth:CGFloat = 60.0
    var height: CGFloat!
    var width: CGFloat!
    var lastY: CGFloat!
    var topY: CGFloat!
    var botY: CGFloat!
    var lastColor: color?
    var lastRGB: CGFloat = 0.0
    private var lastUpdateTime : TimeInterval = 0
    var scoreLabelNode:SKLabelNode!
    var playerScore: Int = 1
	
    enum color { case green, blue, red }
    
    //MARK: - Category Bit Masks
    
    let shipCategory: UInt32 = 1 << 0
    let wallCategory: UInt32 = 1 << 1
    let scoreCategory: UInt32 = 1 << 2
    
    //MARK: - Life Cycle
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }

    override func didMove(to view: SKView) {

        // set height and width properties
        width = view.frame.size.width/2
        height = view.frame.size.height/2
        wallWidth = view.frame.size.width/11
        wallGap = view.frame.size.height*2/3
        minGap = height/6
        maxGap = height*5/6
        topY = maxGap
        botY = -maxGap
        lastY = CGFloat(arc4random_uniform(UInt32(maxGap)+1)) + minGap
        
        // Get node for background child node and change size to fit
        let background: SKSpriteNode = self.childNode(withName: "bg") as! SKSpriteNode
        background.size = view.frame.size
        background.texture?.filteringMode = SKTextureFilteringMode.nearest
        background.zPosition = -5
        
        // get and add emitter node
        if let stars: SKEmitterNode = SKEmitterNode(fileNamed: "stars.sks") {
            stars.position = CGPoint(x: 0, y: 0)
            stars.particlePositionRange = CGVector(dx: width*2, dy: height*2)
            stars.zPosition = -4
            addChild(stars)
            self.stars = stars
        }
        
        // setup physics
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.7)
        physicsWorld.contactDelegate = self
        moving = SKNode()
        addChild(moving)
        walls = SKNode()
        moving.addChild(walls)
        
        // create the walls movement actions
        let distanceToMove = width*2 + wallWidth*2
        let duration = TimeInterval(0.0065 * distanceToMove)
        let movewalls = SKAction.moveBy(x: -distanceToMove, y:0.0, duration: duration)
        let removewalls = SKAction.removeFromParent()
        moveAndRemoveWalls = SKAction.sequence([movewalls, removewalls])
        
        // create port and movement and spawn port
        var spawn = SKAction.run({() in self.makePort()})
        let delay = SKAction.wait(forDuration: TimeInterval(duration/11))
        run(spawn)
        
        port = SKNode()
        moving.addChild(port)
        
        // spawn the walls
        spawn = SKAction.run({() in self.makeWalls()})
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        run(spawnThenDelayForever)
        
        // spawn the ship
        makeShip()
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.isDynamic = false
        
        // initialize label and create a label which holds the score
        scoreLabelNode = SKLabelNode(fontNamed:"Virgo01")
        scoreLabelNode.position = CGPoint( x: -width*0.9, y: height*0.75)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(playerScore)
        self.addChild(scoreLabelNode)
        
        let backgroundMusic = SKAudioNode(fileNamed: "gameMusic.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    //MARK: - Custom Methods

    // create and add ship
    func makeShip() {

        let shipTexture = SKTexture(imageNamed: "ship.png")
        shipTexture.filteringMode = .nearest
        ship = SKSpriteNode(texture: shipTexture)
        ship.position = CGPoint(x: -width/2, y: 0)
        ship.anchorPoint = CGPoint(x: 0, y: 0)
        
        self.addChild(ship)
        
        // physics for ship
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 30, y: 6), CGPoint(x: 58, y: 13), CGPoint(x: 44, y: 16), CGPoint(x: 1, y: 18)])
        path.closeSubpath()
        ship.physicsBody = SKPhysicsBody(polygonFrom: path)
        ship.physicsBody?.isDynamic = true
        ship.physicsBody?.allowsRotation = false
        // check for ship collisions
        ship.physicsBody?.categoryBitMask = shipCategory
        ship.physicsBody?.collisionBitMask = wallCategory
        ship.physicsBody?.contactTestBitMask = wallCategory
        
        // get and add warp trail emitter node
        if let warp: SKEmitterNode = SKEmitterNode(fileNamed: "warpTrail.sks") {
            warp.position = CGPoint(x: 2, y: 17)
            warp.particleSize = CGSize(width: warp.particleSize.width*2 ,height: warp.particleSize.height)
            warp.targetNode = self

            //warp.particlePositionRange = CGVector(dx: width*2, dy: height*2)
            warp.zPosition = -1
            ship.addChild(warp)
        }
    }
    
    // creates top and bottom starting area and adds them as child nodes
    func makePort() {
        let lines = SKNode()
        lines.position = CGPoint(x: -width, y: -height)
        //lines.zPosition = -1
        let heights: [CGFloat] = [0, height*1.5/5, height*8.5/5, height*2]
        
        // Create lines with SKShapeNode
        for y in heights {
            // Large girder
            let line = SKShapeNode()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width*2 - wallWidth, y: y))
            line.path = path.cgPath
            line.strokeColor = UIColor(red: 108/255,green: 96/255,blue: 102/255,alpha: 1.0)
            line.lineWidth = 25
            line.zPosition = 2
            
            // Girder indent
            let inLine = line.copy() as! SKShapeNode
            //let inPath = path.copy() as! UIBezierPath
            inLine.strokeColor = UIColor(red: 133/255,green: 121/255,blue: 126/255,alpha: 1.0)
            inLine.lineWidth = 15
            inLine.zPosition = 3
            lines.addChild(inLine)
            lines.addChild(line)
        }
        
        // Collision box for top beam
        let topBeam = SKSpriteNode(color: UIColor.clear, size: CGSize(width: width*2 - wallWidth, height: height*1.5/5))
        topBeam.anchorPoint = CGPoint(x: 0, y: 0)
        topBeam.position = CGPoint(x: 0, y: heights[2])
        var center: CGPoint = CGPoint(x: topBeam.size.width*(0.5),y: topBeam.size.height*(0.5)-12.5)
        topBeam.physicsBody = SKPhysicsBody(rectangleOf: topBeam.size, center: center)
        topBeam.physicsBody?.isDynamic = false
        topBeam.physicsBody?.categoryBitMask = wallCategory
        topBeam.physicsBody?.contactTestBitMask = shipCategory
        topBeam.physicsBody?.collisionBitMask = wallCategory
        lines.addChild(topBeam)
        
        // Collision box for bot beam
        let botBeam = SKSpriteNode(color: UIColor.clear, size: CGSize(width: width*2 - wallWidth, height: heights[1]))
        botBeam.anchorPoint = CGPoint(x: 0, y: 0)
        botBeam.position = CGPoint(x: 0, y: 0)
        center = CGPoint(x: botBeam.size.width*(0.5),y: botBeam.size.height*(0.5)+12.5) // add half the line width
        botBeam.physicsBody = SKPhysicsBody(rectangleOf: botBeam.size, center: center)
        botBeam.physicsBody?.isDynamic = false
        botBeam.physicsBody?.categoryBitMask = wallCategory
        botBeam.physicsBody?.contactTestBitMask = shipCategory
        botBeam.physicsBody?.collisionBitMask = wallCategory
        lines.addChild(botBeam)
        
        let sections = 17
        for index in 0..<sections {
            let backY = index % 2 == 1 ? height*1.5/5 : 0
            let frontY = index % 2 == 1 ? 0 : height*1.5/5
            let backX = (width*2 - wallWidth - 10)*CGFloat(index)/CGFloat(sections)
            let frontX = (width*2 - wallWidth - 10)*CGFloat(index+1)/CGFloat(sections)
            let topLine = SKShapeNode()
            let topPath = UIBezierPath()
            // Top diagonal girders
            topPath.move(to: CGPoint(x: backX, y: backY + height*8.5/5))
            topPath.addLine(to: CGPoint(x: frontX, y: frontY + height*8.5/5))
            topLine.path = topPath.cgPath
            topLine.strokeColor = UIColor(red: 64/255,green: 58/255,blue: 61/255,alpha: 1.0)
            topLine.lineCap = .round
            topLine.lineWidth = 10
            topLine.zPosition = 1
            lines.addChild(topLine)
            // Top rivets
            let topCircle = SKShapeNode(circleOfRadius: 5)
            topCircle.position = CGPoint(x: frontX, y: frontY + height*8.5/5)
            topCircle.zPosition = 3
            topCircle.fillColor = UIColor(red: 84/255,green: 80/255,blue: 83/255,alpha: 1.0)
            topCircle.glowWidth = 0.1
            topCircle.strokeColor = UIColor(red: 53/255,green: 51/255,blue: 52/255,alpha: 1.0)
            lines.addChild(topCircle)
            // Bottom diagonal girders
            let botLine = topLine.copy() as! SKShapeNode
            let botPath = UIBezierPath()
            botPath.move(to: CGPoint(x: backX, y: backY))
            botPath.addLine(to: CGPoint(x: frontX, y: frontY))
            botLine.path = botPath.cgPath
            lines.addChild(botLine)
            // Bottom rivets
            let botCircle = topCircle.copy() as! SKShapeNode
            topCircle.position = CGPoint(x: frontX, y: frontY)
            lines.addChild(botCircle)
        }
        
        lines.run(moveAndRemoveWalls)
        port.addChild(lines)
    }
    
    // creates the top and bottom walls and adds them as child nodes
    func makeWalls() {
        let wallPair = SKNode()
        wallPair.position = CGPoint(x: width + wallWidth, y: 0)
        wallPair.zPosition = 0
        
        let newColor = updateColor()
        let wiggle = updateYAndWiggle()
        
        let topWall = SKSpriteNode(color: newColor, size: CGSize(width: wallWidth, height: 400))
        topWall.anchorPoint = CGPoint(x: 0, y: 0)
        topWall.position = CGPoint(x: 0, y: topY + wiggle.0) // lastY + wiggle
        var center: CGPoint = CGPoint(x: topWall.size.width*(0.5),y: topWall.size.height*(0.5))
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size, center: center)
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.categoryBitMask = wallCategory
        topWall.physicsBody?.contactTestBitMask = shipCategory
        topWall.physicsBody?.collisionBitMask = wallCategory
        wallPair.addChild(topWall)
        
        let botWall = SKSpriteNode(color: newColor, size: CGSize(width: wallWidth, height: 300))
        botWall.anchorPoint = CGPoint(x: 0, y: 1.0)
        botWall.position = CGPoint(x: 0, y: botY + wiggle.1) // lastY - wallGap - wiggle
        center = CGPoint(x: botWall.size.width*(0.5),y: botWall.size.height*(0.5-botWall.anchorPoint.y))
        botWall.physicsBody = SKPhysicsBody(rectangleOf: botWall.size, center: center)
        botWall.physicsBody?.isDynamic = false
        botWall.physicsBody?.categoryBitMask = wallCategory
        botWall.physicsBody?.contactTestBitMask = shipCategory
        botWall.physicsBody?.collisionBitMask = wallCategory
        
        wallPair.addChild(botWall)
        
        let contactNode = SKNode()
        contactNode.position = CGPoint(x: 0, y: 0)
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: self.frame.height))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = shipCategory
        contactNode.physicsBody?.collisionBitMask = scoreCategory
        wallPair.addChild(contactNode)
        
        wallPair.run(moveAndRemoveWalls)
        walls.addChild(wallPair)
    }
    
    // Updates the last top and bottom heights and returns a slight variance to use as random, organic padding
    func updateYAndWiggle() -> (CGFloat, CGFloat) {
        // create change and update topY with result
        var change: CGFloat = CGFloat(arc4random_uniform(2)) == 1 ? 13.0 : -14.0
        var newY = topY + change
        var test = newY >= maxGap! || newY <= minGap!
        topY = test ? topY - change : topY + change
        
        // create wiggle for top
        var wiggle = CGFloat(arc4random_uniform(5))
        var pole: CGFloat = CGFloat(arc4random_uniform(2)) == 1 ? 1 : -1
        newY = topY + wiggle*pole
        test = newY >= maxGap! || newY <= minGap!
        let wiggleTop = test ? -wiggle : wiggle
        
        // create change and update botY with result
        change = CGFloat(arc4random_uniform(2)) == 1 ? 14.0 : -13.0
        newY = botY + change
        test = newY <= -maxGap! || newY >= -minGap!
        botY = test ? botY - change : botY + change
        
        // create wiggle for bottom
        wiggle = CGFloat(arc4random_uniform(5))
        pole = CGFloat(arc4random_uniform(2)) == 1 ? 1 : -1
        newY = botY + wiggle
        test = newY >= -minGap! || newY <= -maxGap!
        let wiggleBot = test ? -wiggle : wiggle
        
        return (wiggleTop, wiggleBot)
    }
    
    // Checks the lastColor used, and then turns a UIColor. Cycles R->G->B->R...
    func updateColor() -> UIColor{
        // if lastColor exists and it's topped out at 200, switch color, otherwise increase it
        if lastColor != nil {
            if lastRGB == 200.0 {
                lastRGB = 0.0
                if lastColor == color.red { lastColor = color.green }
                else if lastColor == color.green { lastColor = color.blue }
                else { lastColor = color.red }
            } else {
                lastRGB += 10.0
            }
        } else {
            lastColor = color.red
            lastRGB += 10.0
        }
        
        var newColor: UIColor
        
        // create our new color based on last color. Order: R up G down, G up B down, B up R down
        if lastColor == color.red { newColor = UIColor(red: lastRGB/255, green: (200-lastRGB)/255, blue: 200/255, alpha: 1.0) }
        else if lastColor == color.green { newColor = UIColor(red: 200/255, green: lastRGB/255, blue: (200-lastRGB)/255, alpha: 1.0) }
        else { newColor = UIColor(red: (200-lastRGB)/255, green: 200/255, blue: lastRGB/255, alpha: 1.0) }
        return newColor
    }
    
    func scoreGame() {
        let defaults = UserDefaults.standard
        if var scores = defaults.array(forKey: "highScores") {
            print("Old Scores: \(scores)")
            
            var right = scores.count
            var left = 0
            
            while (left < right) {
                let middle: Int = (left + right)/2
                if (playerScore > scores[middle] as! Int) {
                    right = middle
                } else {
                    left = middle + 1
                }
            }
            
            scores.insert(playerScore, at: left)
            scores.remove(at: 15)
            defaults.set(scores, forKey: "highScores")
            print("New Scores: \(scores)")
            
        }
    }

    //MARK: - Actions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if moving.speed > 0  {

        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch ends */
        if moving.speed > 0  {

                for touch: AnyObject in touches {
                    let location = touch.location(in: self)
                    if location.x > 0 {
                        print("Boost")
                        var sound = "boost_2.m4a"
                        let number = arc4random_uniform(3)
                        if number == 0 { sound = "boost_1.m4a"}
                        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
                        var ship2 = SKSpriteNode()
                        let shipTexture = SKTexture(imageNamed: "ship.png")
                        shipTexture.filteringMode = .nearest
                        ship2 = SKSpriteNode(texture: shipTexture)
                        ship2.position = ship.position
                        ship2.anchorPoint = CGPoint(x: 0, y: 0)
                        self.addChild(ship2)
                        ship2.run(SKAction.fadeOut(withDuration: 0.4), completion: {() -> Void in ship2.removeFromParent()})
                        
                        let boost = SKAction.sequence([
                            SKAction.moveBy(x: 140, y: 0, duration: 0.2),
                            //SKAction.wait(forDuration: 0.1),
                            SKAction.moveBy(x: -140, y: 0, duration: 0.45)
                            ])
                        ship.run(boost)
                    }
                    else {
                        ship.physicsBody?.velocity = CGVector(dx: 0, dy: -1)
                        ship.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1.5))
                    }
                }
        }
    }
    
    //MARK: - Frame Update
    
    override func update(_ currentTime: TimeInterval) {
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}

//MARK: - Physics Delegate Extension
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if moving.speed > 0 {
            // check if ship made it through
            if ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
                // Ship has contact with score entity
                playerScore = playerScore + 1
                scoreLabelNode.text = String(playerScore)
            } else {
            
                print("Crash!")
                scoreGame()
                let reveal = SKTransition.fade(with: .white, duration: 0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false, delegate: vcDelegate)
                view?.presentScene(gameOverScene, transition: reveal)
            }

        }
    }
}

