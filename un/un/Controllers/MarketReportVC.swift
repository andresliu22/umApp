//
//  MarketReportVC.swift
//  un
//
//  Created by Andres Liu on 1/21/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import PDFKit
import WebKit

class MarketReportVC: UIViewController {
    
    @IBOutlet weak var reporteSemestralCV: UICollectionView!
    @IBOutlet weak var reporteCoyunturaCV: UICollectionView!
    
    var arraySemestral = [MarketReport]()
    var arrayCoyuntura = [MarketReport]()
    
    var reporteSeleccionado = 1
    
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reporteSemestralCV.dataSource = self
        reporteSemestralCV.delegate = self
        
        reporteCoyunturaCV.dataSource = self
        reporteCoyunturaCV.delegate = self
        
        getReportes()
    }
    
    func getReportes() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.reporteMercadoURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                print(jsonData)
                for reporte in jsonData["marketReports"].arrayValue {
                    var newPdf = reporte["pdfUrl"].string!.replacingOccurrences(of:#"\"#, with: "")
                    newPdf = newPdf.replacingOccurrences(of:" ", with: "%20")
                    let newImg = reporte["imageUrl"].string!.replacingOccurrences(of:#"\"#, with: "")
            
                    let reportElement = MarketReport(title: reporte["title"].string!, subtitle: reporte["subtitle"].string!, imageUrl: newImg, reportType: reporte["reportType"].string!, pdfUrl: newPdf)
                    
                    if reporte["reportType"].string! == "SEMESTRALES" {
                        self.arraySemestral.append(reportElement)
                    } else if reporte["reportType"].string! == "COYUNTURA" {
                        self.arrayCoyuntura.append(reportElement)
                    }
                    
                }
                self.reporteSemestralCV.reloadData()
                self.reporteCoyunturaCV.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func createWebView(withFrame frame: CGRect, urlPath: String) -> WKWebView? {
        
        webView.frame = frame
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let resourceUrl = URL(string: urlPath) {
            let request = URLRequest(url: resourceUrl)
            webView.load(request)
            
            return webView
        }
        
        return nil
    }
    
    func displayWebView(urlPath: String) {
        if let webView = self.createWebView(withFrame: self.view.bounds, urlPath: urlPath) {
            self.view.addSubview(webView)
            let doneButton = UIButton()
            doneButton.frame = CGRect(x: webView.frame.maxX - 100, y: 40, width: 80, height: 30)
            doneButton.setTitle("Cerrar", for: .normal)
            doneButton.backgroundColor = #colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1)
            doneButton.setTitleColor(UIColor.white, for: .normal)
            doneButton.titleLabel?.font = UIFont(name: "Georgia",
                                                 size: 12.0)!
            //doneButton.addBorders(width: 1)
            doneButton.layer.cornerRadius = 10
            doneButton.addTarget(self, action: #selector(closePDF), for: .touchUpInside)
            webView.addSubview(doneButton)
        }
    }
    
    @objc func closePDF() {
        webView.removeFromSuperview()
    }

    
    @IBAction func goToSemestralList(_ sender: UIButton) {
        let marketReportListVC = self.storyboard?.instantiateViewController(withIdentifier: "MarketReportListVC") as! MarketReportListVC
        marketReportListVC.tipoReporte = 1
        self.navigationController?.pushViewController(marketReportListVC, animated: true)
    }
    @IBAction func goToCoyunturaList(_ sender: UIButton) {
        let marketReportListVC = self.storyboard?.instantiateViewController(withIdentifier: "MarketReportListVC") as! MarketReportListVC
        marketReportListVC.tipoReporte = 2
        self.navigationController?.pushViewController(marketReportListVC, animated: true)
    }
    
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MarketReportVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == reporteSemestralCV {
            return arraySemestral.count
        } else {
            return arrayCoyuntura.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == reporteSemestralCV {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "semestral", for: indexPath) as? ReporteSemestralCVCell {
                cell.listarReporteSemestral(titulo: arraySemestral[indexPath.row].title, imagenURL: arraySemestral[indexPath.row].imageUrl, fecha: arraySemestral[indexPath.row].subtitle)
                
                cell.layer.backgroundColor = #colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1)
                return cell
            } else {
                return UICollectionViewCell()
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "coyuntura", for: indexPath) as? ReporteCoyunturaCVCell {
                cell.listarReporteCoyuntura(titulo: arrayCoyuntura[indexPath.row].title, imagenURL: arrayCoyuntura[indexPath.row].imageUrl, fecha: arrayCoyuntura[indexPath.row].subtitle)
                
                cell.layer.backgroundColor = #colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1)
                return cell
            } else {
                return UICollectionViewCell()
            }
        }
    }
    
    
}

extension MarketReportVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == reporteSemestralCV {
            displayWebView(urlPath: arraySemestral[indexPath.row].pdfUrl)
        } else {
            displayWebView(urlPath: arrayCoyuntura[indexPath.row].pdfUrl)
        }
        
    }
}

extension MarketReportVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = ((self.view.frame.height - 120) / 2) * 0.85 - 40
        let cellWidth = cellHeight / 3 * 2
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
