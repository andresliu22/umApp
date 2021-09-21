//
//  BrandCVCell.swift
//  un
//
//  Created by Andres Liu on 1/11/21.
//

import UIKit

class BrandCVCell: UICollectionViewCell {
    
    @IBOutlet weak var brandName: UILabel!
    static let identifier = "Brand"
    
    public func configure(name: String, selected: Bool){
        brandName.text = name
        brandName.sizeToFit()
        
        guard selected else { brandName.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1); return }
        brandName.textColor = #colorLiteral(red: 0.2392156863, green: 0.2352941176, blue: 0.2392156863, alpha: 1)
    }
    
}
