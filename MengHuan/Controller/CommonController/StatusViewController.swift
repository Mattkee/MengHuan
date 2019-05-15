//
//  StatusViewController.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 07/05/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit

class StatusViewController: UIViewController {

    // MARK: - Properties
    var refresh: () -> Void = {}
    var backAction: () -> Void = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - Outlets
    @IBOutlet var statusView: StatusView!

    // MARK: - Actions
    @IBAction func backAction(_ sender: UIButton) {
        backAction()
    }
    @IBAction func refreshButton(_ sender: UIButton) {
        refresh()
    }
}
