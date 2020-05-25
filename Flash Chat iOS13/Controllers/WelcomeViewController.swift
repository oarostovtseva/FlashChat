//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Olena Rostovtseva on 20.05.2020.
//

import CLTypingLabel
import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet var titleLabel: CLTypingLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = K.appName
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
