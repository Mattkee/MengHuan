//
//  UIViewController + Extension.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 09/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Alerts
extension UIViewController: DisplayAlert {

    func showAlert(title: String, message: String) {
        let alerteVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alerteVC.addAction(action)
        present(alerteVC, animated: true, completion: nil)
    }
}
