//
//  CGPoint.swift
//  ImageViewer
//
//  Created by Michael Brown on 08/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    
    func inverted() -> CGPoint {
        
        return CGPoint(x: self.y, y: self.x)
    }
}

enum Direction {
    
    case Left, Right, Up, Down, None
}

enum Orientation {
    
    case Vertical, Horizontal, None
}

///Movement can be expressed as a vector in 2D coordinate space where the implied unit is 1 second and the vector point from 0,0 to an actual CGPoint value represents direction and speed. Then we can calculate convenient properties describing the nature of movement.
extension CGPoint {
    
    var direction: Direction {
        
        guard !(self.x == 0 && self.y == 0) else { return .None }
        
        if (abs(self.x) > abs(self.y) && self.x > 0) {
            
            return .Right
        }
        else if (abs(self.x) > abs(self.y) && self.x <= 0) {
            
            return .Left
        }
            
        else if (abs(self.x) <= abs(self.y) && self.y > 0) {
            
            return .Up
        }
            
        else if (abs(self.x) <= abs(self.y) && self.y <= 0) {
            
            return .Down
        }
            
        else {
            
            return .None
        }
    }
    
    var orientation: Orientation {
        
        guard self.direction != .None else { return .None }
        
        if self.direction == .Left || self.direction == .Right {
            return .Horizontal
        }
        else {
            return .Vertical
        }
    }
}