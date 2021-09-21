//
//  AccountStateContractVC.swift
//  un
//
//  Created by Andres Liu on 1/20/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts
import SideMenu

class AccountStateContractVC: UIViewController {

    @IBOutlet weak var consumoAnualLabel: UILabel!
    @IBOutlet weak var gaugeView: UIView!
    @IBOutlet weak var graphView: UIView!
    
    var arrayProvider = [Int]()
    var arrayYear = [Int]()
    
    var providerList = [FilterBody]()
    var yearList = [FilterBody]()
    
    var barChart = BarChartView()
    
    var gaugeValue = 0
    var graphData = [GraphElement]()
    var gaugeGraph = GaugeView()
    
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ContractManager.shared.contractVC = self
        getFilters()
        
        gaugeGraph.frame = CGRect(x: 0, y: 0, width: gaugeView.frame.width, height: gaugeView.frame.height)
        gaugeGraph.value = gaugeValue
        gaugeGraph.setUp()
        gaugeGraph.backgroundColor = .clear
        gaugeGraph.setNeedsDisplay()
        gaugeView.addSubview(gaugeGraph)
        
    }
    
    func getProviders(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaContractProvidersURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de proveedores")
                    return
                }
                for provider in jsonData["providerList"].arrayValue {
                    let isContained = self.providerList.contains { $0.id == provider["idProvider"].int! }
                    
                    if !isContained {
                        let newProvider: FilterBody = FilterBody(id: provider["idProvider"].int!, name: provider["name"].string!)
                        self.providerList.append(newProvider)
                    }
                    
                }
                self.arrayProvider.append(self.providerList[0].id)
                self.getBarChart()
            } else {
                print("Failure")
            }
        })
    }
    
    func getFilters() {
        yearList = NetworkManager.shared.getYears()
        arrayYear.append(yearList[yearList.count - 1].id)
        getProviders()
    }
    
    func getBarChart() {
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idProvider": arrayProvider[0], "year": arrayYear[0], "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaContratoURL, params: parameters, method: .post, callback: { [self]  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                let data = jsonData["contract"]
                for i in 0..<12 {
                    let element = GraphElement(name: self.months[i], amount: 0.0)
                    self.graphData.append(element)
                }
                    
                var currentValueQ = ""
                if data["currentValue"].float! < 1000 {
                    currentValueQ = "$ \(String(format: "%.2f", data["currentValue"].float!))"
                } else if data["currentValue"].float! < 1000000 {
                    currentValueQ = "$ \(String(format: "%.2f", data["currentValue"].float!/1000))K"
                } else {
                    currentValueQ = "$ \(String(format: "%.2f", data["currentValue"].float!/1000000))MM"
                }
                
                var expectedValueQ = ""
                if data["expectedValue"].float! < 1000 {
                    expectedValueQ = "$ \(String(format: "%.2f", data["expectedValue"].float!))"
                } else if data["expectedValue"].float! < 1000000 {
                    expectedValueQ = "$ \(String(format: "%.2f", data["expectedValue"].float!/1000))K"
                } else {
                    expectedValueQ = "$ \(String(format: "%.2f", data["expectedValue"].float!/1000000))MM"
                }
                
                self.consumoAnualLabel.text = "\(currentValueQ) / \(expectedValueQ)"
                self.gaugeValue = Int(data["currentValue"].float!/data["expectedValue"].float! * 100)
                
                if self.gaugeValue > 100 {
                    self.gaugeValue = 100
                }
                for mes in data["months"].arrayValue {
                    let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(mes["name"].string!) == .orderedSame })
                    self.graphData[Int(index!)].amount += mes["amount"].float!

                }
                    
                self.graphData = self.graphData.filter{ $0.amount > 0}
                print(self.graphData)
                print(self.graphData.count)
                
                self.clearGraphView()
                gaugeGraph.value = gaugeValue
                gaugeGraph.valueArea = gaugeValue
                gaugeGraph.setNeedsDisplay()
                self.showBarChart(dataPoints: self.monthsInitials)
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    
    func showBarChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
