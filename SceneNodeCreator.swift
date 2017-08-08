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

enum ArrowDirection {
    case towards
    case backwards
    case left
    case right
}

class SceneNodeCreator {
    
    class func getGeometryNode(type : GeometryNode, position : SCNVector3, text : String? = nil, imageName : String? = nil) -> SCNNode {
        var geometry : SCNGeometry!
        switch type {
        case .Box:          geometry = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.2)
        case .Pyramid:      geometry = SCNPyramid(width: 0.5, height: 0.5, length: 0.5)
        case .Capsule:      geometry = SCNCapsule(capRadius: 0.5, height: 0.5)
        case .Cone:         geometry = SCNCone(topRadius: 0.0, bottomRadius: 0.3, height: 0.5)
        case .Cylinder:     geometry = SCNCylinder(radius: 0.1, height: 0.5)
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
    
    class func createNodeWithImage(image : UIImage, position : SCNVector3 ) -> SCNNode {
        let plane = SCNPlane(width: image.size.width/2, height: image.size.height / 2)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        let node = SCNNode(geometry: plane)
        node.position = position
        return node
    }
    
    // arrow node
    class func getArrow(position : SCNVector3 , direction : ArrowDirection ) -> SCNNode {
        let color = UIColor.getRandomColor()
        let cylinder = SCNCylinder(radius: 0.1, height: 0.6)
        cylinder.firstMaterial?.diffuse.contents = color
        let cylinderNode = SCNNode(geometry: cylinder)
        
        let pyramid = SCNPyramid(width: 0.5, height: 0.5, length: 0.5)
        pyramid.firstMaterial?.diffuse.contents = color
        let pyramidNode = SCNNode(geometry: pyramid)
        pyramidNode.position = position
        pyramidNode.addChildNode(cylinderNode)
        
        let rotation = CABasicAnimation(keyPath: "rotation")
        switch direction {
            case .left:
                rotation.fromValue = SCNVector4Make(0, 0, 1, 0)
                rotation.toValue = SCNVector4Make(0, 0, 1, Float(Double.pi / 2 )) // Anti-clockwise 90 degree around z-axis
                pyramidNode.rotation = SCNVector4Make(0, 0, 1, Float(Double.pi / 2 ))
            case .right:
                rotation.fromValue = SCNVector4Make(0, 0, 1, 0)
                rotation.toValue = SCNVector4Make(0, 0, 1, -Float(Double.pi / 2 )) // clockwise 90 degree around z-axis
                pyramidNode.rotation = SCNVector4Make(0, 0, 1, -Float(Double.pi / 2 ))
            case .towards:
                rotation.fromValue = SCNVector4Make(1, 0, 0, 0)
                rotation.toValue = SCNVector4Make(1, 0, 0, -Float(Double.pi / 2 ))  // clockwise 90 degree around x-axis
                pyramidNode.rotation = SCNVector4Make(1, 0, 0, -Float(Double.pi / 2 ))
            case .backwards:
                rotation.fromValue = SCNVector4Make(1, 0, 0, 0)
                rotation.toValue = SCNVector4Make(1, 0, 0, Float(Double.pi / 2 )) // anti-clockwise 90 degree around x-axis
                pyramidNode.rotation = SCNVector4Make(1, 0, 0, Float(Double.pi / 2 ))
        }
        rotation.duration = 2.0
        pyramidNode.addAnimation(rotation, forKey: "Rotate it")
        
        return pyramidNode
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
    
    // Scene node
    class func createSceneNode(sceneName : String , position : SCNVector3) -> SCNNode {
        if let scene = SCNScene(named:sceneName) {
            let sceneNode = scene.rootNode.childNodes.first ?? SCNNode()
            sceneNode.position = position
            return sceneNode
        }
        return SCNNode()
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
   
    class func axesNode(quiverLength: CGFloat, quiverThickness: CGFloat) -> SCNNode {
        let quiverThickness = (quiverLength / 50.0) * quiverThickness
        let chamferRadius = quiverThickness / 2.0
        
        let xQuiverBox = SCNBox(width: quiverLength, height: quiverThickness, length: quiverThickness, chamferRadius: chamferRadius)
        xQuiverBox.firstMaterial?.diffuse.contents = UIColor.red
        let xQuiverNode = SCNNode(geometry: xQuiverBox)
        xQuiverNode.position = SCNVector3Make(Float(quiverLength / 2.0), 0.0, 0.0)
        
        let yQuiverBox = SCNBox(width: quiverThickness, height: quiverLength, length: quiverThickness, chamferRadius: chamferRadius)
        yQuiverBox.firstMaterial?.diffuse.contents = UIColor.green
        let yQuiverNode = SCNNode(geometry: yQuiverBox)
        yQuiverNode.position = SCNVector3Make(0.0, Float(quiverLength / 2.0), 0.0)
        
        let zQuiverBox = SCNBox(width: quiverThickness, height: quiverThickness, length: quiverLength, chamferRadius: chamferRadius)
        zQuiverBox.firstMaterial?.diffuse.contents = UIColor.blue
        let zQuiverNode = SCNNode(geometry: zQuiverBox)
        zQuiverNode.position = SCNVector3Make(0.0, 0.0, Float(quiverLength / 2.0))
        
        let quiverNode = SCNNode()
        quiverNode.addChildNode(xQuiverNode)
        quiverNode.addChildNode(yQuiverNode)
        quiverNode.addChildNode(zQuiverNode)
        quiverNode.name = "Axes"
        return quiverNode
    }

    
    // Temporary Scene Graph
    class func sceneSetUp() -> SCNScene {
        let scene = SCNScene()
        scene.rootNode.addChildNode(SceneNodeCreator.getGeometryNode(type: .Box, position: SCNVector3Make(-2, 0, -1), text: "Hi"))
        scene.rootNode.addChildNode(SceneNodeCreator.getGeometryNode(type: .Capsule, position: SCNVector3Make(-1, 0, -1), text: "Hi" ))
        scene.rootNode.addChildNode(SceneNodeCreator.getArrow(position: SCNVector3Make(0, 0, -2), direction: .right))
        scene.rootNode.addChildNode(SceneNodeCreator.createSceneNode(sceneName: "art.scnassets/ship.scn", position:  SCNVector3Make(1, 0, -1)))
        scene.rootNode.addChildNode(SceneNodeCreator.getGeometryNode(type: .Cone, position: SCNVector3Make(2, 0, -1),text: "Hi"))
        scene.rootNode.addChildNode(SceneNodeCreator.getGeometryNode(type: .Pyramid, position: SCNVector3Make(3, 0, -1),text: "Hi"))
        //scene.rootNode.addChildNode(SceneNodeCreator.axesNode(quiverLength: 5, quiverThickness: 1))
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

