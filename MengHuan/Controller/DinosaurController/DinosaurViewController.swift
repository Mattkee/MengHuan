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

    let focus = SCNScene(named: "Dinosaur.scnassets/focus.scn")!.rootNode
    var positions = [SCNVector3]()
    var fixedFocus = SCNScene(named: "Dinosaur.scnassets/fixedFocus.scn")!.rootNode

//    var focusSquare = FocusSquare()
    var nodePosition: SCNNode?
    var isDetected: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        center = view.center
        sceneView.scene.rootNode.addChildNode(focus)
        // Do any additional setup after loading the view.
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
        focus.position = getAveragePosition(from: lastTenPositions)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDetected {
            dinosaurView.dinosaurSelectButton.isHidden = false
            fixedFocus.position = focus.position
            sceneView.scene.rootNode.addChildNode(fixedFocus)
            focus.removeFromParentNode()
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        isDetected = true
    }
}

extension DinosaurViewController: UIPopoverPresentationControllerDelegate {

    enum SegueIdentifier: String {
        case showObjects
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
        if segue.identifier == "showObjects" {
            guard let popup = segue.destination as? PopoverSelectorTableViewController else { return }
            popup.isDinosaur = true
            popup.dinosaur = self.dinosaur
            popup.dinosaurSelected = { [weak self] data in
                self?.selectedDinosaur = data
                if self?.selectedDinosaur != nil {
                    guard let position = self?.fixedFocus.position else {return}
                    self?.addItem(position)
//                    print(self?.dinosaur)
                }
            }
        }

        guard let identifier = segue.identifier,
            let segueIdentifer = SegueIdentifier(rawValue: identifier),
            segueIdentifer == .showObjects else { return }
    }

//    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//        objectsViewController = nil
//    }
    func addItem(_ postion: SCNVector3) {
        if let selectedItem = self.selectedDinosaur {
            print(selectedItem)
            let scene = SCNScene(named: "Dinosaur.scnassets/\(selectedItem).scn")
            guard let newScene = scene else {return}
            sceneView.scene = newScene
            guard let node = scene?.rootNode.childNode(withName: selectedItem, recursively: false) else { return }
            node.position = postion
            self.sceneView.scene.rootNode.addChildNode(node)
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
