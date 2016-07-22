//
//  MSButtonNode.swift
//  HoppyBunny
//
//  Created by Martin Walsh on 20/02/2016.
//  Copyright (c) 2016 Make School. All rights reserved.
//

import SpriteKit

public enum MSButtonNodeState {
    case Active, Selected, Hidden
}

public class MSButtonNode: SKSpriteNode {
    
    /* Setup a dummy action closure */
    var selectedHandler: () -> Void = { print("No button action set") }
    
    /* Button state management */
    public var state: MSButtonNodeState = .Active {
        didSet {
            switch state {
            case .Active:
                /* Enable touch */
                self.userInteractionEnabled = true
                
                /* Visible */
                self.alpha = 1
                break
            case .Selected:
                /* Semi transparent */
                self.alpha = 0.7
                break
            case .Hidden:
                /* Disable touch */
                self.userInteractionEnabled = false
                
                /* Hide */
                self.alpha = 0
                break
            }
        }
    }
    
    /* Support for NSKeyedArchiver (loading objects from SK Scene Editor */
    required public init?(coder aDecoder: NSCoder) {
        
        /* Call parent initializer e.g. SKSpriteNode */
        super.init(coder: aDecoder)
        
        /* Enable touch on button node */
        self.userInteractionEnabled = true
    }
    
    // MARK: - Mouse handling
  //  override public func mouseDown(theEvent: NSEvent) {
 //       state = .Selected
 //   }
    
 //   override public func mouseUp(theEvent: NSEvent) {
 //       selectedHandler()
 //       state = .Active
//}

}