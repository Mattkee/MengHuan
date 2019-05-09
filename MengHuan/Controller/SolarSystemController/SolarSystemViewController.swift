//
//  SolarSystemViewController.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 02/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class SolarSystemViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var playButton: UIButton!

    var nodes = [String: SCNNode]()
    var scene: SCNScene?
    var planet: String?

    private let solarSystemService = SolarSystemService()

    var pageId: String?

    var solarSystem: [String] = {
        guard let solarSystem = SCNScene(named: "SolarSystem.scnassets/solarSystem.scn") else { return []}
        var nodesList = [String]()
        solarSystem.rootNode.enumerateChildNodes { (node, _) in
            guard let name = node.name else {return}
            if !name.contains("Parent"), !name.contains("particles"), !name.contains("omni"), !name.contains("Ring") {
                nodesList.append(name)
            }
        }
        return nodesList
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.setImage(#imageLiteral(resourceName: "Pause Button"), for: .normal)
        playButton.setImage(#imageLiteral(resourceName: "Play Button"), for: .selected)
        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Create a new scene
        scene = SCNScene(named: "SolarSystem.scnassets/solarSystem.scn")
        guard let newScene = scene else {return}
        // Set the scene to the view
        sceneView.scene = newScene
        nameNodes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        guard let sceneViewTappedOn = sender.view as? SCNView else { return }
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if !hitTest.isEmpty {
            guard let results = hitTest.first else {return}
            let node = results.node
            guard let name = node.name else {return}
            guard let pageId = Constant.idDictio[name] else {return}
            self.pageId = pageId
            performSegue(withIdentifier: "wiki Information", sender: self)
        } else {
            print("didn't touch anything")
        }
    }

    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        //        let sceneView = sender.view as! ARSCNView
        //        let pinchLocation = sender.location(in: sceneView)
        //        let hitTest = sceneView.hitTest(pinchLocation)
        //
        //        if !hitTest.isEmpty {
        //            let results = hitTest.first!
        //            let node = results.node
        //            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
        //            print(sender.scale)
        //            node.runAction(pinchAction)
        //            sender.scale = 1.0
        //        }
        guard let node = nodes["System"] else { return }
        let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
        node.runAction(pinchAction)
        sender.scale = 1.0
    }

    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let translation = sender.translation(in: sender.view)

            guard let node = nodes["System"] else { return }
            node.transform = SCNMatrix4MakeTranslation(Float(translation.x), Float(translation.y), 0)
        }
    }

    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func playPauseAction(_ sender: UIButton) {
        if sender.isSelected {
            guard let newScene = SCNScene(named: "SolarSystem.scnassets/solarSystem.scn") else { return }
            sceneView.scene = newScene
            print("ok")
            sender.isSelected = false
        } else {
            sceneView.scene.rootNode.removeAllAnimations()
            print("stop")
            sender.isSelected = true
        }
        performSegue(withIdentifier: "wiki Information", sender: sender)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }

    func nameNodes() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            guard let name = node.name else {return}
            if !name.contains("Parent"), !name.contains("particles"), !name.contains("omni") {
                nodes[name] = node
            }
        }
    }
}

extension SolarSystemViewController: UIPopoverPresentationControllerDelegate {

    enum SegueIdentifier: String {
        case showPopover
    }

    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // All menus should be popovers (even on iPhone).
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
        }
        if segue.identifier == "showPopover" {
            guard let popup = segue.destination as? PopoverSelectorTableViewController else { return }
            popup.isSolarSystem = true
            popup.solarSystem = self.solarSystem
            popup.planetSelected = { [weak self] data in
                self?.planet = data
            }
        }

        guard let identifier = segue.identifier,
            let segueIdentifer = SegueIdentifier(rawValue: identifier),
            segueIdentifer == .showPopover else { return }
    }
}
