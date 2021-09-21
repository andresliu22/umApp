//
//  DigitalPerformanceVC.swift
//  un
//
//  Created by Andres Liu on 1/24/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import SideMenu

class DigitalPerformanceVC: UIViewController {

    @IBOutlet weak var inversionTotal: UILabel!
    @IBOutlet weak var inversionAlcance: UILabel!
    @IBOutlet weak var inversionAlcanceEsperado: UILabel!
    @IBOutlet weak var inversionImpresiones: UILabel!
    @IBOutlet weak var inversionImpresionesCPM: UILabel!
    @IBOutlet weak var clicksTotal: UILabel!
    @IBOutlet weak var ctrTotal: UILabel!
    @IBOutlet weak var cpcTotal: UILabel!
    @IBOutlet weak var clicksLinkTotal: UILabel!
    @IBOutlet weak var ctrLinkTotal: UILabel!
    @IBOutlet weak var cpcLinkTotal: UILabel!
    @IBOutlet weak var videoTotal: UILabel!
    @IBOutlet weak var vtrTotal: UILabel!
    @IBOutlet weak var cpcSTotal: UILabel!
    @IBOutlet weak var reactionsTotal: UILabel!
    @IBOutlet weak var commentsTotal: UILabel!
    @IBOutlet weak var sharesTotal: UILabel!
    @IBOutlet weak var alcanceGauge: UIView!
    @IBOutlet weak var impresionGauge: UIView!
    
    var arrayCampaign = [String]()
    var campaignList = [FilterBody]()
    var arrayBeforeFilter = [String]()
    var alcanceGaugeGraph = GaugeView()
    var impresionGaugeGraph = GaugeView()
    var gaugeValue = 0
    
