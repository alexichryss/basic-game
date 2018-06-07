//
//  SKSpriteNodeExtension.swift
//  GamesPeoplePlay
//
//  Created by Alexi Chryssanthou on 5/31/18.
//  Copyright © 2018 T. Andrew Binkowski. All rights reserved.
//

import SpriteKit

// Attribution: https://stackoverflow.com/questions/28976298/sktexture-from-uiimage-that-respects-aspect-ratio
extension SKSpriteNode {
    
    func aspectFillToSize(_ fillSize: CGSize) {
        
        if texture != nil {
            self.size = texture!.size()
            
            let verticalRatio = (fillSize.height) / self.texture!.size().height
            let horizontalRatio = (fillSize.width) /  self.texture!.size().width

            let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio
            self.setScale(scaleRatio)
        }
    }
    
}
