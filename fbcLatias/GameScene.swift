//
//  GameScene.swift
//  fbcLatias
//
//  Created by Kai Drayton-Yee on 7/11/16.
//  Copyright (c) 2016 Kai Drayton-Yee. All rights reserved.
//
/*
import SpriteKit

class GameScene: SKScene {
override func didMoveToView(view: SKView) {
/* Setup your scene here */
let myLabel = SKLabelNode(fontNamed:"Chalkduster")
myLabel.text = "Hello, World!"
myLabel.fontSize = 45
myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))

self.addChild(myLabel)
}

override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
/* Called when a touch begins */

for touch in touches {
let location = touch.locationInNode(self)

let sprite = SKSpriteNode(imageNamed:"Spaceship")

sprite.xScale = 0.5
sprite.yScale = 0.5
sprite.position = location

let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)

sprite.runAction(SKAction.repeatActionForever(action))

self.addChild(sprite)
}
}

override func update(currentTime: CFTimeInterval) {
/* Called before each frame is rendered */
}
}
*/

import SpriteKit



enum GameSceneState {
	case Active, GameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	var heroTwo: SKSpriteNode!
	var scrollLayer: SKNode!
	var scrollLayerTwo: SKNode!
	var sinceTouch : CFTimeInterval = 0
	let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
	let scrollSpeed: CGFloat = 500
	let scrollSpeedTwo: CGFloat = 100
	var obstacleLayer: SKNode!
	var spawnTimer: CFTimeInterval = 0
	/* UI Connections */
	var buttonRestart: MSButtonNode!
	/* Game management */
	var gameState: GameSceneState = .Active
	var scoreLabel: SKLabelNode!
	var points = 0
	
	
	
	override func didMoveToView(view: SKView) {
  /* Set up your scene here */
		
	//	/* Play SFX */
	//	let backgroundSFX = SKAction.playSoundFileNamed("pokesoundtwo", waitForCompletion: true)
	//	self.runAction(backgroundSFX)
		
  /* Recursive node search for 'hero' (child of referenced node) */
		heroTwo = self.childNodeWithName("//heroTwo") as! SKSpriteNode
		
		/* Set reference to scroll layer node */
		scrollLayer = self.childNodeWithName("scrollLayer")
		
		/* Set reference to scroll layer node */
		scrollLayerTwo = self.childNodeWithName("scrollLayerTwo")
		
		/* Set reference to obstacle layer node */
		obstacleLayer = self.childNodeWithName("obstacleLayer")
		
		/* Set physics contact delegate */
		physicsWorld.contactDelegate = self
		
		/* Set UI connections */
		buttonRestart = self.childNodeWithName("buttonRestart") as! MSButtonNode
		
		/* Setup restart button selection handler */
		buttonRestart.selectedHandler = {
			
			/* Grab reference to our SpriteKit view */
			let skView = self.view as SKView!
			
			/* Load Game scene */
			let scene = GameScene(fileNamed:"GameScene") as GameScene!
			
			/* Ensure correct aspect mode */
			scene.scaleMode = .AspectFill
			
			/* Restart game scene */
			skView.presentScene(scene)
			
		}
///this
		/* Hide restart button */
		buttonRestart.state = .Hidden
		
		scoreLabel = self.childNodeWithName("scoreLabel") as! SKLabelNode
		
		/* Reset Score label */
		scoreLabel.text = String(points)
	}
	
	func didBeginContact(contact: SKPhysicsContact) {
		
		/* Get references to bodies involved in collision */
		let contactA:SKPhysicsBody = contact.bodyA
		let contactB:SKPhysicsBody = contact.bodyB
		
		/* Get references to the physics body parent nodes */
		let nodeA = contactA.node!
		let nodeB = contactB.node!
		
		/* Did our hero pass through the 'goal'? */
		if nodeA.name == "goal" || nodeB.name == "goal" {
			
			/* Increment points */
			points += 1
			
			/* Update score label */
			scoreLabel.text = String(points)
			
			/* We can return now */
			return
		} else if nodeA.name == "roof" || nodeB.name == "roof" {
	
	return
		}
		
  /* Ensure only called while game running */
  if gameState != .Active { return }
		
  /* Hero touches anything, game over */
		
  /* Change game state to game over */
  gameState = .GameOver
		
  /* Stop any new angular velocity being applied */
  heroTwo.physicsBody?.allowsRotation = false
		
  /* Reset angular velocity */
   heroTwo.physicsBody?.angularVelocity = 0
		
  /* Stop hero flapping animation */
  heroTwo.removeAllActions()
		
  /* Show restart button */
  buttonRestart.state = .Active
		
		/* Create our hero death action */
		let heroDeath = SKAction.runBlock({
			
			/* Put our hero face down in the dirt */
			self.heroTwo.zRotation = CGFloat(-90).degreesToRadians()
			/* Stop hero from colliding with anything else */
			self.heroTwo.physicsBody?.collisionBitMask = 0
		})
		/* Load the shake action resource */
		let shakeScene:SKAction = SKAction.init(named: "shakeTwo")!
		
		/* Loop through all nodes  */
		for node in self.children {
			
			/* Apply effect each ground node */
			node.runAction(shakeScene)
		}
		
		/* Run action */
		heroTwo.runAction(heroDeath)
	}
	
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
  /* Called when a touch begins */
		
		/* Disable touch if game state is not active */
		if gameState != .Active { return }
		
		/* Reset velocity, helps improve response against cumulative falling velocity */
		heroTwo.physicsBody?.velocity = CGVectorMake(0, 0)
		
		/* Apply subtle rotation */
	//	heroTwo.physicsBody?.applyAngularImpulse(1)
		
