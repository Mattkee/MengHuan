//
//  MainTableViewCell.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 16/05/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
