//
//  PopoverTableViewCell.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 17/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit

// MARK: - popover cell view
class PopoverTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var popoverImage: UIImageView!
    @IBOutlet weak var popoverName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        popoverImage.layer.cornerRadius = 10
        popoverImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.accessoryType = .checkmark
        }
        // Configure the view for the selected state
    }

    // MARK: - elementToDisplay String allow to display view data
    var elementToDisplay: String? {
        didSet {
            self.popoverName.text = elementToDisplay
            guard let name = elementToDisplay else { return }
            let image = UIImage(named: name)
            if image != nil {
                self.popoverImage.image = image
            } else {
                self.popoverImage.image = UIImage(imageLiteralResourceName: "Virtuel reality")
            }
        }
    }
}
