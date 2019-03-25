//
//  GameScene.swift
//  EndlessRunner
//
//  Created by Himauli Patel on 2019-02-18.
//  Copyright © 2019 Himauli Patel. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    let dinosaur = SKSpriteNode(imageNamed: "dinosaur2")
    let background = SKSpriteNode(imageNamed: "BackgroundEndlessRunner")
    let cactus = SKSpriteNode(imageNamed: "cactus")
    var bomb = SKSpriteNode(imageNamed: "bomb")
    var bird = SKSpriteNode(imageNamed: "goose")
    var backgroundNext : SKSpriteNode
    
     // For Collision
    let dinosaurCategory: UInt32 = 0x1 << 1
    let cactusCategory: UInt32 = 0x1 << 2
    let birdCategory: UInt32 = 0x1 << 4
    
    //MARK: variable for timer
    var cactusTimer: Timer?
    var bombTimer: Timer?
    var birdTimer: Timer?
    
    let DINOSAUR_SPEED:CGFloat = 20
    
    var yn:CGFloat = 0
    var xn:CGFloat = 0
    
    var deltaTime : TimeInterval = 0
    var lastFrameTime : TimeInterval = 0
    
    let playSound = SKAudioNode(fileNamed: "BackgroundMusic/Victory.mp3")
//    let bombSound = SKAudioNode(fileNamed: "BackgroundMusic/BombBlast.wav")
    
    //MARK: variable for score
    var scoreLabel: SKLabelNode!
    var score = 0{
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // variables for dealing with game state
    var gameInProgress = true
    
    
    override init(size: CGSize) {
        
        background.position = CGPoint(x:size.width/1.8, y:size.height/1.8)
        background.size = CGSize(width: size.width, height: size.height)
        
        backgroundNext = background.copy() as! SKSpriteNode
        backgroundNext.position =
            CGPoint(x: background.position.x + background.size.width,
                    y: background.position.y)
        
        super.init(size: size)
        
        physicsWorld.contactDelegate = self
        addChild(background)
        addChild(backgroundNext)
        
        
        
        // Add a dinosaur to the screen
        self.dinosaur.position = CGPoint(x: size.width*0.10, y: size.height/2 - 100)
        
//        print("Dinosaur x position : \(size.width*0.10)")
//        print("Dinosaur y position : \(size.height/2 - 100)")
        
        dinosaur.size = CGSize(width: 100, height: 100)
        dinosaur.physicsBody = SKPhysicsBody(rectangleOf:self.dinosaur.frame.size)
        dinosaur.physicsBody = SKPhysicsBody(texture: self.dinosaur.texture!, size: self.dinosaur.size)
        dinosaur.physicsBody?.affectedByGravity = false
        self.dinosaur.physicsBody!.isDynamic = false
        
         cactus.physicsBody = SKPhysicsBody(texture: self.cactus.texture!, size: self.cactus.size)
         dinosaur.physicsBody?.affectedByGravity = false
         self.dinosaur.physicsBody!.isDynamic = false
        
        dinosaur.physicsBody?.categoryBitMask = dinosaurCategory
        dinosaur.physicsBody?.contactTestBitMask = cactusCategory
        
        addChild(dinosaur)
        
//        print(dinosaur.size)
        
        //Play background music
        playSound.run(SKAction.play())
        self.addChild(playSound)
        
        // MARK: Score lable
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontColor = UIColor.black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: size.width*0.10, y: size.height/2 + 150)
        addChild(scoreLabel)
        
        cactusTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(timer) in self.createCactus()})
        
        birdTimer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true, block: {(timer) in self.createBird()})
        
        bombTimer = Timer.scheduledTimer(withTimeInterval: 50, repeats: false, block: {(timer) in self.generateBomb()})
        
