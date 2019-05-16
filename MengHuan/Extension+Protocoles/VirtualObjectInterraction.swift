//
//  VirtualObjectInterraction.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 16/05/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit

protocol VirtualObjectInterraction: class {
    // MARK: - Properties
    var isPerform: Bool { get set }
    var element: String { get set }
    var typeElement: String { get set }
    var selectedElement: String { get set }
    // MARK: - Methods Declaration
    func addFocus(sceneView scene: ARSCNView)
    func refresh(sceneView scene: ARSCNView, _ positions: inout [SCNVector3])
    func addItemSceneView(sceneView scene: ARSCNView, node staticFocus: inout SCNNode?, with typeScene: String)
    func addStaticFocus(sceneView scene: ARSCNView, node staticFocus: inout SCNNode?)
    func getAveragePosition(from positions: ArraySlice<SCNVector3>) -> SCNVector3
    func tappedSceneView(sceneView scene: ARSCNView, tapGesture sender: UITapGestureRecognizer, with currentNode: inout SCNNode?, with staticFocus: inout SCNNode?, with element: inout String)
    func pinchSceneView(sceneView scene: ARSCNView, pinchGesture sender: UIPinchGestureRecognizer)
    func rotateSceneView(sceneView scene: ARSCNView, rotateGesture sender: UIPanGestureRecognizer, with selectedElement: String)
    func moveNodeSceneView(sceneView scene: ARSCNView, pressGesture sender: UILongPressGestureRecognizer, with selectedElement: String, with currentNode: inout SCNNode?)
}

// MARK: - Methodes
extension VirtualObjectInterraction {
    func refresh(sceneView scene: ARSCNView, _ positions: inout [SCNVector3]) {
        scene.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        addFocus(sceneView: scene)
        selectedElement = ""
        positions = [SCNVector3]()
    }
    func addItemSceneView(sceneView scene: ARSCNView, node staticFocus: inout SCNNode?, with typeScene: String) {
        guard let needScene = SCNScene(named: "\(typeScene).scnassets/\(selectedElement).scn") else { return }
        guard let node = needScene.rootNode.childNode(withName: selectedElement, recursively: false) else { return }
        guard let position = staticFocus?.position else { return }
        node.position = position
        scene.scene.rootNode.addChildNode(node)
    }
    func addFocus(sceneView scene: ARSCNView) {
        guard let focusScene = SCNScene(named: "Common.scnassets/focus.scn") else { return }
        guard let focus = focusScene.rootNode.childNode(withName: "focus", recursively: false) else { return }
        scene.scene.rootNode.addChildNode(focus)
    }
    func addStaticFocus(sceneView scene: ARSCNView, node staticFocus: inout SCNNode?) {
        guard let staticFocusScene = SCNScene(named: "Common.scnassets/fixedFocus.scn") else { return }
        guard let newStaticFocus = staticFocusScene.rootNode.childNode(withName: "fixedFocus", recursively: false) else { return }
        guard let oldFocus = scene.scene.rootNode.childNode(withName: "focus", recursively: false) else { return }
        newStaticFocus.position = oldFocus.position
        oldFocus.removeFromParentNode()
        staticFocus = newStaticFocus
        guard let newFocus = staticFocus else { return }
        scene.scene.rootNode.addChildNode(newFocus)
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
    func tappedSceneView(sceneView scene: ARSCNView, tapGesture sender: UITapGestureRecognizer, with currentNode: inout SCNNode?, with staticFocus: inout SCNNode?, with element: inout String) {
        if currentNode != nil {
            addStaticFocus(sceneView: scene, node: &staticFocus)
            guard let node = currentNode else { return }
            guard let position = staticFocus?.position else { return }
            node.position = position
            scene.scene.rootNode.addChildNode(node)
            currentNode = nil
        } else {
            guard let sceneViewTappedOn = sender.view as? SCNView else { return }
            let touchCoordinates = sender.location(in: sceneViewTappedOn)
            let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
            if !hitTest.isEmpty {
                guard let results = hitTest.first else {return}
                let node = results.node
                guard let name = node.name else {return}
                if name != "focus" && name != "fixedFocus" {
                    element = name
                }
            } else {
                print("didn't touch anything")
            }
        }
    }
    func pinchSceneView(sceneView scene: ARSCNView, pinchGesture sender: UIPinchGestureRecognizer) {
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
    func rotateSceneView(sceneView scene: ARSCNView, rotateGesture sender: UIPanGestureRecognizer, with selectedElement: String) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let node = sceneView.scene.rootNode.childNode(withName: selectedElement, recursively: false) else { return }

        sender.minimumNumberOfTouches = 2
        //1. Get The Current Rotation From The Gesture
        let xPan = sender.velocity(in: sceneView).x/10000
        node.runAction(SCNAction.rotateBy(x: 0, y: xPan, z: 0, duration: 0.1))
    }
    func moveNodeSceneView(sceneView scene: ARSCNView, pressGesture sender: UILongPressGestureRecognizer, with selectedElement: String, with currentNode: inout SCNNode?) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let node = sceneView.scene.rootNode.childNode(withName: selectedElement, recursively: false) else { return }
        currentNode = node
        node.removeFromParentNode()
        guard let staticFocus = sceneView.scene.rootNode.childNode(withName: "fixedFocus", recursively: false) else { return }
        staticFocus.removeFromParentNode()
        addFocus(sceneView: sceneView)
    }
}
