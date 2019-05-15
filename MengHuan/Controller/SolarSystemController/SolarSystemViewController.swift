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

    // MARK: - Properties
    var nodes = [String: SCNNode]()
    var center: CGPoint?
    var element: String?

    var planet: String = "Systeme Solaire" {
        didSet {
            if oldValue != "System Solaire" {
                self.addRemoveNode(oldValue)
            } else {
                self.addRemoveNode("Systeme Solaire")
            }
            selectedPlanetButton.setTitle(self.planet, for: .normal)
        }
    }

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

    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var selectedPlanetButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        center = view.center
        playButton.setImage(#imageLiteral(resourceName: "Pause Button"), for: .normal)
        playButton.setImage(#imageLiteral(resourceName: "Play Button"), for: .selected)

        // Set the view's delegate
        sceneView.delegate = self
        guard let scene = SCNScene(named: "SolarSystem.scnassets/solarSystem.scn") else { return }
        guard let system = scene.rootNode.childNode(withName: "Systeme Solaire", recursively: false) else { return }
        // Set the scene to the view
        sceneView.scene.rootNode.addChildNode(system)
        nameNodes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        sceneView.autoenablesDefaultLighting = true
        // Run the view's session
        sceneView.session.run(configuration)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
}

//MARK: - Methods
extension SolarSystemViewController {

    func addRemoveNode(_ nodeToDelete: String) {
        guard let oldSystem = sceneView.scene.rootNode.childNode(withName: nodeToDelete, recursively: false) else { return }
        oldSystem.removeFromParentNode()
        let nodeName = self.planet
        if nodeName == "Systeme Solaire" {
            guard let scene = SCNScene(named: "SolarSystem.scnassets/solarSystem.scn") else { return }
            guard let system = scene.rootNode.childNode(withName: "Systeme Solaire", recursively: false) else { return }
            sceneView.scene.rootNode.addChildNode(system)
        } else {
            guard let newNode = nodes[nodeName] else { return }
            newNode.position = SCNVector3(0, 0, -1)
            newNode.scale = SCNVector3(0.3, 0.3, 0.3)
            sceneView.scene.rootNode.addChildNode(newNode)
        }
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

//MARK: - Navigations
extension SolarSystemViewController: UIPopoverPresentationControllerDelegate {
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
            popover.element = self.solarSystem
            popover.elementSelected = { [weak self] data in
                self?.planet = data
            }
        case "wikiInformation":
            guard let popup = segue.destination as? InformationPopUpViewController else { return }
            if element == "Soleil" || element == "Lune" || element == "Systeme Solaire" {
                popup.element = self.element
                popup.typeElement = "planet"
            } else {
                popup.element = self.element
                popup.typeElement = ""
            }
        default :
            print("error")
        }
    }
}

// MARK: - Actions
extension SolarSystemViewController {

    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if sender.numberOfTapsRequired == 1 {
            guard let sceneViewTappedOn = sender.view as? SCNView else { return }
            let touchCoordinates = sender.location(in: sceneViewTappedOn)
            let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
            if !hitTest.isEmpty {
                guard let results = hitTest.first else {return}
                let node = results.node
                guard let name = node.name else { return }
                self.element = name
                performSegue(withIdentifier: "wikiInformation", sender: self)
            } else {
                print("didn't touch anything")
            }
        } else {
            guard let hitNode = sceneView.scene.rootNode.childNode(withName: self.planet, recursively: false) else { return }
            guard let centerPoint = center else { return }
            hitNode.scale = SCNVector3(1, 1, 1)
            hitNode.position = centerPosition(sceneView: sceneView, centerPoint: centerPoint)
        }
    }
    
    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        if planet != "Systeme Solaire" {
            guard let sceneView = sender.view as? ARSCNView else { return }
            let pinchLocation = sender.location(in: sceneView)
            let hitTest = sceneView.hitTest(pinchLocation)
            guard let results = hitTest.first else { return }
            let node = results.node
            if sceneView.scene.isPaused == true {
                node.scale = SCNVector3(sender.scale, sender.scale, sender.scale)
            } else {
                if !hitTest.isEmpty {
                    let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
                    node.runAction(pinchAction)
                    sender.scale = 1.0
                }
            }
        }
    }
    
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        guard let senderView = sender.view as? ARSCNView else { return }
        let touch = sender.location(in: senderView)
        if sender.state == .began {
            let hitTestResult = self.sceneView.hitTest(touch, options: nil)
            guard let hitNode = hitTestResult.first?.node else { return }
            guard let planetName = hitNode.name else { return }
            self.planet = planetName
        }
    }
    
    @IBAction func rotateNode(_ sender: UIPanGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let node = sceneView.scene.rootNode.childNode(withName: self.planet, recursively: false) else { return }
        
        sender.minimumNumberOfTouches = 2
        if sender.state == .began {
            sceneView.scene.isPaused = false
        }
        if sender.state == .changed {
            let xPan = sender.velocity(in: sceneView).x/10000
            node.runAction(SCNAction.rotateBy(x: 0, y: xPan, z: 0, duration: 0.1))
        }
        if sender.state == .ended {
            if playButton.isSelected == true {
                sceneView.scene.isPaused = true
            }
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
}
