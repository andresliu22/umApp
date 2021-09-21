//
//  ReporteSemestralCVCell.swift
//  un
//
//  Created by Andres Liu on 1/21/21.
//

import UIKit

class ReporteSemestralCVCell: UICollectionViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var imageUrl: UIImageView!
    @IBOutlet var year: UILabel!
    
    public func listarReporteSemestral(titulo: String, imagenURL: String, fecha: String) {
        if let url = NSURL(string: imagenURL) {
            if let data = NSData(contentsOf: url as URL) {
                imageUrl.image = UIImage(data: data as Data)
            }
        }
        
        title.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        year.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        title.text = titulo
        year.text = fecha
        
    }
}
