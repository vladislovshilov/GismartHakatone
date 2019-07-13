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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var angleLabel: UILabel!
    
    private let motion = CMMotionManager()
    private var timer: Timer!
    private var lastAccData: CMAccelerometerData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAccelerometers()
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
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
}

// MARK: - Gyroscope

extension ViewController {
    func startAccelerometers() {
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0  // 1 Hz
            self.motion.startAccelerometerUpdates()
            
            self.timer = Timer(fire: Date(), interval: 1.0,
                               repeats: true, block: { [weak self] timer in
                                guard let `self` = self, let data = self.motion.accelerometerData else { return }
                                self.updateAccelerationData(data)
            })
            
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    func stopAccelerometers() {
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
        
        print("New data")
        print(roll)
        print(pitch)
        
        let angle = 90 + roll.rounded()
        
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
