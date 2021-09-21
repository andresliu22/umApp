//
//  FirstLegendCVCell.swift
//  un
//
//  Created by Andres Liu on 1/18/21.
//

import UIKit

class FirstLegendCVCell: UICollectionViewCell {
    
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var percentage: UILabel!

    public func listarElementos(text1: String, text2: String){
        amount.text = text1
        percentage.text = text2
    }
}
