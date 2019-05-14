//
//  DinosaurViewController.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 02/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class DinosaurViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var dinosaurView: DinosaurView!

    var center: CGPoint?
    var selectedDinosaur: String?

    var dinosaur: [String] = {
        guard let modelsURL = Bundle.main.url(forResource: "Dinosaur.scnassets", withExtension: nil) else {return []}
        guard let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: []) else { return []}
        return fileEnumerator.compactMap { element in
            guard let url = element as? URL else { return nil }

            guard url.pathExtension == "scn" && !url.path.contains("lighting") && !url.path.contains("focus") && !url.path.contains("fixedFocus") else { return nil }
            let dinosaur = url.lastPathComponent.replacingOccurrences(of: ".scn", with: "")

            return String(dinosaur)
        }
    }()

    var positions = [SCNVector3]()

    var staticFocus: SCNNode?

    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
//    var focusSquare = FocusSquare()
    var nodePosition: SCNNode?
    var isDetected: Bool = false
    var pageId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        center = view.center
        guard let focusScene = SCNScene(named: "Dinosaur.scnassets/focus.scn") else { return }
        guard let focus = focusScene.rootNode.childNode(withName: "focus", recursively: false) else { return }
        sceneView.scene.rootNode.addChildNode(focus)
        // Do any additional setup after loading the view.
        statusViewController.statusView.isHidden = true
        statusViewController.refresh = { [unowned self] in
            self.refresh()
        }
    }

    func addStaticFocus() {
        guard let staticFocusScene = SCNScene(named: "Dinosaur.scnassets/fixedFocus.scn") else { return }
        guard let oldFocus = sceneView.scene.rootNode.childNode(withName: "focus", recursively: false) else { return }
        let newStaticFocus = staticFocusScene.rootNode
        newStaticFocus.position = oldFocus.position
        oldFocus.removeFromParentNode()
        self.staticFocus = newStaticFocus
        sceneView.scene.rootNode.addChildNode(newStaticFocus)
        statusViewController.statusView.blurView.isHidden = true
    }

    func refresh() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        dinosaurView.dinosaurSelectButton.isHidden = true
        guard let focusScene = SCNScene(named: "Dinosaur.scnassets/focus.scn") else { return }
        guard let focus = focusScene.rootNode.childNode(withName: "focus", recursively: false) else { return }
        sceneView.scene.rootNode.addChildNode(focus)
        selectedDinosaur = nil
        positions = [SCNVector3]()
    }

    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if isDetected && selectedDinosaur == nil {
            dinosaurView.dinosaurSelectButton.isHidden = false
            addStaticFocus()
        } else {
            guard let sceneViewTappedOn = sender.view as? SCNView else { return }
            let touchCoordinates = sender.location(in: sceneViewTappedOn)
            let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
            if !hitTest.isEmpty {
                guard let results = hitTest.first else {return}
                let node = results.node
                guard let name = node.name else {return}
                guard let pageId = Constant.idDinosaurDictio[name] else {return}
                self.pageId = pageId
                performSegue(withIdentifier: "wikiInformation", sender: self)
            } else {
                print("didn't touch anything")
            }
        }
    }

    @IBAction func returnToHome(_ sender: UIScreenEdgePanGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        dinosaurView.dinosaurSelectButton.isHidden = true
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
        DispatchQueue.main.async {
            self.statusViewController.statusView.isHidden = false
            self.statusViewController.statusView.statusLabel.text = "Surface détectée"
        }
    }

    func addItem(_ postion: SCNVector3) {
        if let selectedItem = self.selectedDinosaur {
            guard let dinosaurScene = SCNScene(named: "Dinosaur.scnassets/\(selectedItem).scn") else { return }
            guard let node = dinosaurScene.rootNode.childNode(withName: selectedItem, recursively: false) else { return }
            node.position = postion
            sceneView.scene.rootNode.addChildNode(node)
            self.dinosaurView.dinosaurSelectButton.isHidden = true
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

extension DinosaurViewController: UIPopoverPresentationControllerDelegate {

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
            popover.isDinosaur = true
            popover.dinosaur = self.dinosaur
            popover.dinosaurSelected = { [weak self] data in
                self?.selectedDinosaur = data
                if self?.selectedDinosaur != nil {
                    guard let position = self?.staticFocus?.position else { return }
                    let dinosaurPosition = position
                    self?.addItem(dinosaurPosition)
                }
            }
        case "wikiInformation":
            guard let popup = segue.destination as? InformationPopUpViewController else { return }
            popup.pageId = self.pageId
        default :
            print("error")
        }
    }
//    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//        objectsViewController = nil
//    }
}
