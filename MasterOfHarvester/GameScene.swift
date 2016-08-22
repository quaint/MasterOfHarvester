//
//  GameScene.swift
//  MasterOfHarvester
//
//  Created by Tomasz Wiśniewski on 02/08/16.
//  Copyright (c) 2016 GlobalLogic. All rights reserved.
//

import SpriteKit
import Foundation

enum MoveDirection: Int {
    case forward = 1
    case backward = -1
    case none = 0
}

enum RotateDirection: Int {
    case left = 1
    case right = -1
    case none = 0
}

class GameScene: SKScene {
    
    var rotateDirection = RotateDirection.none
    var moveDirection = MoveDirection.none
    var spaceShip: SKSpriteNode!
    var previousTime: Double = 0
    let rotateSpeed: Double = 1
    let moveSpeed: Double = 50
    let fieldGrid = 10
    let fieldX = 0
    let fieldY = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        myLabel.zPosition = 1
        self.addChild(myLabel)
        
//        let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//        sprite.runAction(SKAction.repeatActionForever(action))
        
        let field: SKNode = SKNode()
        for x in 0..<40 {
            for y in 0..<30 {
                let fieldPart = SKSpriteNode(imageNamed: "Field")
                fieldPart.position = CGPoint(x: x * 20, y: y * 20)
                field.addChild(fieldPart)
            }
        }
        let fieldTexture = self.view?.textureFromNode(field)
        let fieldNode = SKSpriteNode(texture: fieldTexture)
        fieldNode.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.addChild(fieldNode)

        spaceShip = SKSpriteNode(imageNamed:"Combine")
        spaceShip.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        spaceShip.zPosition = 2
        spaceShip.anchorPoint = CGPoint(x: 0.65, y: 0.5)
        self.addChild(spaceShip)
    }
    
    func getPointsForLine(x1: Int, y1: Int, x2: Int, y2: Int) -> [[Int]] {
        var ix0 = (x1 - fieldX) / fieldGrid
        var iy0 = (y1 - fieldY) / fieldGrid
        let ix1 = (x2 - fieldX) / fieldGrid
        let iy1 = (y2 - fieldY) / fieldGrid
            
        let dx = abs(ix1 - ix0)
        let sx = ix0 < ix1 ? 1 : -1
        let dy = abs(iy1 - iy0)
        let sy = iy0 < iy1 ? 1 : -1
        var err = (dx > dy ? dx : -dy) / 2
        var points = [[Int]]()
        while (true) {
            points.append([ix0, iy0])
            if (ix0 == ix1 && iy0 == iy1) {
                break
            }
            let e2 = err
            if (e2 > -dx) {
                err -= dy
                ix0 += sx
            }
            if (e2 < dy) {
                err += dx
                iy0 += sy
            }
        }
        return points
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
//        let location = theEvent.locationInNode(self)
    }
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
        updateKeyboardState()
        let delta = currentTime - previousTime
        let move = CGFloat(Double(moveDirection.rawValue) * delta * moveSpeed)
        let rotate = Double(rotateDirection.rawValue) * delta * rotateSpeed
        previousTime = currentTime
        spaceShip.zRotation = spaceShip.zRotation + CGFloat(rotate)
        spaceShip.position = CGPoint(x: spaceShip.position.x + cos(spaceShip.zRotation) * move,
                                     y: spaceShip.position.y + sin(spaceShip.zRotation) * move)
    }

    func updateKeyboardState() {
        if (Keyboard.sharedKeyboard.justPressed(.Up)) {
            moveDirection = .forward
        } else if (Keyboard.sharedKeyboard.justPressed(.Down)) {
            moveDirection = .backward
        } else if (Keyboard.sharedKeyboard.justPressed(.Left)) {
            rotateDirection = .left
        } else if (Keyboard.sharedKeyboard.justPressed(.Right)) {
            rotateDirection = .right
        }
        
        if (Keyboard.sharedKeyboard.justReleased(.Up, .Down)) {
            moveDirection = .none
        }
        if (Keyboard.sharedKeyboard.justReleased(.Left, .Right)) {
            rotateDirection = .none
        }
    }
    
    override func didFinishUpdate() {
        Keyboard.sharedKeyboard.update()
    }
    
    override func keyUp(theEvent: NSEvent) {
        Keyboard.sharedKeyboard.handleKey(theEvent, isDown: false)
    }
    
    override func keyDown(theEvent: NSEvent) {
        Keyboard.sharedKeyboard.handleKey(theEvent, isDown: true)
    }
}
