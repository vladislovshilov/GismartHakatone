//
//  ViewController.swift
//  69
//
//  Created by Vlados iOS on 7/13/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion

final class ViewController: UIViewController,
ARSCNViewDelegate {
    
    @IBOutlet private var sceneView: ARSCNView!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var angleLabel: UILabel!
    
    private var grids = [Grid]()
    
    private let sceneNames = ["CoffeeV", "CoffeeH"]
    private let nodeName = "Coffee"
    
    private var motion: CMMotionManager!
    private var timer: Timer!
    private var lastAccData: CMAccelerometerData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motion = CMMotionManager()
        
        let scene = SCNScene()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        sceneView.scene = scene
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAccelerometers()
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAccelerometers()
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        let location = touches.first!.location(in: sceneView)
        //        var hitTestOptions = [SCNHitTestOption: Any]()
        //        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        //        let hitResults: [SCNHitTestResult]  =
        //            sceneView.hitTest(location, options: hitTestOptions)
        //        if let hit = hitResults.first {
        //            if let node = getParent(hit.node) {
        //                node.removeFromParentNode()
        //                self.dismiss(animated: true, completion: nil)
        //                return
        //            }
        //        }
        //
        //        let hitResultsFeaturePoints: [ARHitTestResult] =
        //            sceneView.hitTest(location, types: .featurePoint)
        //        if let hit = hitResultsFeaturePoints.first {
        //            // Get a transformation matrix with the euler angle of the camera
        //            let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
        //
        //            // Combine both transformation matrices
        //            let finalTransform = simd_mul(hit.worldTransform, rotate)
        //
        //            // Use the resulting matrix to position the anchor
        //            sceneView.session.add(anchor: ARAnchor(transform: finalTransform))
        //            // sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
        //        }
    }
    
    private func getParent(_ nodeFound: SCNNode?) -> SCNNode? {
        if let node = nodeFound {
            if node.name == nodeName {
                return node
            } else if let parent = node.parent {
                return getParent(parent)
            }
        }
        return nil
    }
    
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //        if !anchor.isKind(of: ARPlaneAnchor.self) {
    //            DispatchQueue.main.async {
    //                let modelClone = self.nodeModel.clone()
    //                modelClone.position = SCNVector3Zero
    //
    //                // Add model as a child of the node
    //                node.addChildNode(modelClone)
    //            }
    //        }
    //    }
    
    
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //        if let planeAnchor = anchor as? ARPlaneAnchor {
    //            let grid = Grid(anchor: planeAnchor)
    //            self.grids.append(grid)
    //            node.addChildNode(grid)
    //        }
    //    }
    //
    //    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    //        let grid = self.grids.filter { grid in
    //            return grid.anchor.identifier == anchor.identifier
    //            }.first
    //
    //        guard let foundGrid = grid else {
    //            return
    //        }
    //
    //        foundGrid.update(anchor: anchor as! ARPlaneAnchor)
    //    }
    
    @objc private func tapped(gesture: UITapGestureRecognizer) {
        let touchPosition = gesture.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            guard let hitResult = hitTestResult.first else { return }
            DispatchQueue.main.async { [weak self] in
                self?.addGarbage(hitTestResult: hitResult)
            }
        }
    }
    
    private func addGarbage(hitTestResult: ARHitTestResult) {
        let randomIndex = Int.random(in: 0...1)
        guard let scene = SCNScene(named: "test.scnassets/" + sceneNames[randomIndex] + ".scn"),
            let garbageNode = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }
        
        let position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
                                  hitTestResult.worldTransform.columns.3.y,
                                  hitTestResult.worldTransform.columns.3.z)
        garbageNode.position = position
        
        sceneView.scene.rootNode.addChildNode(garbageNode)
    }
}

// MARK: - Gyroscope

extension ViewController {
    private func startAccelerometers() {
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 10  // 10 Hz
            self.motion.startAccelerometerUpdates()
            
            self.timer = Timer(fire: Date(), interval: 1.0 / 10,
                               repeats: true, block: { [weak self] timer in
                                guard let `self` = self, let data = self.motion.accelerometerData else { return }
                                self.updateAccelerationData(data)
            })
            
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    private func stopAccelerometers() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            
            self.motion.stopGyroUpdates()
        }
    }
    
    private func updateAccelerationData(_ accelerationData: CMAccelerometerData) {
        let x = accelerationData.acceleration.x
        let y = accelerationData.acceleration.y
        let z = accelerationData.acceleration.z
        
        let roll = atan2(y, z) * 57.3
        let pitch = atan2(-x, sqrt(y * y + z * z)) * 57.3
        
        lastAccData = accelerationData
        
//        print("New data")
//        print(roll)
//        print(pitch)
        
        let angle = 90 + Int(roll.rounded())
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if angle < 0 {
                self.angleLabel.text = "0°"
                self.distanceLabel.text = "0m"
            }
            else if angle > 90 {
                self.angleLabel.text = "\(angle)°"
                self.distanceLabel.text = "0m"
            }
            else {
                self.angleLabel.text = "\(angle)°"
                self.distanceLabel.text = "\(angle * 20)m"
            }
        }
    }
}