		/* Reset touch timer */
		sinceTouch = 0
		
		/* Play SFX */
		let flapSFX = SKAction.playSoundFileNamed("sfx_flap", waitForCompletion: false)
		self.runAction(flapSFX)
		
  /* Apply vertical impulse */
  heroTwo.physicsBody?.applyImpulse(CGVectorMake(0, 250))
	}
	
	override func update(currentTime: CFTimeInterval) {
  /* Called before each frame is rendered */
		
		/* Skip game update if game no longer active */
		if gameState != .Active { return }
		
  /* Grab current velocity */
  let velocityY = heroTwo.physicsBody?.velocity.dy ?? 0
		
  /* Check and cap vertical velocity */
  if velocityY > 500 {
	heroTwo.physicsBody?.velocity.dy = 400
  }
		/* Apply falling rotation */
		if sinceTouch > 0.1 {
			let impulse = -20000 * fixedDelta
			heroTwo.physicsBody?.applyAngularImpulse(CGFloat(impulse))
		}
		
		/* Clamp rotation */
		heroTwo.zRotation.clamp(CGFloat(-20).degreesToRadians(),CGFloat(30).degreesToRadians())
		heroTwo.physicsBody?.angularVelocity.clamp(-2, 2)
		
		/* Update last touch timer */
		sinceTouch+=fixedDelta
		
		/* Process world scrolling */
		scrollWorld()
		scrollWorldTwo()
		
		/* spawning Obstacles */
		updateObstacles()
		spawnTimer += fixedDelta
	}
	func scrollWorld() {
		/* Scroll World */
		scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
		
		/* Loop through scroll layer nodes */
		for ground in scrollLayer.children as! [SKSpriteNode] {
			
			/* Get ground node position, convert node position to scene space */
			let groundPosition = scrollLayer.convertPoint(ground.position, toNode: self)
			
			/* Check if ground sprite has left the scene */
			if groundPosition.x <= -ground.size.width / 2 {
				
				/* Reposition ground sprite to the second starting position */
				let newPosition = CGPointMake( (self.size.width / 2) + ground.size.width, groundPosition.y)
				
				/* Convert new node position back to scroll layer space */
				ground.position = self.convertPoint(newPosition, toNode: scrollLayer)
			}
		}
	}
	func scrollWorldTwo() {
		/* Scroll World */
		scrollLayerTwo.position.x -= scrollSpeedTwo * CGFloat(fixedDelta)
		
		/* Loop through scroll layer nodes */
		for ground in scrollLayerTwo.children as! [SKSpriteNode] {
			
			/* Get ground node position, convert node position to scene space */
			let groundPosition = scrollLayerTwo.convertPoint(ground.position, toNode: self)
			
			/* Check if ground sprite has left the scene */
			if groundPosition.x <= -ground.size.width / 2 {
				
				/* Reposition ground sprite to the second starting position */
				let newPosition = CGPointMake( (self.size.width / 2) + ground.size.width, groundPosition.y)
				
				/* Convert new node position back to scroll layer space */
				ground.position = self.convertPoint(newPosition, toNode: scrollLayerTwo)
			}
		}
	}
	func updateObstacles() {
		/* Update Obstacles */
		
		obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
		
		/* Loop through obstacle layer nodes */
		for anObstacle in obstacleLayer.children as! [SKReferenceNode] {
			
			/* Get obstacle node position, convert node position to scene space */
			let obstaclePosition = obstacleLayer.convertPoint(anObstacle.position, toNode: self)
			
			/* Check if obstacle has left the scene */
			if obstaclePosition.x <= -270 {
				
				/* Remove obstacle node from obstacle layer */
				anObstacle.removeFromParent()
			}
		}
		/* Time to add a new obstacle? */
		if spawnTimer >= 0.75 {
			
			//my code
			
			
			/* Create a new obstacle reference object using our obstacle resource */
			
			
			//gen ran num 1-7... if ran num =.... set to resourcepath to resourcepathforObstacle...
			
			
			let ranNum = random() % 8
			var resourcePath: String!
			if ranNum <= 1{
	//one is not working....?
				resourcePath = NSBundle.mainBundle().pathForResource("obstacleTwo", ofType: "sks")
				print("onePrint")
			} else if ranNum <= 2{
				resourcePath = NSBundle.mainBundle().pathForResource("obstacleTwo", ofType: "sks")
				print("TwoPrint")
			} else if ranNum <= 3{
				resourcePath = NSBundle.mainBundle().pathForResource("obstacleThree", ofType: "sks")
				print("ThreePrint")
			} else if ranNum <= 4{
				resourcePath = NSBundle.mainBundle().pathForResource("obstacleFour", ofType: "sks")
				print("FourPrint")
			} else if ranNum <= 5{
	//deal with five later....
				resourcePath = NSBundle.mainBundle().pathForResource("obstacleFour", ofType: "sks")
				print("FivePrint")
			} else if ranNum <= 6{
				resourcePath = NSBundle.mainBundle().pathForResource("obstacleSix", ofType: "sks")
				print("Six")
			} else{
				resourcePath = NSBundle.mainBundle().pathForResource("obstacleSeven", ofType: "sks")
				print("seven")
			}
			
			
			
			
			
			let newObstacle = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
			obstacleLayer.addChild(newObstacle)
			
			/* Generate new obstacle position, start just outside screen and with a random y value */
			//let randomPosition = CGPointMake(352, CGFloat.random(min: 234, max: 382))
			
			let position = CGPointMake(352, 0)
			/* Convert new node position back to obstacle layer space */
			newObstacle.position = self.convertPoint(position, toNode: obstacleLayer)
			
			// Reset spawn timer
			spawnTimer = 0
		}
 }
}
