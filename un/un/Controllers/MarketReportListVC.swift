//
//  MarketReportListVC.swift
//  un
//
//  Created by Andres Liu on 1/21/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class MarketReportListVC: UIViewController {

    @IBOutlet weak var reportTableView: UITableView!
    var tipoReporte = 1
    var arrayReportes = [MarketReport]()
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reportTableView.dataSource = self
        reportTableView.delegate = self
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
                for reporte in jsonData["marketReports"].arrayValue {
                    var newPdf = reporte["pdfUrl"].string!.replacingOccurrences(of:#"\"#, with: "")
                    newPdf = newPdf.replacingOccurrences(of:" ", with: "%20")
                    let newImg = reporte["imageUrl"].string!.replacingOccurrences(of:#"\"#, with: "")
                    let reportElement = MarketReport(title: reporte["title"].string!, subtitle: reporte["subtitle"].string!, imageUrl: newImg, reportType: reporte["reportType"].string!, pdfUrl: newPdf)
                    
                    if self.tipoReporte == 1 {
                        if reporte["reportType"].string! == "SEMESTRALES" {
                            self.arrayReportes.append(reportElement)
                        }
                    } else if self.tipoReporte == 2 {
                        if reporte["reportType"].string! == "COYUNTURA" {
                           self.arrayReportes.append(reportElement)
                       }
                    }
                }
                self.reportTableView.reloadData()
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
    @IBAction func returnToMarketReport(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }


}

extension MarketReportListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayReportes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "ListadoReporteMercadoCell")
        
        cell.textLabel?.font = UIFont(name: "Georgia",
                                      size: 15.0)
        
        cell.textLabel?.text = "\(arrayReportes[indexPath.row].title) - \(arrayReportes[indexPath.row].subtitle)"
        
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right")!.withTintColor(.black, renderingMode: .alwaysOriginal))

        return cell
    }
    
    
}

extension MarketReportListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayWebView(urlPath: arrayReportes[indexPath.row].pdfUrl)
    }
}
