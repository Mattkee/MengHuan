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
    @IBOutlet weak var selectedPlanetButton: UIButton!

    var nodes = [String: SCNNode]()
    var center: CGPoint?
    var scene: SCNScene?
    var planet: String? {
        didSet {
            if selectedPlanetButton.currentTitle == "System" {
                guard let globalNode = scene?.rootNode.childNode(withName: "System", recursively: false) else { return }
                globalNode.removeFromParentNode()
            } else {
                guard let oldPlanet = oldValue else { return }
                guard let deleteNode = scene?.rootNode.childNode(withName: oldPlanet, recursively: false) else { return }
                deleteNode.removeFromParentNode()
            }
            guard let nodeName = self.planet else { return }
            guard let node = nodes[nodeName] else { return }
            guard let centerPoint = center else { return }
            node.position = centerPosition(sceneView: sceneView, centerPoint: centerPoint)
            scene?.rootNode.addChildNode(node)
            selectedPlanetButton.setTitle(self.planet, for: .normal)
        }
    }

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
        center = view.center
        playButton.setImage(#imageLiteral(resourceName: "Pause Button"), for: .normal)
        playButton.setImage(#imageLiteral(resourceName: "Play Button"), for: .selected)
        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true

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
            performSegue(withIdentifier: "wikiInformation", sender: self)
        } else {
            print("didn't touch anything")
        }
    }

    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        guard let node = nodes["System"] else { return }
        let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
        node.runAction(pinchAction)
        sender.scale = 1.0
    }

    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        guard let senderView = sender.view as? ARSCNView else { return }
        let touch = sender.location(in: senderView)
        var selectedNode: SCNNode?
        if sender.state == .began {
            let hitTestResult = self.sceneView.hitTest(touch, options: nil)
            guard let hitNode = hitTestResult.first?.node else { return }
            selectedNode = hitNode
            //            let translation = sender.translation(in: sceneView)
            //            guard let node = nodes["System"] else { return }
            //            node.transform = SCNMatrix4MakeTranslation(Float(translation.x), Float(translation.y), 0)
        } else if sender.state == .changed {
            guard let hitNode = selectedNode else { return }
            let hitTestPlane = self.sceneView.hitTest(touch, types: .existingPlane)
            guard let hitPlane = hitTestPlane.first else { return }
            hitNode.position = SCNVector3(hitPlane.worldTransform.columns.3.x, hitNode.position.y, hitPlane.worldTransform.columns.3.z)
        }
    }

    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func playPauseAction(_ sender: UIButton) {
        if sender.isSelected {
            sceneView.scene.isPaused = false
            sender.isSelected = false
        } else {
            sceneView.scene.isPaused = true
            sender.isSelected = true
        }
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

//    enum SegueIdentifier: String {
//        case showPopover
//        case wikiInformation
//    }

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
        switch segue.identifier {
        case "showPopover":
            guard let popover = segue.destination as? PopoverSelectorTableViewController else { return }
            popover.isSolarSystem = true
            print(self.solarSystem)
            popover.solarSystem = self.solarSystem
            popover.planetSelected = { [weak self] data in
                self?.planet = data
            }
        case "wikiInformation":
            guard let popup = segue.destination as? InformationPopUpViewController else { return }
            popup.pageId = self.pageId
        default :
            print("error")
        }
//        guard let identifier = segue.identifier,
//            let segueIdentifer = SegueIdentifier(rawValue: identifier),
//            segueIdentifer == .showPopover else { return }
    }
}
