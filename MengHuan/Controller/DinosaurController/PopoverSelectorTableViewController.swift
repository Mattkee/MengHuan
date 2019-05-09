//
//  PopoverSelectorTableViewController.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 16/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//
import ARKit
import SceneKit
import UIKit

class PopoverSelectorTableViewController: UITableViewController {

    var dinosaurSelected: ((_ data: String) -> Void )?
    var planetSelected: ((_ data: String) -> Void )?

    var isDinosaur: Bool = false
    var isSolarSystem: Bool = false

    var dinosaur = [String]()
    var solarSystem = [String]()

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
        if isDinosaur {
            return dinosaur.count
        } else if isSolarSystem {
            return solarSystem.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DinosaurCell", for: indexPath) as? PopoverTableViewCell else {
            return UITableViewCell()
        }

        // Configure the cell...
        if isDinosaur {
            cell.elementToDisplay = dinosaur[indexPath.row]
        } else if isSolarSystem {
            cell.elementToDisplay = solarSystem[indexPath.row]
            cell.popoverImage.isHidden = true
        }

        return cell
    }

    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 250, height: tableView.contentSize.height)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isDinosaur {
            let selected = dinosaur[indexPath.row]
            dinosaurSelected?(selected)
            dismiss(animated: false, completion: nil)
        } else if isSolarSystem {
            let selected = solarSystem[indexPath.row]
            planetSelected?(selected)
            dismiss(animated: false, completion: nil)
        }
    }
}
