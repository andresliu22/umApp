//
//  SecondLegendCVCell.swift
//  un
//
//  Created by Andres Liu on 1/18/21.
//

import UIKit

class SecondLegendCVCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var circle: UIImageView!

    public func listarEle(color: UIColor, nombre: String){
        circle.tintColor = color
        name.text = nombre
    }
}
