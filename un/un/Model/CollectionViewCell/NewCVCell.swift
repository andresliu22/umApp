//
//  NewCVCell.swift
//  un
//
//  Created by Andres Liu on 1/14/21.
//

import UIKit

class NewCVCell: UICollectionViewCell {
    
    
    @IBOutlet weak var newImg: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    public func listNew(imagenURL: String, titulo: String, fecha: String) {
        if let url = NSURL(string: imagenURL) {
            if let data = NSData(contentsOf: url as URL) {
//                newImg.image = UIImage(data: data as Data)!.resizeImage(targetSize: CGSize(width: newImg.frame.width, height: newImg.frame.height))
                newImg.image = UIImage(data: data as Data)
            }
        }
        title.text = titulo
        timestamp.text = fecha
        
    }
}
