//
//  StatusViewController.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 07/05/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit

class StatusViewController: UIViewController {

    @IBOutlet var statusView: StatusView!
    var refresh: () -> Void = {}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func refreshButton(_ sender: UIButton) {
        refresh()
    }
}
