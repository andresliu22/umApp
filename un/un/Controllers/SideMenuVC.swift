//
//  SideMenuVC.swift
//  un
//
//  Created by Andres Liu on 1/14/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class SideMenuVC: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var buttonNews: UIButton!
    @IBOutlet weak var buttonReports: UIButton!
    @IBOutlet weak var buttonStatus: UIButton!
    
    @IBOutlet weak var contact: UILabel!
    
    var info = BusinessInfo(phoneNumber: "", email: "", tyc: "", instagram: "", linkedin: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = UserDefaults.standard.string(forKey: "userFirstName") ?? ""
        getInfo()
    }
    
    func getInfo() {
        let serverManager = ServerManager()
        let parameters : Parameters  = [:]
        serverManager.serverCallWithHeadersGET(url: serverManager.infoURL, params: parameters, method: .get, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.info.phoneNumber = jsonData["numcontacto"].string ?? ""
                self.info.email = jsonData["mailcontacto"].string ?? ""
                self.info.tyc = jsonData["tyc"].string ?? ""
                self.info.instagram = jsonData["instagram"].string ?? ""
                self.info.linkedin = jsonData["linkedin"].string ?? ""
                
                self.contact.text = "\(self.info.phoneNumber) / \(self.info.email)"
            } else {
                print("Failure")
            }
        })
    }
    
    @IBAction func closeMenu(_ sender: UIButton) {
        let lastReport = UserDefaults.standard.integer(forKey: "lastReport")
        switch lastReport {
        case 0:
            let reportListVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportListVC") as! ReportListVC
            self.navigationController?.pushViewController(reportListVC, animated: true)
        case 1:
            let newsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
            self.navigationController?.pushViewController(newsVC, animated: true)
        case 2:
            let statusVC = self.storyboard?.instantiateViewController(withIdentifier: "StatusVC") as! StatusVC
            self.navigationController?.pushViewController(statusVC, animated: true)
        default:
            let reportListVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportListVC") as! ReportListVC
            self.navigationController?.pushViewController(reportListVC, animated: true)
        }
    }
    
    @IBAction func returnToBrandList(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: BrandListVC.self, animated: true)
    }
    
    @IBAction func goToNews(_ sender: UIButton) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is NewsVC}).first {
            navigationController?.popToViewController(destinationViewController, animated: true)
        } else {
            let newsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
            self.navigationController?.pushViewController(newsVC, animated: true)
        }
    }
    
    @IBAction func goToReportList(_ sender: UIButton) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is ReportListVC}).first {
            navigationController?.popToViewController(destinationViewController, animated: true)
        } else {
            let reportListVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportListVC") as! ReportListVC
            self.navigationController?.pushViewController(reportListVC, animated: true)
        }
        
    }
    
    @IBAction func goToStatus(_ sender: UIButton) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is StatusVC}).first {
            navigationController?.popToViewController(destinationViewController, animated: true)
        } else {
            let statusVC = self.storyboard?.instantiateViewController(withIdentifier: "StatusVC") as! StatusVC
            self.navigationController?.pushViewController(statusVC, animated: true)
        }
    }
    
    @IBAction func goToPresets(_ sender: UIButton) {
        let presetVC = self.storyboard?.instantiateViewController(withIdentifier: "PresetVC") as! PresetVC
        self.navigationController?.pushViewController(presetVC, animated: true)
    }
    
    @IBAction func goToConfig(_ sender: UIButton) {
        let configVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfigVC") as! ConfigVC
        self.navigationController?.pushViewController(configVC, animated: true)
    }
    
    @IBAction func goToTermCond(_ sender: UIButton) {
        let termsVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsVC") as! TermsVC
        termsVC.tycText = info.tyc
        self.navigationController?.pushViewController(termsVC, animated: true)
    }
    
    @IBAction func goToLinkedin(_ sender: UIButton) {
        if let url = URL(string: info.linkedin) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "Error", message: "No se ha encontrado la página de LinkedIn")
        }
    }
    
    @IBAction func goToInstagram(_ sender: UIButton) {
        if let url = URL(string: info.instagram) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "Error", message: "No se ha encontrado la página de Instagram")
        }
    }
    
    @IBAction func logoutUser(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
