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
    var combine: SKSpriteNode!
    var previousTime: Double = 0
    let rotateSpeed: Double = 1
    let moveSpeed: Double = 50
    let gridSize = 20
    let fieldGrid = 10
    let fieldX = 0
    let fieldY = 0
    let combineAngleHeader = CGFloat(60 * M_PI / 180)
    var combineHeaderX1: Int = 0
    var combineHeaderY1: Int = 0
    var combineHeaderX2: Int = 0
    var combineHeaderY2: Int = 0
    var combineRadiusHeader: Double = 0
    let field = SKNode()

    override func didMoveToView(view: SKView) {

//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        myLabel.zPosition = 1
//        self.addChild(myLabel)

//        let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//        sprite.runAction(SKAction.repeatActionForever(action))
        
        for x in 0..<45 {
            for y in 0..<35 {
                let fieldPart = SKSpriteNode(imageNamed: "field")
                fieldPart.position = CGPoint(x: x * gridSize, y: y * gridSize)
                fieldPart.name = "\(x);\(y)"
                field.addChild(fieldPart)
            }
        }
        let fieldTexture = self.view?.textureFromNode(field)
        let fieldNode = SKSpriteNode(texture: fieldTexture)
        fieldNode.position = CGPoint(x:fieldNode.size.width/2, y:fieldNode.size.height/2)
        fieldNode.name = "field"
        self.addChild(fieldNode)

        combine = SKSpriteNode(imageNamed:"combine")
        combine.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        combine.zPosition = 2
        combine.anchorPoint = CGPoint(x: 0.65, y: 0.5)
        combineRadiusHeader = Double(combine.size.height / 2)
        self.addChild(combine)
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
    
    func updateHeader() {
        let diagonalAngle1 = Double(combine.zRotation + combineAngleHeader)
        let diagonalAngle2 = Double(combine.zRotation - combineAngleHeader)
        combineHeaderX1 = Int(cos(diagonalAngle1) * combineRadiusHeader + Double(combine.position.x))
        combineHeaderY1 = Int(sin(diagonalAngle1) * combineRadiusHeader + Double(combine.position.y))
        combineHeaderX2 = Int(cos(diagonalAngle2) * combineRadiusHeader + Double(combine.position.x))
        combineHeaderY2 = Int(sin(diagonalAngle2) * combineRadiusHeader + Double(combine.position.y))
    }
    
    func updateFromCombine() {
        let headerPoints = getPointsForLine(combineHeaderX1, y1: combineHeaderY1, x2: combineHeaderX2, y2: combineHeaderY2)
        for i in 0..<headerPoints.count {
            let points = headerPoints[i]
            let x = points[0]
            let y = points[1]
            let fieldPart = SKSpriteNode(imageNamed: "field_done")
            fieldPart.position = CGPoint(x: x * gridSize, y: y * gridSize)
            fieldPart.zPosition = 2
            fieldPart.name = "\(x);\(y)"
            field.childNodeWithName("\(x);\(y)")?.removeFromParent()
            field.addChild(fieldPart)
        }
        let fieldTexture = self.view?.textureFromNode(field)
        let fieldNode = SKSpriteNode(texture: fieldTexture)
        fieldNode.position = CGPoint(x:fieldNode.size.width/2, y:fieldNode.size.height/2)
        fieldNode.name = "field"
        self.childNodeWithName("field")?.removeFromParent()
        self.addChild(fieldNode)
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
        combine.zRotation = combine.zRotation + CGFloat(rotate)
        combine.position = CGPoint(x: combine.position.x + cos(combine.zRotation) * move,
                                     y: combine.position.y + sin(combine.zRotation) * move)
        updateHeader()
        updateFromCombine()
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
