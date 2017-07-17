//
//  SceneNodeCreator.swift
//
//
//  Created by Ashis Laha on 14/07/17.
//

import Foundation
import SceneKit

enum GeometryNode {
    case Box
    case Pyramid
    case Capsule
    case Cone
    case Cylinder
}

class SceneNodeCreator {
    
    class func getGeometryNode(type : GeometryNode, position : SCNVector3, text : String? = nil, imageName : String? = nil) -> SCNNode {
        var geometry : SCNGeometry!
        switch type {
        case .Box:          geometry = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.2)
        case .Pyramid:      geometry = SCNPyramid(width: 0.5, height: 0.5, length: 0.5)
        case .Capsule:      geometry = SCNCapsule(capRadius: 0.5, height: 0.5)
        case .Cone:         geometry = SCNCone(topRadius: 0.0, bottomRadius: 0.3, height: 0.5)
        case .Cylinder:     geometry = SCNCylinder(radius: 0.5, height: 0.5)
        }
        
        if let imgName = imageName , let image =  UIImage(named: imgName) {
             geometry.firstMaterial?.diffuse.contents = image
        } else if let txt = text, let img = imageWithText(text:txt, imageSize: CGSize(width: 1024, height: 1024), backgroundColor: UIColor.getRandomColor()) {
            geometry.firstMaterial?.diffuse.contents = img
        } else {
            geometry.firstMaterial?.diffuse.contents = UIColor.getRandomColor()
        }
        geometry.firstMaterial?.specular.contents = UIColor.getRandomColor()
        let node = SCNNode(geometry: geometry)
        node.position = position
        return node
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
    
    // plane node
    class func createPlane(position : SCNVector3) -> SCNNode {
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let shipNode = scene.rootNode.childNodes.first ?? SCNNode()
        shipNode.position = position
        return shipNode
    }
    
    // create car
    class func createCar(position : SCNVector3) -> SCNNode {
        let scene = SCNScene(named: "art.scnassets/car.scn")!
        let shipNode = scene.rootNode.childNodes.first ?? SCNNode()
        shipNode.position = position
        return shipNode
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
    
    // Temporary SceneSetup
    class func sceneSetUp() -> SCNScene {
        let scene = SCNScene()
        scene.rootNode.addChildNode(SceneNodeCreator.getGeometryNode(type: .Box, position: SCNVector3Make(-2, 0, -1)))
        scene.rootNode.addChildNode(SceneNodeCreator.getGeometryNode(type: .Pyramid, position: SCNVector3Make(1, 0, -1)))
        scene.rootNode.addChildNode(SceneNodeCreator.getGeometryNode(type: .Capsule, position: SCNVector3Make(-1, 0, -1)))
        scene.rootNode.addChildNode(SceneNodeCreator.getGeometryNode(type: .Cone, position: SCNVector3Make(2, 0, -1)))
        scene.rootNode.addChildNode(SceneNodeCreator.createPlane(position: SCNVector3Make(0, 0, -1)))
        //scene.rootNode.addChildNode(SceneNodeCreator.createCar(position: SCNVector3Make(0, 0, -1)))
        return scene
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

