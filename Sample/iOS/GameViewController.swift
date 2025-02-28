//
//  GameViewController.swift
//  GLTFSceneKitSampler
//
//  Created by magicien on 2017/08/26.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GLTFSceneKit

class GameViewController: UIViewController {
    
    var gameView: SCNView? {
        get { return self.view as? SCNView }
    }
    var scene: SCNScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var scene: SCNScene
        do {
            let startTimeLoadAll = CFAbsoluteTimeGetCurrent()
            let sceneSource = try GLTFSceneSource(named: "art.scnassets/pilot-pororo.glb")
            scene = try sceneSource.scene(options: nil, animationIndex: -1, loadAllAnimations: true)
            let endTimeLoadAll = CFAbsoluteTimeGetCurrent()
            let timeTaken = (endTimeLoadAll - startTimeLoadAll)
            print("Loading All Animations: \(timeTaken)s")
            
            let startTimeSingle = CFAbsoluteTimeGetCurrent()
            let sceneSource2 = try GLTFSceneSource(named: "art.scnassets/pilot-pororo.gltf")
            scene = try sceneSource2.scene(options: nil, animationIndex: 1, loadAllAnimations: false)
            let endTimeSingle = CFAbsoluteTimeGetCurrent()
            let timeTakenSingle = (endTimeSingle - startTimeSingle)
            print("Loading Only selected animation taken: \(timeTakenSingle)s")
        } catch {
            print("\(error.localizedDescription)")
            return
        }
        
        self.setScene(scene)
        
        self.gameView!.autoenablesDefaultLighting = true
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = UIColor.gray

        self.gameView!.delegate = self
    }
    
    func setScene(_ scene: SCNScene) {
        // set the scene to the view
        self.gameView!.scene = scene
        self.scene = scene

        //to give nice reflections :)
        scene.lightingEnvironment.contents = "art.scnassets/shinyRoom.jpg"
        scene.lightingEnvironment.intensity = 2;
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
    self.scene?.rootNode.updateVRMSpringBones(time: time)
  }
}
