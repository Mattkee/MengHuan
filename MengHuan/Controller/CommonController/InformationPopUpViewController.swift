//
//  InformationPopUpViewController.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 05/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import UIKit

class InformationPopUpViewController: UIViewController {

    private let solarSystemService = SolarSystemService()

    @IBOutlet var popUpView: PopUpView!
    var pageId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        displayHiddenInfo(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let searchId = pageId else {return}
        search(searchId)
    }

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

    func search(_ searchId: String) {
        solarSystemService.getWikiInfo(searchId) { (error, wiki) in
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
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
