//
//  AccountStateProjectedVC.swift
//  un
//
//  Created by Andres Liu on 1/20/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts
import SideMenu

class AccountStateProjectedVC: UIViewController {

    
    @IBOutlet weak var fullYear: UILabel!
    @IBOutlet weak var ytd: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var legendCV: UICollectionView!
    
    var arrayMedia = [Int]()
    var arrayProvider = [Int]()
    var arrayVehicle = [Int]()
    
    var mediaList = [FilterBody]()
    var providerList = [FilterBody]()
    var vehicleList = [FilterBody]()
    
    var barChart = BarChartView()
    var graphData = [EstadoCuentaProyectadoStruct]()
    
    var graphicColors: [UIColor] = [UIColor(rgb: 0xF34627), UIColor(rgb: 0x5FF281)]
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    let legendValues = ["Consumido", "Pagado"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        legendCV.dataSource = self
        legendCV.delegate = self
        ProjectedManager.shared.projectedVC = self
        getMedia()
    }
    
    func getMedia(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.mediaURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de medios")
                    return
                }
                for media in jsonData["mediaInversionList"].arrayValue {
                    let newMedia: FilterBody = FilterBody(id: media["id"].int!, name: media["name"].string!)
                    self.mediaList.append(newMedia)
                    self.arrayMedia.append(newMedia.id)
                }
                self.getProviders()
            } else {
                print("Failure")
            }
        })
    }
    
    func getProviders(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaProvidersURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
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
                        self.arrayProvider.append(newProvider.id)
                    }
                }
                self.getVehicle()
            } else {
                print("Failure")
            }
        })
    }
    
    func getVehicle(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.vehicleURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de vehículos")
                    return
                }
                for vehicle in jsonData["vehicleInversionList"].arrayValue {
                    let newVehicle: FilterBody = FilterBody(id: vehicle["idVehicle"].int!, name: vehicle["name"].string!)
                    self.vehicleList.append(newVehicle)
                    self.arrayVehicle.append(newVehicle.id)
                }
                self.getBarChart()
            } else {
                print("Failure")
            }
        })
    }
    
    func getBarChart() {
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["medias": arrayMedia, "providers": arrayProvider, "vihicles": arrayVehicle, "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
//        let parameters : Parameters  = ["medias": [1,2,3,4,5,6,7,8,9], "providers": [1,4,6,32,75,144,429,569], "vihicles": [5,4,3,1,3276,2828,3388,1668], "idCurrency": 2, "idBrand": 596]
        
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaProyectadoURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                let data = jsonData["projected"]
                for i in 0..<12 {
                    let element = EstadoCuentaProyectadoStruct(name: self.months[i], consumido: 0.0, pagado: 0.0)
                    self.graphData.append(element)
                }
                
                var fullYearQ = ""
                if data["fullYear"].float! < 1000 {
                    fullYearQ = "$ \(String(format: "%.2f", data["fullYear"].float!))"
                } else if data["fullYear"].float! < 1000000 {
                    fullYearQ = "$ \(String(format: "%.2f", data["fullYear"].float!/1000))K"
                } else {
                    fullYearQ = "$ \(String(format: "%.2f", data["fullYear"].float!/1000000))MM"
                }
                self.fullYear.text = fullYearQ
                
                var ytdQ = ""
                if data["ytd"].float! < 1000 {
                    ytdQ = "$ \(String(format: "%.2f", data["ytd"].float!))"
                } else if data["ytd"].float! < 1000000 {
                    ytdQ = "$ \(String(format: "%.2f", data["ytd"].float!/1000))K"
                } else {
                    ytdQ = "$ \(String(format: "%.2f", data["ytd"].float!/1000000))MM"
                }
                self.ytd.text = ytdQ
                
                
                for mes in data["months"].arrayValue {
                    for car in mes["cars"].arrayValue {
                        let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(mes["name"].string!) == .orderedSame })
                        if car["name"].string!.caseInsensitiveCompare("CONSUMO") == .orderedSame {
                            self.graphData[Int(index!)].consumido += car["amount"].float!
                        } else if car["name"].string!.caseInsensitiveCompare("PAGADO") == .orderedSame {
                            self.graphData[Int(index!)].pagado += car["amount"].float!
                        }
                    }
                }
                    
                
                //self.graphData = self.graphData.filter{ $0.consumido > 0}
                print(self.graphData)
                print(self.graphData.count)
                self.showBarChart(dataPoints: self.monthsInitials)
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showBarChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
            clearGraphView()

            self.barChart.frame = CGRect(x: 10, y: 5, width: self.graphView.frame.size.width, height: self.graphView.frame.height - 10)

            // Y - Axis Setup
            let yaxis = self.barChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.clear
            yaxis.axisLineColor = UIColor.clear
            yaxis.labelPosition = .insideChart
            yaxis.enabled = true
            yaxis.spaceTop = 0.35
            yaxis.axisMinimum = 0
            
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
            //xaxis.valueFormatter = bottomLabelsAxis.valueFormatter
            xaxis.centerAxisLabelsEnabled = true
            xaxis.valueFormatter = IndexAxisValueFormatter(values: self.monthsInitials)
            xaxis.granularity = 1
            
            graphView.addSubview(barChart)

            var entries = [BarChartDataEntry]()
            var entries2 = [BarChartDataEntry]()
            
            for x in 0..<graphData.count {
                entries.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].consumido / 1000000).round(to: 2)))
                entries2.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].pagado / 1000000).round(to: 2)))
            }
            
            let set = BarChartDataSet(values: entries, label: "1")
            let set2 = BarChartDataSet(values: entries2, label: "2")
            
            set.drawValuesEnabled = false
            set.colors = [UIColor(rgb: 0xF34627)]
            //set.highlightColor = UIColor(rgb: 0x365381)
            set.valueColors = [.black]
            set.valueLabelAngle = -90
            
            set2.drawValuesEnabled = false
            set2.colors = [UIColor(rgb: 0x5FF281)]
            //set2.highlightColor = UIColor(rgb: 0xD0173D)
            set2.valueColors = [.black]
            set2.valueLabelAngle = -90
            
            let barChartRenderer = BarChartEstadoDeCuentaRenderer(dataProvider: barChart, animator: barChart.chartAnimator, viewPortHandler: barChart.viewPortHandler)
            barChart.renderer = barChartRenderer
            
            var datasets = [BarChartDataSet]()
            datasets.append(set)
            datasets.append(set2)
            
            let chartData = BarChartData(dataSets: datasets)
            chartData.setDrawValues(true)
            chartData.setValueTextColor(UIColor.black)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 2
            pFormatter.multiplier = 1.0
            //pFormatter.zeroSymbol = ""
            pFormatter.currencySymbol = "$"
            pFormatter.positiveSuffix = "MM"
            chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = 0.3
            // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"

            let groupCount = self.months.count
            let startYear = 0

            chartData.barWidth = barWidth
            barChart.xAxis.axisMinimum = Double(startYear)
            let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            barChart.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
            chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
            barChart.notifyDataSetChanged()
            barChart.data = chartData
            barChart.data?.setValueFont(UIFont(name: "Georgia",
                                                    size: 12.0)!)
            
            barChart.chartDescription.enabled = false
            barChart.legend.enabled = false
            barChart.rightAxis.enabled = false
            barChart.drawValueAboveBarEnabled = true
            barChart.setVisibleXRangeMaximum(6)
            barChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            barChart.doubleTapToZoomEnabled = false
            barChart.highlightPerTapEnabled = false
            self.legendCV.reloadData()
            
        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    func clearGraphView() {
        self.barChart.removeFromSuperview()
    }
    
    @IBAction func goToProjected(_ sender: UIButton) {
    }
    @IBAction func goToContracts(_ sender: UIButton) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is AccountStateContractVC}).first {
            navigationController?.popToViewController(destinationViewController, animated: false)
        } else {
            let contractVC = self.storyboard?.instantiateViewController(withIdentifier: "ContractVC") as! AccountStateContractVC
            self.navigationController?.pushViewController(contractVC, animated: false)
        }
    }
    @IBAction func goToOrion(_ sender: UIButton) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is AccountStateOrionVC}).first {
            navigationController?.popToViewController(destinationViewController, animated: false)
        } else {
            let orionVC = self.storyboard?.instantiateViewController(withIdentifier: "OrionVC") as! AccountStateOrionVC
            self.navigationController?.pushViewController(orionVC, animated: false)
        }
    }
    @IBAction func showFIlters(_ sender: UIButton) {
        let projectedFilter = storyboard?.instantiateViewController(withIdentifier: "ProjectedFilters") as! SideMenuNavigationController
        projectedFilter.presentationStyle = .menuSlideIn
        projectedFilter.presentationStyle.presentingEndAlpha = 0.5
        projectedFilter.presentationStyle.onTopShadowOpacity = 1
        projectedFilter.menuWidth = self.view.frame.width * 0.75
        
        present(projectedFilter, animated: true) {
            ProjectedFilterManager.shared.projectedFiltersVC.arrayMedia = self.arrayMedia
            ProjectedFilterManager.shared.projectedFiltersVC.arrayProvider = self.arrayProvider
            ProjectedFilterManager.shared.projectedFiltersVC.arrayVehicle = self.arrayVehicle
            
            ProjectedFilterManager.shared.projectedFiltersVC.mediaList = self.mediaList
            ProjectedFilterManager.shared.projectedFiltersVC.providerList = self.providerList
            ProjectedFilterManager.shared.projectedFiltersVC.vehicleList = self.vehicleList
            
            ProjectedFilterManager.shared.projectedFiltersVC.changeButtonTitle(ProjectedFilterManager.shared.projectedFiltersVC.buttonMedia, self.arrayMedia, self.mediaList)
            ProjectedFilterManager.shared.projectedFiltersVC.changeButtonTitle(ProjectedFilterManager.shared.projectedFiltersVC.buttonProvider, self.arrayProvider, self.providerList)
            ProjectedFilterManager.shared.projectedFiltersVC.changeButtonTitle(ProjectedFilterManager.shared.projectedFiltersVC.buttonVehicle, self.arrayVehicle, self.vehicleList)
        }
    }
    
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AccountStateProjectedVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondLegend", for: indexPath) as? SecondLegendCVCell {
            
            cell.listarEle(color: graphicColors[indexPath.row], nombre: legendValues[indexPath.row])

            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    

}

extension AccountStateProjectedVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 100 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)

        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 10, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let label = UILabel(frame: CGRect.zero)
        label.text = legendValues[indexPath.row]
        label.sizeToFit()
        return CGSize(width: label.frame.width + 20, height: 20)
    }
}
