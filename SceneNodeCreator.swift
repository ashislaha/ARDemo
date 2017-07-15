//
//  SceneNodeCreator.swift
//
//
//  Created by Ashis Laha on 14/07/17.
//

import Foundation
import SceneKit

class SceneNodeCreator {
    
    class func sceneSetUp() -> SCNScene {
        let scene = SCNScene() //SCNScene(named: "art.scnassets/ship.scn")!
        scene.rootNode.addChildNode(SceneNodeCreator.createBoxNode(position: SCNVector3Make(0, 0, -1)))
        scene.rootNode.addChildNode(SceneNodeCreator.createPyramidNode(position: SCNVector3Make(1, 0, -1)))
        scene.rootNode.addChildNode(SceneNodeCreator.createCapsuleNode(position: SCNVector3Make(-1, 0, -1)))
        scene.rootNode.addChildNode(SceneNodeCreator.createCameraNode(position: SCNVector3Make(0, 0, 20)))
        return scene
    }
    
    // box node
    class func createBoxNode(position : SCNVector3) -> SCNNode {
        let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.2)
        box.firstMaterial?.diffuse.contents = UIColor.getRandomColor()
        box.firstMaterial?.specular.contents = UIColor.getRandomColor()
        
        let node = SCNNode(geometry: box)
        node.position = position
        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        return node
    }
    
    // pyramid node
    class func createPyramidNode(position : SCNVector3) -> SCNNode {
        let pyramid = SCNPyramid(width: 0.5, height: 0.5, length: 0.5)
        pyramid.firstMaterial?.diffuse.contents = UIColor.getRandomColor()
        pyramid.firstMaterial?.specular.contents = UIColor.getRandomColor()
        let pyramidNode = SCNNode(geometry: pyramid)
        pyramidNode.position = position
        return pyramidNode
    }
    
    // Capsule node
    class func createCapsuleNode(position : SCNVector3, text : String? = nil) -> SCNNode {
        let cirle = SCNCapsule(capRadius: 0.5, height: 0.5)
        if let txt = text, let img = imageWithText(text:txt, imageSize: CGSize(width: 1024, height: 1024), backgroundColor: UIColor.getRandomColor()) {
            cirle.firstMaterial?.diffuse.contents = img
        } else {
            cirle.firstMaterial?.diffuse.contents = UIColor.getRandomColor()
        }
        cirle.firstMaterial?.specular.contents = UIColor.getRandomColor()
        let capsuleNode = SCNNode(geometry: cirle)
        capsuleNode.position = position
        return capsuleNode
    }
    
    // Camera node
    class func createCameraNode(position : SCNVector3) -> SCNNode {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = position
        return cameraNode
    }
    
    // omni light node
    class func createLightNode(position : SCNVector3) -> SCNNode {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = .omni
        omniLightNode.light?.color = UIColor.white.withAlphaComponent(0.5)
        omniLightNode.position = position
        return omniLightNode
    }
    
    
    // Get Random Node
    class func getGeometry(position : SCNVector3) -> SCNNode {
        let random = Int(arc4random_uniform(3))
        switch random {
        case 0: return createBoxNode(position: position)
        case 1: return createPyramidNode(position: position)
        case 2: return createCapsuleNode(position: position)
        default: return createBoxNode(position: position)
        }
    }
    
    // Image with Text
    class func imageWithText(text:String, fontSize:CGFloat = 150, fontColor: UIColor = .black, imageSize:CGSize, backgroundColor:UIColor) -> UIImage? {
        let imageRect = CGRect(origin: CGPoint.zero, size: imageSize)
        UIGraphicsBeginImageContext(imageSize)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Fill the background with a color
        context.setFillColor(backgroundColor.cgColor)
        context.fill(imageRect)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // Define the attributes of the text
        let attributes : [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : UIFont(name: "TimesNewRomanPS-BoldMT", size:fontSize) ?? UIFont.italicSystemFont(ofSize: fontSize),
            NSAttributedStringKey.paragraphStyle : paragraphStyle,
            NSAttributedStringKey.foregroundColor : fontColor
        ]
        
        // Determine the width/height of the text for the attributes
        let textSize = text.size(withAttributes: attributes)
        
        // Draw text in the current context
        text.draw(at: CGPoint(x: imageSize.width/2 - textSize.width/2, y: imageSize.height/2 - textSize.height/2), withAttributes: attributes)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return nil
    }
}

extension UIColor {
    class func getRandomColor() -> UIColor {
        let random = Int(arc4random_uniform(8))
        switch random {
        case 0: return UIColor.red
        case 1: return UIColor.brown
        case 2: return UIColor.green
        case 3: return UIColor.yellow
        case 4: return UIColor.blue
        case 5: return UIColor.purple
        case 6: return UIColor.cyan
        case 7: return UIColor.orange
        default: return UIColor.darkGray
        }
    }
}

