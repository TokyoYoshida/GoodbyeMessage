//
//  GameViewController.swift
//  GoodbyeMessage
//
//  Created by TokyoYoshida on 2020/07/30.
//  Copyright © 2020 TokyoMac. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

struct GlobalData {
    var ch_pos: SIMD2<Float>//   = float2 (0.0, 0.0);             // character position(X,Y)
    var d: Float// = 1e6;
    var time: Float
}


class GameViewController: UIViewController {
    private var globalData: GlobalData = GlobalData(ch_pos: SIMD2<Float>(0,0), d: Float(1e6), time: Float(0))
    private var startDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.runAction(SCNAction.moveBy(x: 0, y: 0, z: -3, duration: 20))

        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        addAdiosText()
        addPlane()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}

extension GameViewController {
    func addAdiosText() {
        let scnView = self.view as! SCNView
        
        let str = "Goodbye!!"
        let depth:CGFloat = 0.5
        let text = SCNText(string: str, extrusionDepth: depth)
        text.font = UIFont(name: "HiraKakuProN-W6", size: 0.5);
        let textNode = SCNNode(geometry: text)

        let (min, max) = (textNode.boundingBox)
        let x = CGFloat(max.x - min.x)
        let y = CGFloat(max.y - min.y)
        textNode.position = SCNVector3(-(x/2), -1, 0)

        print("\(str) width=\(x)m height=\(y)m depth=\(depth)m")
        textNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: 0, duration: 1)))

        scnView.scene?.rootNode.addChildNode(textNode)
        setMetalMaterial2(textNode)
    }
    
    func addPlane() {
        let scnView = self.view as! SCNView
        let planeGeometry = SCNBox(width: 100,
                               height: 100,
                               length: 1,
                               chamferRadius: 0)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3(0, -1, -5)

        let material = SCNMaterial()
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(100, 100, 0)
        planeNode.geometry?.firstMaterial = material

        scnView.scene?.rootNode.addChildNode(planeNode)
        
        setMetalMaterial(planeNode)

    }
    
    func setMetalMaterial(_ node: SCNNode) {
        let program = SCNProgram()
        program.vertexFunctionName = "vertexShader"
        program.fragmentFunctionName = "fragmentShader"
        node.geometry?.firstMaterial?.program = program
        

        Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true, block: { (timer) in
            self.updateTime(node)
        })
        let time = Float(Date().timeIntervalSince(startDate))
        globalData.time = time
        let uniformsData = Data(bytes: &globalData, count: MemoryLayout<GlobalData>.size)
        node.geometry?.firstMaterial?.setValue(uniformsData, forKey: "globalData")
    }
    
    func updateTime(_ node: SCNNode) {
        let time = Float(Date().timeIntervalSince(startDate))
        globalData.time = time
        let uniformsData = Data(bytes: &globalData, count: MemoryLayout<GlobalData>.size)
        node.geometry?.firstMaterial?.setValue(uniformsData, forKey: "globalData")
    }

    func setMetalMaterial2(_ node: SCNNode) {
        let program = SCNProgram()
        program.vertexFunctionName = "vertexShader2"
        program.fragmentFunctionName = "fragmentShader2"
        node.geometry?.firstMaterial?.program = program
    }
}