//            let formatter = BarChartFormatter()
//            formatter.setValues(values: dataPoints)
//            let bottomLabelsAxis: XAxis = XAxis()
//            bottomLabelsAxis.valueFormatter = formatter

            self.barChart.frame = CGRect(x: 10, y: 5, width: self.graphView.frame.size.width - 20, height: self.graphView.frame.height - 20)

            let yaxis = self.barChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.clear
            yaxis.axisLineColor = UIColor.clear
            yaxis.labelPosition = .insideChart
            yaxis.enabled = true
            yaxis.axisMinimum = 0
            self.barChart.rightAxis.enabled = false

            // X - Axis Setup
            let xaxis = self.barChart.xAxis
            xaxis.drawGridLinesEnabled = false
            xaxis.labelTextColor = UIColor.black
            xaxis.axisLineColor = UIColor.white
            xaxis.granularityEnabled = true
            xaxis.enabled = true
            xaxis.labelPosition = .bottom
            xaxis.labelFont = UIFont(name: "Gotham-Bold",
                                     size: 16.0)!
            xaxis.drawGridLinesEnabled = false
            xaxis.valueFormatter = IndexAxisValueFormatter(values: self.monthsInitials)
            
            self.graphView.addSubview(self.barChart)

            var entries = [BarChartDataEntry]()
            
            
            for x in 0..<graphData.count {
                

                entries.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].amount / 1000).round(to: 2)))
            }
            
            let set = BarChartDataSet(values: entries, label: "1")
            set.drawValuesEnabled = false
            set.colors = [UIColor(rgb: 0x18AFD4)]
            
            set.valueColors = [.black]
            set.valueLabelAngle = -90
            
            let barChartRenderer = BarChartEstadoDeCuentaContratosRenderer(dataProvider: barChart, animator: barChart.chartAnimator, viewPortHandler: barChart.viewPortHandler)
            barChart.renderer = barChartRenderer
            
            let chartData = BarChartData(dataSet: set)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 0
            pFormatter.multiplier = 1.0
            //pFormatter.zeroSymbol = ""
            pFormatter.currencySymbol = "$"
            pFormatter.positiveSuffix = "K"
            chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            chartData.barWidth = Double(0.4)
            chartData.setDrawValues(true)
            
            self.barChart.data = chartData
            self.barChart.data?.setValueFont(UIFont(name: "Georgia",
                                                    size: 12.0)!)
            self.barChart.chartDescription.enabled = false
            self.barChart.legend.enabled = false
            self.barChart.rightAxis.enabled = false
            self.barChart.drawValueAboveBarEnabled = true
            self.barChart.notifyDataSetChanged()
            self.barChart.setVisibleXRangeMaximum(8)
            self.barChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            self.barChart.doubleTapToZoomEnabled = false
            self.barChart.extraTopOffset = 30.0
            self.barChart.highlightPerTapEnabled = false
            chartData.setValueTextColor(UIColor.black)
            
        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    
    func clearGraphView() {
        self.barChart.removeFromSuperview()
    }
    
    @IBAction func goToProjected(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: AccountStateProjectedVC.self, animated: false)
    }
    
    @IBAction func goToContract(_ sender: UIButton) {
    }
    
    @IBAction func goToOrion(_ sender: UIButton) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is AccountStateOrionVC}).first {
            navigationController?.popToViewController(destinationViewController, animated: false)
        } else {
            let orionVC = self.storyboard?.instantiateViewController(withIdentifier: "OrionVC") as! AccountStateOrionVC
            self.navigationController?.pushViewController(orionVC, animated: false)
        }
    }
    
    @IBAction func showFilters(_ sender: UIButton) {
        let contractFilter = storyboard?.instantiateViewController(withIdentifier: "ContractFilters") as! SideMenuNavigationController
        contractFilter.presentationStyle = .menuSlideIn
        contractFilter.presentationStyle.presentingEndAlpha = 0.5
        contractFilter.presentationStyle.onTopShadowOpacity = 1
        contractFilter.menuWidth = self.view.frame.width * 0.75
        
        present(contractFilter, animated: true) {
            ContractFilterManager.shared.contractFiltersVC.arrayYear = self.arrayYear
            ContractFilterManager.shared.contractFiltersVC.arrayProvider = self.arrayProvider
            
            ContractFilterManager.shared.contractFiltersVC.yearList = self.yearList
            ContractFilterManager.shared.contractFiltersVC.providerList = self.providerList
            
            ContractFilterManager.shared.contractFiltersVC.changeButtonTitle(ContractFilterManager.shared.contractFiltersVC.buttonYear, self.arrayYear, self.yearList)
            ContractFilterManager.shared.contractFiltersVC.changeButtonTitle(ContractFilterManager.shared.contractFiltersVC.buttonProvider, self.arrayProvider, self.providerList)
        }
        
    }
    @IBAction func returnToReporte(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: ReportListVC.self, animated: true)
    }
}
