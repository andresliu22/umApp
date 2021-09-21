//
//  NotificationVC.swift
//  un
//
//  Created by Andres Liu on 1/14/21.
//

import UIKit

class NotificationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func returnToConfig(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func returnToReport(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
