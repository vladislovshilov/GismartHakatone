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
                            ARSCNViewDelegate, CAAnimationDelegate {
    
    @IBOutlet private var sceneView: ARSCNView!
    //@IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var angleLabel: UILabel!
    @IBOutlet private weak var projectileView: UIView!
    @IBOutlet private weak var projectileImage: UIImageView!
    
    @IBOutlet private weak var powerIndicatorImage: UIImageView!
    @IBOutlet private weak var powerPointImage: UIImageView!
    
    @IBOutlet private weak var weaponAmountLabel: UILabel!
    
    private let sceneNames = ["CoffeeV", "CoffeeH"]
    private let nodeName = "Coffee"
    
    private var isPowerViewShouldAnimating = false
    
    private var motion: CMMotionManager!
    private var timer: Timer!
    private var animationTimer: Timer!
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
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(gesture:)))
        projectileView.addGestureRecognizer(longPressGestureRecognizer)
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
    
    private func createTimer() {
        if animationTimer == nil {
            animationTimer = Timer.scheduledTimer(timeInterval: 1.0/60,
                                                  target: self,
                                                  selector: #selector(updateTimer),
                                                  userInfo: nil,
                                                  repeats: true)
            animationTimer?.tolerance = 0.1
        }
    }
    
    private func cancelTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    var power: CGFloat = 50
    var isPointMovesUp = true
    var minPoint: CGFloat!
    var maxPoint: CGFloat!
    
    @objc private func updateTimer() {
        if power >= 100 { isPointMovesUp = false }
        else if power <= 0 { isPointMovesUp = true }
        
        if isPointMovesUp {
            power += 1
        }
        else {
            power -= 1
        }
        updateAnimation()
    }
    
    private func updateAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            let newPoint = (self.maxPoint - self.minPoint) / 100.0 * self.power
            print(self.power)
            self.powerPointImage.center.y = newPoint
        }
    }

    private func startPowerPointAnimation() {
        minPoint = powerIndicatorImage.frame.origin.y
        maxPoint = minPoint + powerIndicatorImage.frame.height
        createTimer()
        
//        let x = powerIndicatorImage.frame.origin.x + powerPointImage.frame.width / 2
//        let minPoint = powerIndicatorImage.frame.origin.y
//        let maxPoint = minPoint + powerIndicatorImage.frame.height
//        isPowerViewShouldAnimating = true
//
//        let animation = CABasicAnimation(keyPath: "position")
//        animation.fromValue = CGPoint(x: x,
//                                      y: minPoint)
//        animation.toValue = CGPoint(x: x,
//                                    y: maxPoint)
//        animation.duration = 2
//        animation.autoreverses = true
//        animation.repeatCount = .infinity
//        powerPointImage.layer.add(animation, forKey: nil)
        
//        UIView.animate(withDuration: 1.0,
//                       animations: { () -> Void in
//                        self.powerPointImage.center.y = maxPoint
//
//        }, completion: { _ in
//            if !self.isPowerViewShouldAnimating { return }
//            UIView.animate(withDuration: 2.0,
//                           delay: 0.0,
//                           options: [.autoreverse, .repeat],
//                           animations: { () -> Void in
//                            self.powerPointImage.center.y = minPoint
//
//            }, completion: { _ in
//                print("comp \(self.powerPointImage.bounds.origin.y)")
//                self.powerPointImage.center.y = self.powerIndicatorImage.center.y
//            })
//        })
    }
    
    private func stopPowerPointAnimation() {
        cancelTimer()
    }
    
    @objc private func longPressed(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .began:
            startPowerPointAnimation()
        case .ended:
            stopPowerPointAnimation()
        default:
            return
        }
    }

    @objc private func tapped(gesture: UITapGestureRecognizer) {
        if let node = nodeOnTap(gesture) {
            node.removeFromParentNode()
            self.dismiss(animated: true, completion: nil)
            return
        }
        else {
            addGarbageOnScene(on: gesture)
        }
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
    
    private func nodeOnTap(_ tap: UITapGestureRecognizer) -> SCNNode? {
        let location = tap.location(in: sceneView)
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult]  =
            sceneView.hitTest(location, options: hitTestOptions)
        
        if let hit = hitResults.first {
            return getParent(hit.node)
        }
        
        return nil
    }
    
    private func addGarbageOnScene(on tap: UITapGestureRecognizer) {
        let touchPosition = tap.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            guard let hitResult = hitTestResult.first else { return }
            addGarbage(hitTestResult: hitResult)
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

// MARK: - Accelerometer

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
        
        lastAccData = accelerationData
        
//        print("New data")
//        print(roll)
//        print(pitch)
        
        let angle = 90 + Int(roll.rounded())
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if angle < 0 {
                self.angleLabel.text = "0°"
                //self.distanceLabel.text = "0m"
            }
            else if angle > 90 {
                self.angleLabel.text = "\(angle)°"
                //self.distanceLabel.text = "0m"
            }
            else {
                self.angleLabel.text = "\(angle)°"
                //self.distanceLabel.text = "\(angle * 20)m"
            }
        }
    }
}
