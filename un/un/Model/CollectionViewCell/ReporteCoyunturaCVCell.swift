//
//  ReporteCoyunturaCVCell.swift
//  un
//
//  Created by Andres Liu on 1/21/21.
//

import UIKit

class ReporteCoyunturaCVCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageUrl: UIImageView!
    @IBOutlet weak var year: UILabel!
    
    public func listarReporteCoyuntura(titulo: String, imagenURL: String, fecha: String) {
        if let url = NSURL(string: imagenURL) {
            if let data = NSData(contentsOf: url as URL) {
                imageUrl.image = UIImage(data: data as Data)
            }
        }
        title.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        year.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        title.text = titulo
        year.text = fecha
        
    }
}
