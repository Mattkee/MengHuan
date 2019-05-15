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

    // MARK: - Properties
    var elementSelected: ((_ data: String) -> Void )?
    var isFixedElement: Bool = false
    var element = [String]()

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
        return element.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PopoverCell", for: indexPath) as? PopoverTableViewCell else {
            return UITableViewCell()
        }
        // Configure the cell...
        if isFixedElement {
            cell.elementToDisplay = element[indexPath.row]
        } else {
            cell.elementToDisplay = element[indexPath.row]
            cell.popoverImage.isHidden = true
        }
        return cell
    }

    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 250, height: tableView.contentSize.height)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selected = element[indexPath.row]
            elementSelected?(selected)
            dismiss(animated: false, completion: nil)
    }
}
