//
//  BrandListVC.swift
//  un
//
//  Created by Andres Liu on 1/11/21.
//

import UIKit
import SwiftyJSON
import Alamofire

class BrandListVC: UIViewController {

    @IBOutlet weak var brandCV: UICollectionView!
    
    var brandList = [Brand]()
    
    var selectedBrand = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        brandCV.dataSource = self
        brandCV.delegate = self
        
        validateToken()
    }
    
    func validateToken() {
        let serverManager = ServerManager()
        let userToken = UserDefaults.standard.string(forKey: "userToken")!
        let index = userToken.index(userToken.startIndex, offsetBy: 6)
        let parameters : Parameters  = ["userToken": userToken.suffix(from: index)]
        print(userToken.suffix(from: index))
        serverManager.serverCallWithHeaders(url: serverManager.tolenAuthURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard jsonData["isValid"].boolValue else {
                    let alert = UIAlertController(title: "Error", message: "Token ha expirado, ingresar nuevamente", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true)
                    return
                }
                self.getBrands()
            } else {
                print("Failure")
                let alert = UIAlertController(title: "Error", message: "Token no válido, ingresar nuevamente", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
            }
        })
    }
    
    func getBrands() {
        let serverManager = ServerManager()
        let parameters : Parameters  = [:]
        serverManager.serverCallWithHeadersGET(url: serverManager.marcaURL, params: parameters, method: .get, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay marcas registradas en el usuario")
                    return
                }
                for brand in jsonData.arrayValue {
                    let newBrand: Brand = Brand(id: brand["externalcode"].string!, name: brand["name"].string!)
                    self.brandList.append(newBrand)
                }
                self.brandCV.reloadData()
            } else {
                print("Failure")
                let alert = UIAlertController(title: "Error", message: "Time Limit Exceeded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { _ in self.getBrands()
                }))
                alert.addAction(UIAlertAction(title: "Return", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
            }
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BrandListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brandList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrandCVCell.identifier, for: indexPath) as? BrandCVCell {
            
            if selectedBrand == indexPath.row {
                cell.configure(name: brandList[indexPath.row].name, selected: true)
                cell.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
                cell.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            } else {
                cell.configure(name: brandList[indexPath.row].name, selected: false)
                cell.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
                cell.layer.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2352941176, blue: 0.2392156863, alpha: 1).cgColor
            }
            cell.layer.borderWidth = 1
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
}

extension BrandListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UserDefaults.standard.setValue(brandList[indexPath.row].id, forKey: "idBrand")
        UserDefaults.standard.setValue(brandList[indexPath.row].name, forKey: "brandName")
        selectedBrand = indexPath.row
        brandCV.reloadData()
        
        let menu = storyboard?.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuVC
        let reportListVC = storyboard?.instantiateViewController(withIdentifier: "ReportListVC") as! ReportListVC
        self.navigationController?.pushViewController(menu, animated: false, completion: {
            self.navigationController?.pushViewController(reportListVC, animated: false)
        })
//        self.navigationController?.pushViewController(reportListVC, animated: true)
    }
}

extension BrandListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width - 60, height: 100)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
    }
}
