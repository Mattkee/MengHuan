//
//  UIViewController + Extension.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 09/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

// MARK: - Alerts
extension UIViewController: DisplayAlert {

    func showAlert(title: String, message: String) {
        let alerteVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alerteVC.addAction(action)
        present(alerteVC, animated: true, completion: nil)
    }

    func centerPosition(sceneView: ARSCNView, centerPoint: CGPoint) -> SCNVector3 {
        let hitTest = sceneView.hitTest(centerPoint, types: .featurePoint)
        let result = hitTest.last
        guard let transform = result?.worldTransform else { return SCNVector3(0, 0, 0) }
        let thirdColumn = transform.columns.3
        let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        return position
    }
    func verctorAddition(vector isFirst: SCNVector3, vector isSecond: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(isFirst.x + isSecond.x, isFirst.y + isSecond.y, isFirst.z + isSecond.z)
    }
}
