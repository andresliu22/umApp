//
//  SalesCVC.swift
//  un
//
//  Created by Andres Liu on 1/25/21.
//

import UIKit
import Charts

class SalesCVC: UICollectionViewCell {
    
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var imageUrl: UIImageView!
    
    @IBOutlet weak var valorVisitas: UILabel!
    @IBOutlet weak var valorSesiones: UILabel!
    @IBOutlet weak var valorConversaciones: UILabel!
    
    @IBOutlet weak var viewVisitas: UIView!
    @IBOutlet weak var viewSesiones: UIView!
    @IBOutlet weak var viewConversaciones: UIView!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    @IBOutlet weak var cellContent: UIView!
    
    var pieVisitas = PieChartView()
    var pieSesiones = PieChartView()
    var pieConversaciones = PieChartView()
    
    var graphicColorsVisitas: [UIColor] = [UIColor(rgb: 0x18AFD4), UIColor.white]
    var graphicColorsSesiones: [UIColor] = [UIColor(rgb: 0x584EB7), UIColor.white]
    var graphicColorsConversaciones: [UIColor] = [UIColor(rgb: 0xFFC400), UIColor.white]
    
    public func listarVenta(titulo: String, source: String, cantidadVisitas: Float, cantidadVisitasE: Float, cantidadSesiones: Float, cantidadSesionesE: Float, cantidadConversaciones: Float, cantidadConversacionesE: Float) {
        
//        cellContent.layer.cornerRadius = 10
        cellContent.layer.masksToBounds = true
        
        self.titulo.text = titulo
        
        switch source.uppercased() {
        case "INSTAGRAM":
            self.imageUrl.image = UIImage(named: "ig_light")
        case "FACEBOOK":
            self.imageUrl.image = UIImage(named: "fb_light")
        case "TWITTER":
            self.imageUrl.image = UIImage(named: "twitter_light")
        case "GOOGLE":
            self.imageUrl.image = UIImage(named: "google_light")
        case "LINKEDIN":
            self.imageUrl.image = UIImage(named: "linkedin_light")
        case "YOUTUBE":
            self.imageUrl.image = UIImage(named: "youtube_light")
        default:
            self.imageUrl.image = UIImage(named: "google_light")
        }
        
        if cantidadVisitas < 1000 {
            self.valorVisitas.text = "\(String(format: "%.2f", cantidadVisitas))"
        } else {
            self.valorVisitas.text = "\(String(format: "%.2f", cantidadVisitas/1000))K"
        }
        if cantidadSesiones < 1000 {
            self.valorSesiones.text = "\(String(format: "%.2f", cantidadSesiones))"
        } else {
            self.valorSesiones.text = "\(String(format: "%.2f", cantidadSesiones/1000))K"
        }
        if cantidadConversaciones < 1000 {
            self.valorConversaciones.text = "\(String(format: "%.2f", cantidadConversaciones))"
        } else {
            self.valorConversaciones.text = "\(String(format: "%.2f", cantidadConversaciones/1000))K"
        }
        
        self.pieVisitas.frame = CGRect(x: 0, y: 0, width: self.viewVisitas.frame.size.width, height: self.viewVisitas.frame.height)
        self.pieSesiones.frame = CGRect(x: 0, y: 0, width: self.viewSesiones.frame.size.width, height: self.viewSesiones.frame.height)
        self.pieConversaciones.frame = CGRect(x: 0, y: 0, width: self.viewConversaciones.frame.size.width, height: self.viewConversaciones.frame.height)

        self.pieVisitas.drawEntryLabelsEnabled = false
        self.pieVisitas.legend.enabled = false
        self.pieSesiones.drawEntryLabelsEnabled = false
        self.pieSesiones.legend.enabled = false
        self.pieConversaciones.drawEntryLabelsEnabled = false
        self.pieConversaciones.legend.enabled = false

        self.viewVisitas.addSubview(self.pieVisitas)
        self.viewSesiones.addSubview(self.pieSesiones)
        self.viewConversaciones.addSubview(self.pieConversaciones)
        
        //Datos de Visitas
        
        var entriesVisitas = [ChartDataEntry]()
        
        entriesVisitas.append(ChartDataEntry(x: Double(1), y: Double(cantidadVisitas)))
        
        if cantidadVisitasE < 1 {
            self.pieVisitas.centerAttributedText = NSAttributedString.init(string: "0%", attributes: [NSAttributedString.Key.font : UIFont(name: "Gotham-Bold", size: 20.0)!])
            entriesVisitas.append(ChartDataEntry(x: Double(2), y: Double(1)))
        } else {
            self.pieVisitas.centerAttributedText = NSAttributedString.init(string: "\(String(format: "%.0f",(cantidadVisitas / cantidadVisitasE * 100)))%", attributes: [NSAttributedString.Key.font : UIFont(name: "Gotham-Bold", size: 20.0)!])
            entriesVisitas.append(ChartDataEntry(x: Double(2), y: Double(cantidadVisitasE - cantidadVisitas)))
        }
        
        let setVisitas = PieChartDataSet(values: entriesVisitas, label: "1")
        setVisitas.sliceBorderWidth = 1.0
        setVisitas.sliceBorderColor = UIColor(rgb: 0x18AFD4)
        setVisitas.colors = self.graphicColorsVisitas
        setVisitas.drawValuesEnabled = false
        //set.colors = ChartColorTemplates.material()
        let dataVisitas = PieChartData(dataSet: setVisitas)
        self.pieVisitas.data = dataVisitas
        self.pieVisitas.holeRadiusPercent = 0.65
        self.pieVisitas.holeColor = UIColor(rgb: 0x18AFD4)
        self.pieVisitas.holeBorderColor = UIColor.white
        
        
        
    
        
        //Datos de Sesiones
        
        var entriesSesiones = [ChartDataEntry]()
        
        entriesSesiones.append(ChartDataEntry(x: Double(1), y: Double(cantidadSesiones)))
        
        if cantidadSesionesE < 1 {
            self.pieSesiones.centerAttributedText = NSAttributedString.init(string: "0%", attributes: [NSAttributedString.Key.font : UIFont(name: "Gotham-Bold", size: 20.0)!])
            entriesSesiones.append(ChartDataEntry(x: Double(2), y: Double(1)))
        } else {
            self.pieSesiones.centerAttributedText = NSAttributedString.init(string: "\(String(format: "%.0f", (cantidadSesiones / cantidadSesionesE * 100)))%", attributes: [NSAttributedString.Key.font : UIFont(name: "Gotham-Bold", size: 20.0)!])
            entriesSesiones.append(ChartDataEntry(x: Double(2), y: Double(cantidadSesionesE - cantidadSesiones)))
        }
        
        
        let setSesiones = PieChartDataSet(values: entriesSesiones, label: "1")
        setSesiones.sliceBorderWidth = 1.0
        setSesiones.sliceBorderColor = UIColor(rgb: 0x584EB7)
        setSesiones.colors = self.graphicColorsSesiones
        setSesiones.drawValuesEnabled = false
        //set.colors = ChartColorTemplates.material()
        let dataSesiones = PieChartData(dataSet: setSesiones)
        self.pieSesiones.data = dataSesiones
        self.pieSesiones.holeRadiusPercent = 0.65
        self.pieSesiones.holeColor = UIColor(rgb: 0x584EB7)
        self.pieSesiones.holeBorderColor = UIColor.white
        
        //Datos de Conversaciones
        
        var entriesConversaciones = [ChartDataEntry]()
        
        entriesConversaciones.append(ChartDataEntry(x: Double(1), y: Double(cantidadConversaciones)))
        
        if cantidadConversacionesE < 1 {
            self.pieConversaciones.centerAttributedText = NSAttributedString.init(string: "0%", attributes: [NSAttributedString.Key.font : UIFont(name: "Gotham-Bold", size: 20.0)!])
            entriesConversaciones.append(ChartDataEntry(x: Double(2), y: Double(1)))
        } else {
            self.pieConversaciones.centerAttributedText = NSAttributedString.init(string: "\(String(format: "%.0f", (cantidadConversaciones / cantidadConversacionesE * 100)))%", attributes: [NSAttributedString.Key.font : UIFont(name: "Gotham-Bold", size: 20.0)!])
            entriesConversaciones.append(ChartDataEntry(x: Double(2), y: Double(cantidadConversacionesE - cantidadConversaciones)))
        }
        
        
        let setConversaciones = PieChartDataSet(values: entriesConversaciones, label: "1")
        setConversaciones.sliceBorderWidth = 1.0
        setConversaciones.sliceBorderColor = UIColor(rgb: 0xFFC400)
        setConversaciones.colors = self.graphicColorsConversaciones
        setConversaciones.drawValuesEnabled = false
        //set.colors = ChartColorTemplates.material()
        let dataConversaciones = PieChartData(dataSet: setConversaciones)
        self.pieConversaciones.data = dataConversaciones
        self.pieConversaciones.holeRadiusPercent = 0.65
        self.pieConversaciones.holeColor = UIColor(rgb: 0xFFC400)
        self.pieConversaciones.holeBorderColor = UIColor.white
        
        
        self.pieVisitas.highlightPerTapEnabled = false
        self.pieSesiones.highlightPerTapEnabled = false
        self.pieConversaciones.highlightPerTapEnabled = false
        
        self.pieVisitas.animate(yAxisDuration: 1.0, easingOption: .linear)
        self.pieSesiones.animate(yAxisDuration: 1.0, easingOption: .linear)
        self.pieConversaciones.animate(yAxisDuration: 1.0, easingOption: .linear)
        
    }
}