    var startDate = ""
    var finishDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PerformanceManager.shared.performanceVC = self
        setGaugeView(graph: alcanceGaugeGraph, view: alcanceGauge)
        setGaugeView(graph: impresionGaugeGraph, view: impresionGauge)
        getDate()
    }
    
    func setGaugeView(graph: GaugeView, view: UIView) {
        graph.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        graph.value = 0
        graph.setUp()
        graph.backgroundColor = .clear
        graph.setNeedsDisplay()
        view.addSubview(graph)
    }
    
    func getDate() {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        var stringDay = ""
        var stringMonth = ""
        if day < 10 {
            stringDay = "0\(day)"
        } else {
            stringDay = "\(day)"
        }
        
        if month < 10 {
            stringMonth = "0\(month)"
        } else {
            stringMonth = "\(month)"
        }
        startDate = "01/\(stringMonth)/\(year)"
        finishDate = "\(stringDay)/\(stringMonth)/\(year)"
        
        getCampaign()
    }
    public func getCampaign(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalPerformanceCampaignsURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
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
                self.getPerformance()
            } else {
                print("Failure")
            }
        })
    }
    
    func getPerformance() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "campaign": arrayCampaign[0], "starDate": startDate, "endDate": finishDate, "idCurrency": UserDefaults.standard.integer(forKey: "moneda")]
        
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                if self.arrayCampaign.contains(jsonData["title"].string!) {
                    let data = jsonData["reportData"]
                    print(data["totalClicks"])
                    let motivo = Motive(totalInversion: data["totalInversion"].float ?? 0.0, totalCurrentScope: data["totalCurrentScope"].float ?? 0.0, totalExpectedScope: data["totalExpectedScope"].float ?? 1.0, totalCurrentImpressions: data["totalCurrentImpressions"].float ?? 0.0,  totalExpectedImpressions: data["totalExpectedImpressions"].float ?? 1.0, totalCPMImpressions: data["totalCPMImpressions"].float ?? 0.0, totalClicks: data["totalClicks"].float ?? 0.0, totalLinkClicks: data["totalLinkClicks"].float ?? 0.0, totalCTR: data["totalCTR"].float ?? 0.0, totalLinkCTR: data["totalLinkCTR"].float ?? 0.0, totalCPC: data["totalCPC"].float ?? 0.0, totalLinkCPC: data["totalLinkCPC"].float ?? 0.0, videoViews10: data["videoViews10"].float ?? 0.0, totalVTR: data["totalVTR"].float ?? 0.0, totalCPC10: data["totalCPC10"].float ?? 0.0, postReactions: data["postReactions"].float ?? 0.0, postComments: data["postComments"].float ?? 0.0, postShares: data["postShares"].float ?? 0.0)
                    
                    self.inversionTotal.text = "$ \(motivo.totalInversion)"
                    
                    if motivo.totalCurrentScope < 1000000 {
                        self.inversionAlcance.text = "$ \(String(format: "%.2f", motivo.totalCurrentScope / 1000))K"
                    } else {
                        self.inversionAlcance.text = "$ \(String(format: "%.2f", motivo.totalCurrentScope / 1000000))MM"
                    }
                    
                    if motivo.totalExpectedScope <= 0 {
                        self.inversionAlcanceEsperado.text = "100%"
                    } else {
                        if motivo.totalCurrentScope / motivo.totalExpectedScope > 100 {
                            self.inversionAlcanceEsperado.text = "100%"
                        } else {
                            self.inversionAlcanceEsperado.text = "\(motivo.totalCurrentScope / motivo.totalExpectedScope * 100)%"
                        }
                    }
                    
                    if motivo.totalCurrentImpressions < 1000000 {
                        self.inversionImpresiones.text = "$ \(String(format: "%.2f", motivo.totalCurrentImpressions / 1000))K"
                    } else {
                        self.inversionImpresiones.text = "$ \(String(format: "%.2f", motivo.totalCurrentImpressions / 1000000))MM"
                    }
                    
                    self.inversionImpresionesCPM.text = "$ \(motivo.totalCPMImpressions) CPM"
                    self.clicksTotal.text = "\(String(format: "%.2f",(motivo.totalClicks/1000)))K"
                    self.ctrTotal.text = "\(motivo.totalCTR)%"
                    self.cpcTotal.text = "$ \(motivo.totalCPC)"
                    self.clicksLinkTotal.text = "$ \(String(format: "%.2f", motivo.totalLinkClicks/1000))K"
                    self.ctrLinkTotal.text = "\(motivo.totalLinkCTR)%"
                    self.cpcLinkTotal.text = "$ \(motivo.totalLinkCPC)"
                    self.videoTotal.text = "\(String(format: "%.2f",motivo.videoViews10/1000))K"
                    self.vtrTotal.text = "\(motivo.totalVTR)%"
                    self.cpcSTotal.text = "$ \(motivo.totalCPC10)"
                    self.reactionsTotal.text = "\(String(format: "%.2f",motivo.postReactions/1000))K"
                    self.commentsTotal.text = "\(String(format: "%.2f",motivo.postComments/1000))K"
                    self.sharesTotal.text = "\(String(format: "%.2f",motivo.postShares/1000))K"
                    
                    if motivo.totalExpectedScope <= motivo.totalCurrentScope {
                        self.alcanceGaugeGraph.value = 100
                    } else {
                        self.alcanceGaugeGraph.value = Int(motivo.totalCurrentScope/motivo.totalExpectedScope * 100)
                    }
                    
                    self.alcanceGaugeGraph.valueArea = self.alcanceGaugeGraph.value
                    
                    if motivo.totalExpectedImpressions <= motivo.totalCurrentImpressions {
                        self.impresionGaugeGraph.value = 100
                    } else {
                        self.impresionGaugeGraph.value = Int(motivo.totalCurrentImpressions/motivo.totalExpectedImpressions * 100)
                    }
                    
                    self.impresionGaugeGraph.valueArea = self.impresionGaugeGraph.value
                    
                    self.alcanceGaugeGraph.setNeedsDisplay()
                    self.impresionGaugeGraph.setNeedsDisplay()
                }
                
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func goToMotiveList(){
        let motiveListVC = storyboard?.instantiateViewController(identifier: "MotiveListVC") as! MotiveListVC
        motiveListVC.campaignName = arrayCampaign[0]
        motiveListVC.startDate = startDate
        motiveListVC.endDate = finishDate
        
        self.navigationController?.pushViewController(motiveListVC, animated: true)
    }
    
    @IBAction func goToSales(_ sender: UIButton) {
        let salesVC = self.storyboard?.instantiateViewController(withIdentifier: "DigitalSalesVC") as! DigitalSalesVC
        self.navigationController?.pushViewController(salesVC, animated: false)
    }
    
    @IBAction func showFilters(_ sender: UIButton) {
        let performanceFilter = storyboard?.instantiateViewController(withIdentifier: "PerformanceFilter") as! SideMenuNavigationController
        performanceFilter.presentationStyle = .menuSlideIn
        performanceFilter.presentationStyle.presentingEndAlpha = 0.5
        performanceFilter.presentationStyle.onTopShadowOpacity = 1
        performanceFilter.menuWidth = self.view.frame.width * 0.75
        
        var campaignName = ""
        if !arrayCampaign.isEmpty {
            campaignName = arrayCampaign[0]
        }
        present(performanceFilter, animated: true) {
            PerformanceFilterManager.shared.performanceFiltersVC.arrayCampaign = self.arrayCampaign
            PerformanceFilterManager.shared.performanceFiltersVC.campaignList = self.campaignList
            PerformanceFilterManager.shared.performanceFiltersVC.buttonCampaign.setTitle(campaignName, for: .normal)
            PerformanceFilterManager.shared.performanceFiltersVC.startDateTxt.text = self.startDate
            PerformanceFilterManager.shared.performanceFiltersVC.finishDateTxt.text = self.finishDate
        }
    }
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
