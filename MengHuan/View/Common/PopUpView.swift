//
//  PopUpView.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 30/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//
import Foundation
import UIKit

// MARK: - popup display view
class PopUpView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var imageWiki: UIImageView!
    @IBOutlet weak var wikiTitle: UILabel!
    @IBOutlet weak var wikiDescription: UILabel!
    @IBOutlet weak var wikiText: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        activityIndicator.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
    }

    // MARK: - wikiInfo object allow to display view data
    var wikiInfo: WikiInfo? {
        didSet {
            self.wikiTitle.text = self.wikiInfo?.query.idPages[0].title
            self.wikiText.text = self.wikiInfo?.query.idPages[0].extract
            self.wikiDescription.text = self.wikiInfo?.query.idPages[0].description ?? ""
            guard let image = self.wikiInfo?.query.idPages[0].original.source else {return}
            self.imageWiki.image = UIImage.displayImage(image)
        }
    }
}
