//
//  VehiculeViewController.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 15/05/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class VehiculeViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Properties
    var center: CGPoint?
    var positions = [SCNVector3]()
    var staticFocus: SCNNode?
    var currentNode: SCNNode?
    var isDetected: Bool = false
    var element: String?

    var selectedVehicule: String? {
        didSet {
            if self.selectedVehicule != nil {
                self.addItem()
            }
        }
    }

    var vehicule: [String] = {
        guard let modelsURL = Bundle.main.url(forResource: "Vehicule.scnassets", withExtension: nil) else {return []}
        guard let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: []) else { return []}
        return fileEnumerator.compactMap { element in
            guard let url = element as? URL else { return nil }

            guard url.pathExtension == "scn" && !url.path.contains("lighting") else { return nil }
            let vehicule = url.lastPathComponent.replacingOccurrences(of: ".scn", with: "")

            return String(vehicule)
        }
    }()

    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()

    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var vehiculeView: VehiculeView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self

        center = view.center
        addFocus()
        // Do any additional setup after loading the view.
        statusViewController.statusView.blurView.isHidden = true
        statusViewController.statusView.refreshButton.isHidden = true

        statusViewController.refresh = { [unowned self] in
            self.refresh()
        }
        statusViewController.backAction = { [unowned self] in
            self.backAction()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.autoenablesDefaultLighting = true
        // Run the view's session
        sceneView.session.run(configuration)
        vehiculeView.vehiculeSelectButton.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        center = view.center
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let centerPoint = center else { return }
        let position = centerPosition(sceneView: sceneView, centerPoint: centerPoint)
        positions.append(position)
        let lastTenPositions = positions.suffix(10)
        guard let focus = sceneView.scene.rootNode.childNode(withName: "focus", recursively: false) else { return }
        focus.position = getAveragePosition(from: lastTenPositions)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        isDetected = true

        if staticFocus == nil {
            DispatchQueue.main.async {
                self.statusViewController.statusView.refreshButton.isHidden = false
                self.statusViewController.statusView.blurView.isHidden = false
                self.statusViewController.statusView.statusLabel.text = "Surface détectée"
            }
        }
    }
}

// MARK: - Navigations
extension VehiculeViewController: UIPopoverPresentationControllerDelegate {
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
            popover.isFixedElement = true
            popover.element = self.vehicule
            popover.elementSelected = { [weak self] data in
                self?.selectedVehicule = data
            }
        case "wikiInformation":
            guard let popup = segue.destination as? InformationPopUpViewController else { return }
            if element == "SF Fighter" || element == "SHC X" {
                popup.element = self.element
                popup.typeElement = "fiction"
            } else {
                popup.element = self.element
                popup.typeElement = ""
            }
        case "statusSegue":
            print("status bar ok")
        default :
            print("error")
        }
    }
    //    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    //        objectsViewController = nil
    //    }
}

// MARK: - Methods
extension VehiculeViewController {

    func addFocus() {
        guard let focusScene = SCNScene(named: "Common.scnassets/focus.scn") else { return }
        guard let focus = focusScene.rootNode.childNode(withName: "focus", recursively: false) else { return }
        sceneView.scene.rootNode.addChildNode(focus)
    }
    
    func addStaticFocus() {
        guard let staticFocusScene = SCNScene(named: "Common.scnassets/fixedFocus.scn") else { return }
        guard let staticFocus = staticFocusScene.rootNode.childNode(withName: "fixedFocus", recursively: false) else { return }
        guard let oldFocus = sceneView.scene.rootNode.childNode(withName: "focus", recursively: false) else { return }
        staticFocus.position = oldFocus.position
        oldFocus.removeFromParentNode()
        self.staticFocus = staticFocus
        sceneView.scene.rootNode.addChildNode(staticFocus)
        statusViewController.statusView.blurView.isHidden = true
    }
    
    func refresh() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        vehiculeView.vehiculeSelectButton.isHidden = true
        addFocus()
        selectedVehicule = nil
        positions = [SCNVector3]()
    }
    
    func backAction() {
        dismiss(animated: false, completion: nil)
    }

    func addItem() {
        if let selectedItem = self.selectedVehicule {
            guard let vehiculeScene = SCNScene(named: "Vehicule.scnassets/\(selectedItem).scn") else { return }
            guard let node = vehiculeScene.rootNode.childNode(withName: selectedItem, recursively: false) else { return }
            guard let position = self.staticFocus?.position else { return }
            node.position = position
            sceneView.scene.rootNode.addChildNode(node)
            self.vehiculeView.vehiculeSelectButton.isHidden = true
            self.statusViewController.statusView.blurView.isHidden = true
        }
    }

    func getAveragePosition(from positions: ArraySlice<SCNVector3>) -> SCNVector3 {
        var averageX: Float = 0
        var averageY: Float = 0
        var averageZ: Float = 0
        
        for position in positions {
            averageX += position.x
            averageY += position.y
            averageZ += position.z
        }
        let count = Float(positions.count)
        return SCNVector3Make(averageX / count, averageY / count, averageZ / count)
    }
}

// MARK: - Actions
extension VehiculeViewController {

    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if isDetected && selectedVehicule == nil && currentNode == nil {
            vehiculeView.vehiculeSelectButton.isHidden = false
            addStaticFocus()
        } else if currentNode != nil {
            addStaticFocus()
            guard let node = currentNode else { return }
            guard let position = self.staticFocus?.position else { return }
            node.position = position
            sceneView.scene.rootNode.addChildNode(node)
            self.currentNode = nil
        } else {
            guard let sceneViewTappedOn = sender.view as? SCNView else { return }
            let touchCoordinates = sender.location(in: sceneViewTappedOn)
            let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
            if !hitTest.isEmpty {
                guard let results = hitTest.first else {return}
                let node = results.node
                guard let name = node.name else {return}
                if name != "focus" && name != "fixedFocus" {
                    self.element = name
                    performSegue(withIdentifier: "wikiInformation", sender: self)
                }
            } else {
                print("didn't touch anything")
            }
        }
    }
    
    @IBAction func vehiculeScale(_ sender: UIPinchGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        guard let results = hitTest.first else { return }
        let node = results.node
        if !hitTest.isEmpty {
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @IBAction func rotateNode(_ sender: UIPanGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let vehicule = self.selectedVehicule else { return }
        guard let node = sceneView.scene.rootNode.childNode(withName: vehicule, recursively: false) else { return }
        
        sender.minimumNumberOfTouches = 2
        //1. Get The Current Rotation From The Gesture
        let xPan = sender.velocity(in: sceneView).x/10000
        node.runAction(SCNAction.rotateBy(x: 0, y: xPan, z: 0, duration: 0.1))
    }
    
    @IBAction func vehiculeMove(_ sender: UILongPressGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let vehicule = self.selectedVehicule else { return }
        guard let node = sceneView.scene.rootNode.childNode(withName: vehicule, recursively: false) else { return }
        self.currentNode = node
        node.removeFromParentNode()
        guard let staticFocus = sceneView.scene.rootNode.childNode(withName: "fixedFocus", recursively: false) else { return }
        staticFocus.removeFromParentNode()
        addFocus()
    }
}
