//
//  DigitalSalesVC.swift
//  un
//
//  Created by Andres Liu on 1/24/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import SideMenu

class DigitalSalesVC: UIViewController {

    @IBOutlet weak var campaignCollectionView: UICollectionView!
    
    var arrayVentas = [RDVenta]()
    var arrayCampaign = [String]()
    var campaignList = [FilterBody]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SalesManager.shared.salesVC = self
        campaignCollectionView.dataSource = self
        campaignCollectionView.delegate = self
        
        getCampaign()
    }
    
    public func getCampaign(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalSalesCampaignsURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de campaña")
                    return
                }
                var count = 1
                for campaign in jsonData["campaignList"].arrayValue {
                    let isContained = self.campaignList.contains { $0.id == campaign["idCampaign"].int! }
                    
                    if !isContained {
                        let newCampaign: FilterBody = FilterBody(id: campaign["idCampaign"].int!, name: campaign["name"].string!)
                        self.campaignList.append(newCampaign)
                        if count == 1 {
                            self.arrayCampaign.append(newCampaign.name)
                            count += 1
                        }
                    }
                }
                self.getVentas()
            } else {
                print("Failure")
            }
        })
    }
    
    func getVentas() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "campaign": arrayCampaign[0], "idCurrency": UserDefaults.standard.integer(forKey: "moneda")]
        
        arrayVentas.removeAll()
        
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalVentasURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                    
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }

                for categoria in jsonData["categories"].arrayValue {
                    var venta = RDVenta(titulo: "\(categoria["categoryTitle"].string!) \(self.arrayCampaign[0])", source: categoria["source"].string ?? "", valorVisitas: 0.0, valorVisitasEsperado: 0.0, valorSesiones: 0.0, valorSesionesEsperado: 0.0, valorConversaciones: 0.0, valorConversacionesEsperado: 0.0)
                    for statistic in categoria["statistics"].arrayValue {
                        if statistic["statTitle"].string!.caseInsensitiveCompare("Visitas") == .orderedSame {
                            venta.valorVisitas = statistic["currentValue"].float ?? 0
                            venta.valorVisitasEsperado = statistic["expectedValue"].float ?? 0
                        } else if statistic["statTitle"].string!.caseInsensitiveCompare("Sesiones") == .orderedSame  {
                            venta.valorSesiones = statistic["currentValue"].float ?? 0
                            venta.valorSesionesEsperado = statistic["expectedValue"].float ?? 0
                        } else if statistic["statTitle"].string!.caseInsensitiveCompare("Conversiones") == .orderedSame  {
                            venta.valorConversaciones = statistic["currentValue"].float ?? 0
                            venta.valorConversacionesEsperado = statistic["expectedValue"].float ?? 0
                        }
                    }
                    print(venta)
                    self.arrayVentas.append(venta)
                }
                
                self.campaignCollectionView.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    @IBAction func returnToPerformance(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func showFilters(_ sender: UIButton) {
        let salesFilter = storyboard?.instantiateViewController(withIdentifier: "SalesFilter") as! SideMenuNavigationController
        salesFilter.presentationStyle = .menuSlideIn
        salesFilter.presentationStyle.presentingEndAlpha = 0.5
        salesFilter.presentationStyle.onTopShadowOpacity = 1
        salesFilter.menuWidth = self.view.frame.width * 0.75
        
        var campaignName = ""
        if !arrayCampaign.isEmpty {
            campaignName = arrayCampaign[0]
        }
        present(salesFilter, animated: true) {
            SalesFilterManager.shared.salesFilterVC.arrayCampaign = self.arrayCampaign
            SalesFilterManager.shared.salesFilterVC.campaignList = self.campaignList
            SalesFilterManager.shared.salesFilterVC.buttonCampaign.setTitle(campaignName, for: .normal)

        }
    }
    
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: ReportListVC.self, animated: true)
    }
}

extension DigitalSalesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayVentas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VentaCell", for: indexPath) as? SalesCVC {
            
            cell.contentView.layer.shadowColor = UIColor.black.cgColor
            cell.contentView.layer.shadowRadius = 3.0
            cell.contentView.layer.shadowOpacity = 0.5
            cell.contentView.layer.masksToBounds = false
            cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.contentView.layer.backgroundColor = UIColor.clear.cgColor
            
            cell.listarVenta(titulo: arrayVentas[indexPath.row].titulo, source: arrayVentas[indexPath.row].source, cantidadVisitas: arrayVentas[indexPath.row].valorVisitas, cantidadVisitasE: arrayVentas[indexPath.row].valorVisitasEsperado, cantidadSesiones: arrayVentas[indexPath.row].valorSesiones, cantidadSesionesE: arrayVentas[indexPath.row].valorSesionesEsperado, cantidadConversaciones: arrayVentas[indexPath.row].valorConversaciones, cantidadConversacionesE: arrayVentas[indexPath.row].valorConversacionesEsperado)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    
}

extension DigitalSalesVC: UICollectionViewDelegate {
    
}

extension DigitalSalesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = self.view.frame.width - 40
        let cellHeight = cellWidth / 3 + 140
        return CGSize(width: cellWidth, height: cellHeight)
        
        
    }
}
