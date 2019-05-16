//
//  InformationPopUpViewController.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 05/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit

class InformationPopUpViewController: UIViewController {

    // MARK: - Properties
    private let solarSystemService = WikiInfoService()
    var element: String?
    var typeElement: String?

    // MARK: - Outlets
    @IBOutlet var popUpView: PopUpView!

    override func viewDidLoad() {
        super.viewDidLoad()
        displayHiddenInfo(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let elementName = element else { return }
        if typeElement == "fiction" {
            displayHiddenInfo(false)
            guard let name = element else { return }
            withoutWikiInfo(title: name, description: Constant.wikiDescription, bodyText: Constant.wikiText)
        } else {
            guard let elementType = typeElement else { return }
            search(elementName, type: elementType)
        }
    }
}

// MARK: Methods
extension InformationPopUpViewController {
    func search(_ elementName: String, type: String) {
        solarSystemService.getWikiInfo(elementName, type: type) { (error, wiki) in
            guard error == nil else {
                guard let error = error else {
                    return
                }
                self.showAlert(title: Constant.titleAlert, message: error)
                return
            }
            self.popUpView.wikiInfo = wiki
            self.displayHiddenInfo(false)
        }
    }

    func displayHiddenInfo(_ isReady: Bool) {
        self.popUpView.activityIndicator.isHidden = !isReady
        self.popUpView.label.isHidden = !isReady
        self.popUpView.imageWiki.isHidden = isReady
        self.popUpView.wikiTitle.isHidden = isReady
        self.popUpView.wikiDescription.isHidden = isReady
        self.popUpView.wikiText.isHidden = isReady
        self.popUpView.linkLabel.isHidden = isReady
    }

    func withoutWikiInfo(title: String, description: String, bodyText: String) {
        if title == "SF Fighter" || title == "SHC X" {
            popUpView.imageWiki.image = UIImage(imageLiteralResourceName: "Virtuel reality")
        } else {
            popUpView.imageWiki.image = UIImage(imageLiteralResourceName: title)
        }
        popUpView.wikiTitle.text = title
        popUpView.wikiDescription.text = description
        popUpView.wikiText.text = bodyText
    }
}

// MARK: - Actions
extension InformationPopUpViewController {
    @IBAction func tapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        guard let gestureView = sender.view else {return}
        let tapCoordonate = sender.location(in: gestureView)
        let hitTest = gestureView.hitTest(tapCoordonate, with: nil)
        if hitTest == popUpView {
            guard let url = popUpView.wikiInfo?.query.idPages[0].fullurl else {
                return
            }
            guard let link = URL(string: url) else {
                return
            }
            UIApplication.shared.open(link)
        } else {
            dismiss(animated: false, completion: nil)
        }
    }
}