//        print("Width & height :\(size.width) \(size.height)")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveSprite(sprite : SKSpriteNode,
                    nextSprite : SKSpriteNode, speed : Float) -> Void {
        var newPosition = CGPoint()
        
        // For both the sprite and its duplicate:
        for spriteToMove in [sprite, nextSprite] {
            
            // Shift the sprite leftward based on the speed
            newPosition = spriteToMove.position
            newPosition.x -= CGFloat(speed * Float(deltaTime))
            spriteToMove.position = newPosition
            
            // If this sprite is now offscreen (i.e., its rightmost edge is
            // farther left than the scene's leftmost edge):
            if spriteToMove.frame.maxX < self.frame.minX {
                
                // Shift it over so that it's now to the immediate right
                // of the other sprite.
                // This means that the two sprites are effectively
                // leap-frogging each other as they both move.
                spriteToMove.position =
                    CGPoint(x: spriteToMove.position.x +
                        spriteToMove.size.width * 2,
                            y: spriteToMove.position.y)
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        jump()
    }
    
    func jump() {
        dinosaur.texture = SKTexture(imageNamed: "dinosaur2")
        let moveUp = SKAction.moveBy(x: 0, y: size.height/2, duration: 0.5)
        let moveDown = SKAction.moveTo(y: size.height/2 - 100, duration: 0.5)
        let sequence = SKAction.sequence([moveUp, moveDown])
        dinosaur.run(sequence)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
      
        // Called before each frame is rendered
        if lastFrameTime <= 0 {
            lastFrameTime = currentTime
        }
        
        // Update delta time
        deltaTime = currentTime - lastFrameTime
        
        lastFrameTime = currentTime
      
        // Next, move each of the four pairs of sprites.
        // Objects that should appear move slower than foreground objects.
        self.moveSprite(sprite: background, nextSprite:backgroundNext, speed:250.0)
       
        
    }
    
    @objc func calculateScore() {
        
        self.score = self.score + 5
        scoreLabel?.text = "Score: \(score)"
        print("New Score: \(self.score)")
        
        // MARK: Winner Condition
        if score == 30 {
            print("You win!!!")
            
            let winSound = SKAction.playSoundFileNamed("BackgroundMusic/Win.wav",waitForCompletion: false)
            self.run(winSound)
            
            let message = SKLabelNode(text:"Winner! Scored \(score) points")
            message.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
            message.fontSize = 50
            message.fontName = "Chalkduster"
            message.fontColor = UIColor.black
            addChild(message)
            
            newGame()
        }
    }
    
    //MARK: Obstacle generation
    func createCactus()
    {
        let cactcus = SKSpriteNode(imageNamed: "cactus")
        cactcus.size = CGSize(width: 50, height: 70)
        
        let xx = size.width - cactcus.size.width
//        let xx = CGFloat(arc4random_uniform(UInt32((size.width + 200))))
        let yy = size.height/2 - 120
        
//        print("Height: \(size.height)")
//        print("xx : \(xx)")
        
        
        cactcus.position = CGPoint(x: xx , y: yy)
        cactcus.physicsBody = SKPhysicsBody(rectangleOf: cactcus.size)
        cactcus.physicsBody?.affectedByGravity = false
        
        //For collision
        cactcus.physicsBody?.categoryBitMask = cactusCategory
        cactcus.physicsBody?.contactTestBitMask = dinosaurCategory
        cactcus.physicsBody?.collisionBitMask = 0
        
        addChild(cactcus)
        
        //MARK: REMOVE CATCUS
        let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: 3)
        let sequence = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        cactcus.run(sequence)
        
        perform(#selector(calculateScore), with: nil, afterDelay: 3)
//        calculateScore()
    }
    
    // MARK: Moving Obstacle
    func createBird()
    {
        let bird = SKSpriteNode(imageNamed: "goose")
        bird.size = CGSize(width: 50, height: 70)
        
        let xx = size.width
        let yy = size.height/2
//
//        //        print("Height: \(size.height)")
//        //        print("xx : \(xx)")
//
        bird.position = CGPoint(x: xx , y: yy)
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.affectedByGravity = false
        
        //For collision
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = dinosaurCategory
        bird.physicsBody?.collisionBitMask = 0
        
        addChild(bird)
        
        //MARK: REMOVE CATCUS
        var xPosition = CGFloat(arc4random_uniform(UInt32((size.width))))
        print("Bird xPosition: \(xPosition)")
        let yPosition = CGFloat(arc4random_uniform(UInt32((size.height))))
         print("Bird yPosition: \(yPosition)")
        
        if (xPosition < 0)
        {
            xPosition = -xPosition
        }
        
        let moveUp = SKAction.moveBy(x: -xPosition, y: yPosition, duration: 1.5)
        let moveDown = SKAction.moveBy(x: -xPosition, y: -yPosition, duration: 1.5)
        
        let sequence = SKAction.sequence([moveUp, moveDown, SKAction.removeFromParent()])
        bird.run(sequence)
        
    }
    
    // MARK: Destruction item
    func generateBomb()
    {
        var randomX = Int(arc4random_uniform(UInt32(size.width)))
        var randomY = Int(arc4random_uniform(UInt32(size.height)))
        bomb.position = CGPoint(x: size.width - bomb.size.width, y: CGFloat(randomY))
        bomb.size = CGSize(width: 100, height: 100)

        //hitbox for bomb
        let bombHitbox = CGSize(width: bomb.size.width, height: bomb.size.height)
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bombHitbox)
        bomb.physicsBody?.isDynamic = false
        bomb.name = "bomb"

        addChild(bomb)
        
        let bombSound = SKAction.playSoundFileNamed("BackgroundMusic/BombBlast.wav",waitForCompletion: false)
        self.run(bombSound)
        
        gameOver()
       

    }
    
    @objc func newGame() {
        
        let nextScene = GameScene(size: self.scene!.size)
        nextScene.scaleMode = self.scaleMode
        self.view?.presentScene(nextScene, transition: SKTransition.fade(withDuration: 3))

    }

    func gameOver()
    {
        playSound.run(SKAction.stop())
        let gameOverSound = SKAction.playSoundFileNamed("BackgroundMusic/GameOver.wav",waitForCompletion: false)
        self.run(gameOverSound)
        
        print("You lose, try again!")
//        playSound.run(SKAction.stop())
        let message = SKLabelNode(text:"Game Over!")
        message.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
        message.fontSize = 50
        message.fontName = "Chalkduster"
        message.fontColor = UIColor.black
        addChild(message)
        
        self.score = 0
        scoreLabel?.text = "Score: \(score)"
        print("Score Over: \(score)")
        
        perform(#selector(newGame), with: nil, afterDelay: 5)
//        newGame()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        print("Contact!!!")
        
        if contact.bodyA.categoryBitMask == cactusCategory {
            contact.bodyA.node?.removeFromParent()
            dinosaur.removeFromParent()
//            print("Catagory: \(cactusCategory)")
            self.gameOver()
        }
        if contact.bodyB.categoryBitMask == cactusCategory {
            contact.bodyB.node?.removeFromParent()
            dinosaur.removeFromParent()
//            print("Catagory: \(cactusCategory)")
            self.gameOver()
        }
        
        if contact.bodyA.categoryBitMask == birdCategory {
            contact.bodyA.node?.removeFromParent()
            dinosaur.removeFromParent()
            //            print("Catagory: \(cactusCategory)")
            self.gameOver()
        }
        if contact.bodyB.categoryBitMask == birdCategory {
            contact.bodyB.node?.removeFromParent()
            dinosaur.removeFromParent()
            //            print("Catagory: \(cactusCategory)")
            self.gameOver()
        }
        
        
        
    }
    
}
