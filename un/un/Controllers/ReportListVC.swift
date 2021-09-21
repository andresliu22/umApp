//
//  ReportListVC.swift
//  un
//
//  Created by Andres Liu on 1/13/21.
//

import UIKit
import SwiftyJSON
import Alamofire
import SideMenu

class ReportListVC: UIViewController {

    @IBOutlet weak var reportCollectionView: UICollectionView!
    
    var reportList = [Report]()
    let reportTitle = ["INVERSIÓN", "ESTADO DE CUENTA", "FACTURACIÓN", "RESUMEN DIGITAL", "REPORTE DE MERCADO", "IMPLEMENTACIÓN DE CAMPAÑAS"]
    let reportImg = ["inversion_background", "estado_de_cuenta_background", "facturacion_background", "resumen_digital_background", "reporte_de_mercado_background", "implementacion_de_campanas_background"]

    override func viewDidLoad() {
        super.viewDidLoad()

        reportCollectionView.dataSource = self
        reportCollectionView.delegate = self
        getReportes()
    }
    
    func getReportes() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.reporteURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos en esta marca")
                    return
                }
                for i in 0..<6 {
                    let newReport: Report = Report(title: self.reportTitle[i], description: "", imageUrl: self.reportImg[i])
                    self.reportList.append(newReport)
                }
                for report in jsonData["infoBrand"].arrayValue {
                    let index = self.reportList.firstIndex(where: { $0.title.capitalized == report["title"].string!.capitalized })
                    self.reportList[Int(index!)].description = report["description"].string ?? ""
                }
                self.reportCollectionView.reloadData()
            } else {
                print("Failure")
            }
        })
    }

    @IBAction func openMenu(_ sender: UIButton) {
//        let menu = storyboard?.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuNavigationController
//        menu.presentationStyle = .menuSlideIn
//        menu.presentationStyle.presentingEndAlpha = 0.5
//        menu.presentationStyle.onTopShadowOpacity = 1
//        menu.menuWidth = self.view.frame.width
//        self.present(menu, animated: true, completion: nil)
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is SideMenuVC}).first {
            UserDefaults.standard.setValue(0, forKey: "lastReport")
            navigationController?.popToViewController(destinationViewController, animated: true)
        } else {
            let menu = storyboard?.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuVC
    //        menu.presentationStyle = .menuSlideIn
    //        menu.presentationStyle.presentingEndAlpha = 0.5
    //        menu.presentationStyle.onTopShadowOpacity = 1
    //        menu.menuWidth = self.view.frame.width
            self.navigationController?.pushViewController(menu, animated: true)
        }

    }

}

extension ReportListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reportList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReportCVCell.identifier, for: indexPath) as? ReportCVCell {
        
            cell.listReport(title: reportList[indexPath.row].title, description: reportList[indexPath.row].description, backgroundImg: reportList[indexPath.row].imageUrl)
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension ReportListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let inversionVC = storyboard?.instantiateViewController(withIdentifier: "InversionVC") as! InversionVC
            self.navigationController?.pushViewController(inversionVC, animated: true)
            break
        case 1:
            let accountStateVC = storyboard?.instantiateViewController(withIdentifier: "ProjectedVC") as! AccountStateProjectedVC
            self.navigationController?.pushViewController(accountStateVC, animated: true)
            break
        case 2:
            let billingVC = storyboard?.instantiateViewController(withIdentifier: "BillingVC") as! BillingVC
            self.navigationController?.pushViewController(billingVC, animated: true)
            break
        case 3:
            let digitalPerformanceVC = storyboard?.instantiateViewController(withIdentifier: "DigitalPerformanceVC") as! DigitalPerformanceVC
            self.navigationController?.pushViewController(digitalPerformanceVC, animated: true)
            break
        case 4:
            let marketReportVC = storyboard?.instantiateViewController(withIdentifier: "MarketReportVC") as! MarketReportVC
            self.navigationController?.pushViewController(marketReportVC, animated: true)
            break
        case 5:
            let implementationVC = storyboard?.instantiateViewController(withIdentifier: "ImplementationVC") as! ImplementationVC
            self.navigationController?.pushViewController(implementationVC, animated: true)
            break
        default:
            self.performSegue(withIdentifier: "goToInversion", sender: self)
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cell.alpha = 0
        let x = cell.frame.origin.x
        let y = cell.frame.origin.y
        let width = cell.frame.width
        let height = cell.frame.height
        cell.frame = CGRect(x: cell.frame.midX, y: cell.frame.midY, width: width/10, height: height/10)
        UIView.animate(withDuration: 0.8) {
            cell.alpha = 1
            cell.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
}

extension ReportListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 40, height: (self.view.frame.width - 40) / 3 * 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
}

