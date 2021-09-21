//
//  MotiveVC.swift
//  un
//
//  Created by Andres Liu on 1/25/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class MotiveVC: UIViewController {
    
    @IBOutlet weak var motivoTitle: UILabel!
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
    
    var alcanceGaugeGraph = GaugeView()
    var impresionGaugeGraph = GaugeView()
    var gaugeValue = 0
    
    var motiveId = 0
    var vcTitle = "Motivo"
    var campaignName = ""
    var startDate = ""
    var endDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motivoTitle.text = vcTitle
        setGaugeView(graph: alcanceGaugeGraph, view: alcanceGauge)
        setGaugeView(graph: impresionGaugeGraph, view: impresionGauge)
        getInfo()
    }
    
    func setGaugeView(graph: GaugeView, view: UIView) {
        graph.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        graph.value = 0
        graph.setUp()
        graph.backgroundColor = .clear
        graph.setNeedsDisplay()
        view.addSubview(graph)
    }

    func getInfo() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "campaign": campaignName, "starDate": startDate, "endDate": endDate, "idCurrency": UserDefaults.standard.integer(forKey: "moneda")]
        
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                for categoria in jsonData["categories"].arrayValue {
                    let data = categoria["reportData"]
                    if categoria["idCategoryTitle"].int ?? 0 == self.motiveId {
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
                }
                
                
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    @IBAction func returnToMotiveList(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
