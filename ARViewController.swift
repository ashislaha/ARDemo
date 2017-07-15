//
//  ViewController.swift
//  ARDemo
//
//  Created by Ashis Laha on 26/06/17.
//  Copyright © 2017 Ashis Laha. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

/* AR contains   1. Tracking ( World Tracking - ARAnchor )
                 2. Scene Understanding [a. Plane detection (ARPlaneAnchor) b. Hit Testing (placing object)  c. Light Estimation ]
                 3. Rendering ( SCNNode -> ARAnchor )
 */

@available(iOS 11.0, *)
class ARViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var sectionCoordinates : [[(Double,Double)]]?
    var worldSectionsPositions : [[(Float,Float,Float)]]? // (0,0,0) is the center of Co-ordinates
    
    var isObjectAddedPerPlane : Bool = false
    var overlayView : UIView!
    let worldTrackingFactor : Float = 100000
    var nodeNumber : Int = 1
    
    //MARK:- View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self           // ARSCNViewDelegate
        sceneView.session.delegate = self   // ARSessionDelegate
        sceneView.showsStatistics = true
        mapper()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal // Plane Detection
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //MARK:- Dismiss
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        isObjectAddedPerPlane = false
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Scene Set up
    
    private func createScene() {
        if let worldSectionsPositions = worldSectionsPositions {
            let scene = SCNScene()
            for eachSection in worldSectionsPositions {
                for eachCoordinate in eachSection {
                    let position = SCNVector3Make(eachCoordinate.0, eachCoordinate.1, eachCoordinate.2)
                    scene.rootNode.addChildNode(SceneNodeCreator.createCapsuleNode(position:position,text: "\(nodeNumber)"))
                    nodeNumber = nodeNumber + 1
                }
            }
            //scene.rootNode.addChildNode(SceneNodeCreator.createCameraNode(position: SCNVector3Make(0, 0, 20))) // optional
            sceneView.scene = scene
            sceneView.autoenablesDefaultLighting = true
            sceneView.allowsCameraControl = false
        }
    }
    
    //MARK:- Coordinate Mapper
    
    private func mapper() {
        if let sectionCoordinates = sectionCoordinates , let firstSection = sectionCoordinates.first , firstSection.count > 0 {
            let referencePoint = firstSection[0]
            mapToWorldCoordinateMapper(referencePoint: referencePoint, sectionCoordinates: sectionCoordinates)
        }
    }
    
    private func mapToWorldCoordinateMapper(referencePoint : (Double,Double) , sectionCoordinates : [[(Double,Double)]]) {
        worldSectionsPositions = []
        for eachSection in sectionCoordinates { // Each Edge
            var worldTrackSection = [(Float,Float,Float)]()
            for eachCoordinate in eachSection { // Each Point
                var realCoordinate : (x:Float, y: Float, z:Float) = (Float(),Float(),Float())
                let lndDelta = Float(eachCoordinate.1 - referencePoint.1) * worldTrackingFactor
                let latDelta = Float(eachCoordinate.0 - referencePoint.0) * worldTrackingFactor
                realCoordinate.x = lndDelta // based on Longtitude
                realCoordinate.y = 0.0
                realCoordinate.z = -1.0 * sqrt(latDelta * latDelta + lndDelta * lndDelta) // -ve Z axis
                worldTrackSection.append(realCoordinate)
            }
            worldSectionsPositions?.append(worldTrackSection)
        }
    }
    
    //MARK:- Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(location, options: nil)
        if let firstResult = hitTestResults.first {
            handleTouchEvent(node: firstResult.node)
        }
    }
    private func handleTouchEvent(node : SCNNode ) {
        let basicAnimation = CABasicAnimation(keyPath: "opacity")
        basicAnimation.duration = 1.0
        basicAnimation.fromValue = 1.0
        basicAnimation.toValue = 0.0
        node.addAnimation(basicAnimation, forKey: "opacity")
        //node.geometry?.firstMaterial?.emission.contents = UIColor.green
    }
}

// MARK:- Tracking
 
extension ARViewController : ARSCNViewDelegate , ARSessionDelegate {
    
    //MARK:- ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
       // addAnchorPoint(frame: frame)
    }
    
    //MARK:- Hit-Test (Scene Understanding)
    
    func addAnchorPoint(frame : ARFrame) {
        let point = CGPoint(x: 0.5, y: 0.5)
        let results = frame.hitTest(point, types: [.existingPlane, .estimatedHorizontalPlane])
        if let closetPoint = results.first , !isObjectAddedPerPlane {
            let anchor = ARAnchor(transform: closetPoint.worldTransform)
            isObjectAddedPerPlane = true
            sceneView.session.add(anchor: anchor)
        }
    }
    
    // Tracking
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        addPlaneGeometry(for: anchors)
    }
    func addPlaneGeometry(for anchors : [ARAnchor]) {
    }
    
    // When a plane is removed
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        removePlaneGeometry(for: anchors)
    }
    func removePlaneGeometry(for anchors : [ARAnchor]) {
    }
    
    // While Tracking State changes ( Not-running -> Normal <-> Limited )
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .limited(let reason) :
            if reason == .excessiveMotion {
                showAlert(header: "Tracking State Failure", message: "Excessive Motion")
            } else if reason == .insufficientFeatures {
                showAlert(header: "Tracking State Failure", message: "Insufficient Features")
            }
            isObjectAddedPerPlane = false
        case .normal, .notAvailable : break
        }
    }
    
    //MARK:- ARSCNViewDelegate  (Rendering)
    
    // ADD
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        print("Plane Detected : New Node is added")
        //let node = SceneNodeCreator.createPyramidNode(position: SCNVector3Make(0, 0, 0))
        return SCNNode() // node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
    
    // UPDATE
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    }
    
    // REMOVE
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    }
}

//MARK:- ERROR Handling

extension ARViewController {
    func session(_ session: ARSession, didFailWithError error: Error) {
       showAlert(header: "Session Failure", message: "Session Interrupted.")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        addOverlay()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        removeOverlay()
    }
    
    private func addOverlay() {
        overlayView = UIView(frame: sceneView.bounds)
        overlayView.backgroundColor = UIColor.brown.withAlphaComponent(0.5)
        self.sceneView.addSubview(overlayView)
    }
    
    private func removeOverlay() {
        if let overlayView = overlayView {
            overlayView.removeFromSuperview()
        }
    }
    
    func showAlert(header : String? = "Header", message : String? = "Message")  {
        
        let alertController = UIAlertController(title: header, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
