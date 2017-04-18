//
//  Impetus.swift
//  Impetus
//
//  Created by Nate Parrott on 4/18/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation
import QuartzCore

public class Impetus : NSObject {
    public init(initialPos: CGPoint, onUpdate: @escaping ((CGPoint) -> ())) {
        self.onUpdate = onUpdate
        self.position = initialPos
        super.init()
    }
    
    private let onUpdate: ((CGPoint) -> ())
    
    
    // MARK: Bounds
    
    public var minX: CGFloat?
    public var minY: CGFloat?
    public var maxX: CGFloat?
    public var maxY: CGFloat?
    
    func setBounds(minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat) {
        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY
    }
    
    // MARK: Parameters
    
    public var friction: CGFloat = 0.92
    
    public var position: CGPoint {
        didSet {
            onUpdate(position)
        }
    }
    
    // MARK: Gesture input
    
    public func startGesture(pos: CGPoint) {
        
        gestureActive = true
        decelerating = false
        
        lastPointerPos = pos
        curPointerPos = pos
        
        trackingPoints.removeAll()
        addTrackingPoint(point: pos)
    }
    
    public func updateGesture(pos: CGPoint) {
        tick()
        curPointerPos = pos
        addTrackingPoint(point: lastPointerPos)
        requestTick()
    }
    
    public func endGesture() {
        stopTracking()
    }
    
    // MARK: Internal
    private var gestureActive = false
    private var decelerating = false
    private var curPointerPos = CGPoint.zero
    private var lastPointerPos = CGPoint.zero
    private var trackingPoints = [TrackingPoint]()
    private let stopThreshold: CGFloat = 0.3
    private let bounceDeceleration: CGFloat = 0.04
    private let bounceAcceleration: CGFloat = 0.11
    private let interval: CGFloat = 1.0 / 60
    
    private func addTrackingPoint(point: CGPoint) {
        let time = CFAbsoluteTimeGetCurrent()
        while let firstPoint = trackingPoints.first {
            if time - firstPoint.time <= 0.1 {
                break
            } else {
                trackingPoints.removeFirst()
            }
        }
        trackingPoints.append(TrackingPoint(pos: point, time: time))
    }
    
    private func decelStepAnim() {
        if decelerating {
            let timeScale: CGFloat = 1
            let decel = friction
            decVelocity = CGPoint(x: decVelocity.x * decel, y: decVelocity.y * decel)
            position = CGPoint(x: position.x + decVelocity.x * timeScale, y: position.y + decVelocity.y * timeScale)
            let (diff, inBounds) = checkBounds()
            if (fabs(decVelocity.x) > stopThreshold || fabs(decVelocity.y) > stopThreshold || !inBounds) {
                let reboundAdjust: CGFloat = 2.5
                if diff.x != 0 {
                    if diff.x * decVelocity.x <= 0 {
                        decVelocity.x += diff.x * bounceDeceleration
                    } else {
                        let adjust = diff.x > 0 ? reboundAdjust : -reboundAdjust
                        decVelocity.x = (diff.x + adjust) * bounceAcceleration
                    }
                }
                if diff.y != 0 {
                    if diff.y * decVelocity.y <= 0 {
                        decVelocity.y += diff.y * bounceDeceleration
                    } else {
                        let adjust = diff.y > 0 ? reboundAdjust : -reboundAdjust
                        decVelocity.y = (diff.y + adjust) * bounceAcceleration
                    }
                }
                requestAnimFrame {
                    self.decelStepAnim()
                }
            } else {
                decelerating = false
            }
        }
    }
    
    private var requestedTick = false
    private func requestTick() {
        if !requestedTick {
            requestedTick = true
            requestAnimFrame {
                self.requestedTick = false
                self.tick()
            }
        }
    }
    
    private func requestAnimFrame(callback: @escaping (() -> ())) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(1000 * interval))) { 
            callback()
        }
    }
    
    private func tick() {
        let delta = CGPoint(x: curPointerPos.x - lastPointerPos.x, y: curPointerPos.y - lastPointerPos.y)
        var newPos = CGPoint(x: position.x + delta.x, y: position.y + delta.y)
        
        let (diff, _) = checkBounds()
        if diff.x != 0 {
            newPos.x -= delta.x * dragOutOfBoundsMultiplier(val: diff.x)
        }
        if diff.y != 0 {
            newPos.y -= delta.y * dragOutOfBoundsMultiplier(val: diff.y)
        }
        
        position = newPos
        lastPointerPos = curPointerPos
    }
    
    private struct TrackingPoint {
        let pos: CGPoint
        let time: CFAbsoluteTime
    }
    
    private func stopTracking() {
        gestureActive = false
        addTrackingPoint(point: lastPointerPos)
        startDecelAnimation()
    }
    
    private func startDecelAnimation() {
        let p1 = trackingPoints.first!
        let p2 = trackingPoints.last!
        let delta = CGPoint(x: p2.pos.x - p1.pos.x, y: p2.pos.y - p1.pos.y)
        let timeDelta = (p2.time - p1.time) * 1000
        let d = CGFloat(timeDelta) / 15
        decVelocity = (d == 0) ? CGPoint.zero : CGPoint(x: delta.x / d, y: delta.y / d)
        let (_, inBounds) = checkBounds()
        if (fabs(decVelocity.x) > 1 || fabs(decVelocity.y) > 1 || !inBounds) {
            decelerating = true
            decelStepAnim()
        }
    }
    
    private func checkBounds() -> (diff: CGPoint, inBounds: Bool) {
        var diff = CGPoint.zero
        if let minX = self.minX, position.x < minX {
            diff.x = minX - position.x
        } else if let maxX = self.maxX, position.x > maxX {
            diff.x = maxX - position.x
        }
        if let minY = self.minY, position.y < minY {
            diff.y = minY - position.y
        } else if let maxY = self.maxY, position.y > maxY {
            diff.y = maxY - position.y
        }
        return (diff: diff, inBounds: diff.equalTo(CGPoint.zero))
    }
    
    private func dragOutOfBoundsMultiplier(val: CGFloat) -> CGFloat {
        return 0.000005 * pow(val, 2) + 0.0001 * val + 0.55
    }
    
    private var decVelocity = CGPoint.zero
}
