//
//  HomeTableViewController.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 02/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 200
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let emptyLabel = UILabel()
        emptyLabel.text = "Que voulez vous apprendre ?"
        emptyLabel.textColor = UIColor.white
        emptyLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        emptyLabel.textAlignment = .center
        return emptyLabel
    }
}
