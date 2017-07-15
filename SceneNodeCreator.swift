//
//  SceneNodeCreator.swift
//  
//
//  Created by Ashis Laha on 14/07/17.
//

import Foundation

class SceneNodeCreator {
    
    class func sceneSetup() -> SCNScene {
        let scene = SCNScene()
        // add Box
        scene.rootNode.addChildNode(createBoxNode())
        
        // add pyramid
        scene.rootNode.addChildNode(createPyramidNode())
        
        // add omni light node
        scene.rootNode.addChildNode(createLightNode())
        
        // add camera node
        scene.rootNode.addChildNode(createCameraNode())
        return scene
    }
    
    // add box node
    class func createBoxNode() -> SCNNode {
        let box = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0.5)
        let node = SCNNode(geometry: box)
        node.position = SCNVector3Make(-1, 1, -1)
        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        return node
    }
    
    // add pyramid node
    class func createPyramidNode() -> SCNNode {
        let pyramid = SCNPyramid(width: 5, height: 5, length: 5)
        pyramid.firstMaterial?.diffuse.contents = UIColor.brown
        pyramid.firstMaterial?.specular.contents = UIColor.blue
        let pyramidNode = SCNNode(geometry: pyramid)
        pyramidNode.position = SCNVector3Make(5, 0, -2)
        return pyramidNode
    }
    
    // add Capsule node
    class func createCapsuleNode() -> SCNNode {
        let cirle = SCNCapsule(capRadius: 5, height: 6)
        cirle.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
        let node = SCNNode(geometry: cirle)
        node.position = SCNVector3Make(20, 5, -10)
        return node
    }
    
    // omni light node
    class func createLightNode() -> SCNNode {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = .omni
        omniLightNode.light?.color = UIColor.white.withAlphaComponent(0.5)
        omniLightNode.position = SCNVector3Make(0, 20, 20)
        return omniLightNode
    }
    
    // Camera node
    class func createCameraNode() -> SCNNode {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 30)
        //cameraNode.camera?.projectionTransform = SCNMatrix4MakeRotation(Double.pi/2, 0, 0, 0)
        return cameraNode
    }
    
    // Get Random Node
    class func getGeometry() -> SCNNode {
        let random = Int(arc4random_uniform(3))
        switch random {
        case 0: return createBoxNode()
        case 1: return createPyramidNode()
        case 2: return createCapsuleNode()
        default: return createCapsuleNode()
        }
    }
}
