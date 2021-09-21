//
//  TermsVC.swift
//  un
//
//  Created by Andres Liu on 1/28/21.
//

import UIKit

class TermsVC: UIViewController {

    @IBOutlet weak var tycLabel: UILabel!
    var tycText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tycLabel.text = tycText
    }

    @IBAction func returnToMenu(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
