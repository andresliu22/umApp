//
//  ReportCVCell.swift
//  un
//
//  Created by Andres Liu on 1/13/21.
//

import UIKit

class ReportCVCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var backgroundImg: UIImageView!
    static let identifier = "Report"
    
    public func listReport(title: String, description: String, backgroundImg: String){
        self.title.text = title
        self.desc.text = description
        self.backgroundImg.image = UIImage(named: backgroundImg)
    }
}
