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

class DinosaurViewController: UIViewController, ARSCNViewDelegate, VirtualObjectInterraction {

    // MARK: - Properties
    var staticFocus: SCNNode?
    var center: CGPoint?
    var positions = [SCNVector3]()
    var currentNode: SCNNode?
    var isDetected: Bool = false
    var typeElement: String = ""

    var element: String = "" {
        didSet {
            if self.element == "SF Fighter" || self.element == "SHC X" {
                typeElement = "fiction"
                isPerform = true
            } else if self.element != oldValue {
                isPerform = true
            }
        }
    }

    var isPerform: Bool = false {
        didSet {
            if self.isPerform == true {
                performSegue(withIdentifier: "wikiInformation", sender: self)
            }
        }
    }

    var selectedElement: String = "" {
        didSet {
            if self.selectedElement != "" {
                self.addItem()
            }
        }
    }

    var dinosaur: [String] = {
        guard let modelsURL = Bundle.main.url(forResource: "Dinosaur.scnassets", withExtension: nil) else {return []}
        guard let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: []) else { return []}
        return fileEnumerator.compactMap { element in
            guard let url = element as? URL else { return nil }

            guard url.pathExtension == "scn" && !url.path.contains("lighting") else { return nil }
            let dinosaur = url.lastPathComponent.replacingOccurrences(of: ".scn", with: "")

            return String(dinosaur)
        }
    }()

    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()

    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var dinosaurView: DinosaurView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self

        center = view.center
        addFocus(sceneView: sceneView)
        // Do any additional setup after loading the view.
        statusViewController.statusView.blurView.isHidden = true
        statusViewController.statusView.refreshButton.isHidden = true

        statusViewController.refresh = { [unowned self] in
            self.dinosaurView.dinosaurSelectButton.isHidden = true
            self.refresh(sceneView: self.sceneView, &self.positions)
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
            popover.isFixedElement = true
            popover.element = self.dinosaur
            popover.elementSelected = { [weak self] data in
                self?.selectedElement = data
            }
        case "wikiInformation":
            guard let popup = segue.destination as? InformationPopUpViewController else { return }
            popup.element = self.element
            popup.typeElement = self.typeElement
        case "statusSegue":
            print("status bar ok")
        default :
            print("error")
        }
    }
}

// MARK: - Methods
extension DinosaurViewController {
    func backAction() {
        dismiss(animated: false, completion: nil)
    }

    func addItem() {
        addItemSceneView(sceneView: sceneView, node: &staticFocus, with: "Dinosaur")
        self.dinosaurView.dinosaurSelectButton.isHidden = true
        self.statusViewController.statusView.blurView.isHidden = true
    }
}

// MARK: - Actions
extension DinosaurViewController {

    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if isDetected && selectedElement == "" && currentNode == nil {
            dinosaurView.dinosaurSelectButton.isHidden = false
            addStaticFocus(sceneView: sceneView, node: &staticFocus)
            statusViewController.statusView.blurView.isHidden = true
        } else {
            tappedSceneView(sceneView: sceneView, tapGesture: sender, with: &currentNode, with: &staticFocus, with: &element)
        }
    }

    @IBAction func dinosaurScale(_ sender: UIPinchGestureRecognizer) {
        pinchSceneView(sceneView: sceneView, pinchGesture: sender)
    }

    @IBAction func rotateNode(_ sender: UIPanGestureRecognizer) {
        rotateSceneView(sceneView: sceneView, rotateGesture: sender, with: selectedElement)
    }

    @IBAction func dinosaurMove(_ sender: UILongPressGestureRecognizer) {
        moveNodeSceneView(sceneView: sceneView, pressGesture: sender, with: selectedElement, with: &currentNode)
    }
}
