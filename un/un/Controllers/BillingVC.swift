//
//  BillingVC.swift
//  un
//
//  Created by Andres Liu on 1/22/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class BillingVC: UIViewController {

    
    @IBOutlet weak var totalConsumed: UILabel!
    @IBOutlet weak var graphView: UIView!
    
    @IBOutlet weak var totalBilled: UILabel!
    @IBOutlet weak var totalToBill: UILabel!
    @IBOutlet weak var totalToPay: UILabel!
    @IBOutlet weak var totalPaid: UILabel!
    
    var lineChart = LineChartView()
    var idCurrency = 2
    var graphData = [GraphElement]()
    var graphicColors: [UIColor] = [UIColor(rgb: 0x7F2246), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F)]
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    
    let date = Date()
    let calendar = Calendar.current
    var year = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        year = calendar.component(.year, from: date)
        getLineChart()
    }
    
    func getLineChart() {
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["year": year, "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.facturacionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                var totalFacturadoQ: Float = 0.0
                var totalPorFacturarQ: Float = 0.0
                var totalPagadoQ: Float = 0.0
                var totalPorPagarQ: Float = 0.0
                
                for i in 0..<12 {
                    let element = GraphElement(name: self.months[i], amount: 0.0)
                    self.graphData.append(element)
                }
                
                for month in jsonData["billings"].arrayValue {
            
                    let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(month["month"].string!) == .orderedSame })
                    self.graphData[Int(index!)].amount += month["amountConsumed"].float ?? 0
                    totalFacturadoQ += month["amountInvoice"].float ?? 0
                    totalPorFacturarQ += month["amountToBilled"].float ?? 0
                    totalPagadoQ += month["amountPaid"].float ?? 0
                    totalPorPagarQ += month["amountToPay"].float ?? 0
                }
                
                self.totalBilled.text = "$ \(Double(totalFacturadoQ / 1000000).round(to: 2))MM"
                self.totalToBill.text = "$ \(Double(totalPorFacturarQ / 1000000).round(to: 2))MM"
                self.totalPaid.text = "$ \(Double(totalPagadoQ / 1000000).round(to: 2))MM"
                self.totalToPay.text = "$ \(Double(totalPorPagarQ / 1000000).round(to: 2))MM"
                
                self.graphData = self.graphData.filter{ $0.amount > 0}
                print(self.graphData)
                print(self.graphData.count)
                self.showLineChart(dataPoints: self.monthsInitials)
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showLineChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
            clearGraphView()

            self.lineChart.frame = CGRect(x: 0, y: 0, width: self.graphView.frame.size.width, height: self.graphView.frame.height - 20)

            // Y - Axis Setup
            let yaxis = self.lineChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.white
            yaxis.axisLineColor = UIColor.white
            yaxis.labelPosition = .insideChart
            yaxis.enabled = false
            self.lineChart.rightAxis.enabled = false

            // X - Axis Setup
            let xaxis = self.lineChart.xAxis
            xaxis.drawGridLinesEnabled = false
            xaxis.labelTextColor = UIColor.black
            xaxis.axisLineColor = UIColor.white
            xaxis.granularityEnabled = true
            xaxis.enabled = true
            xaxis.labelPosition = .bottom
            xaxis.labelFont = UIFont(name: "Georgia",
                                     size: 12.0)!
            xaxis.drawGridLinesEnabled = false
            xaxis.valueFormatter = IndexAxisValueFormatter(values: self.monthsInitials)
            
            self.graphView.addSubview(self.lineChart)

            var entries = [ChartDataEntry]()
            
            var totalConsumed = 0.0
            for x in 0..<graphData.count {
                entries.append(ChartDataEntry(x: Double(x), y: Double(graphData[x].amount / 1000000).round(to: 2)))
                totalConsumed += Double(graphData[x].amount / 1000000).round(to: 2)
            }
            
            self.totalConsumed.text = "$ \(String(format: "%.2f", totalConsumed))MM"
            
            let set = LineChartDataSet(values: entries, label: "1")
            set.mode = .linear
            set.setCircleColor(#colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1))
            set.circleHoleColor = #colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1)
            set.setColor(#colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1))
            set.circleRadius = 0
            set.lineWidth = 2
            set.drawValuesEnabled = false
            let data = LineChartData(dataSet: set)
            self.lineChart.data = data
        
            self.lineChart.chartDescription.enabled = false
            self.lineChart.legend.enabled = false
            self.lineChart.rightAxis.enabled = false
            self.lineChart.keepPositionOnRotation = true
            self.lineChart.clipValuesToContentEnabled = true

            self.lineChart.setVisibleXRangeMaximum(8)
            self.lineChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            self.lineChart.doubleTapToZoomEnabled = false
            
        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    
    func clearGraphView() {
        self.lineChart.removeFromSuperview()
    }
    
    @IBAction func goToDetails(_ sender: UIButton) {
        let billingDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BillingDetailVC") as! BillingDetailVC
        self.navigationController?.pushViewController(billingDetailVC, animated: false)
    }
    
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
