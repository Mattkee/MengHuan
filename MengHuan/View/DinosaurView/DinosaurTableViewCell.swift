//
//  DinosaurTableViewCell.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 17/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit

class PopoverTableViewCell: UITableViewCell {

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

        // Configure the view for the selected state
    }

    var elementToDisplay: String? {
        didSet {
            self.popoverName.text = elementToDisplay
            self.popoverImage.image = UIImage(imageLiteralResourceName: elementToDisplay ?? "Virtuel reality")
        }
    }
}
