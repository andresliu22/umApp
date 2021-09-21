//
//  ConfigVC.swift
//  un
//
//  Created by Andres Liu on 1/14/21.
//

import UIKit

class ConfigVC: UIViewController {

    @IBOutlet weak var switchCurrency: UISwitch!
    var monedaId = 2
    override func viewDidLoad() {
        super.viewDidLoad()

        monedaId = UserDefaults.standard.integer(forKey: "moneda")
        
        if monedaId == 2 {
            switchCurrency.isOn = true
            switchCurrency.thumbTintColor = #colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1)
        } else {
            switchCurrency.isOn = false
            switchCurrency.thumbTintColor = #colorLiteral(red: 0.2392156863, green: 0.2352941176, blue: 0.2392156863, alpha: 1)
        }
    }
    
    @IBAction func onSwitchCurrency(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(2, forKey: "moneda")
            sender.thumbTintColor = #colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1)
        } else {
            UserDefaults.standard.setValue(1, forKey: "moneda")
            sender.thumbTintColor = #colorLiteral(red: 0.2392156863, green: 0.2352941176, blue: 0.2392156863, alpha: 1)
        }
    }
    
    @IBAction func returnToMenu(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func returnToReport(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goToChangePass(_ sender: UIButton) {
        let changePassVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePassVC") as! ChangePassVC
        self.navigationController?.pushViewController(changePassVC, animated: true)
    }
    
    @IBAction func goToNotifications(_ sender: UIButton) {
        let notificationVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
}
