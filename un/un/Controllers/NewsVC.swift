//
//  NewsVC.swift
//  un
//
//  Created by Andres Liu on 1/14/21.
//

import UIKit
import SwiftyJSON
import Alamofire
import SideMenu

class NewsVC: UIViewController {

    @IBOutlet weak var newsCV: UICollectionView!
    var newsList = [New]()
    override func viewDidLoad() {
        super.viewDidLoad()

        newsCV.dataSource = self
        newsCV.delegate = self
        
        getNews()
    }
    
    func getNews() {
        let serverManager = ServerManager()
        let parameters : Parameters  = [:]
        serverManager.serverCallWithHeadersGET(url: serverManager.noticiaURL, params: parameters, method: .get, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                for noticia in jsonData.arrayValue {
                    let newNoticia: New = New(title: noticia["title"].string!, description: noticia["description"].string!, linkURL: noticia["subtitle"].string!, imageURL: noticia["url_image"].string!)
                    self.newsList.append(newNoticia)
                }
                self.newsCV.reloadData()
            } else {
                print("Failure")
            }
        })
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is SideMenuVC}).first {
            UserDefaults.standard.setValue(1, forKey: "lastReport")
            navigationController?.popToViewController(destinationViewController, animated: true)
        } else {
            let menu = storyboard?.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuVC
    //        menu.presentationStyle = .menuSlideIn
    //        menu.presentationStyle.presentingEndAlpha = 0.5
    //        menu.presentationStyle.onTopShadowOpacity = 1
    //        menu.menuWidth = self.view.frame.width
            self.navigationController?.pushViewController(menu, animated: true)
        }
    }
    
}

extension NewsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newCell", for: indexPath) as? NewCVCell {
            
            cell.listNew(imagenURL: newsList[indexPath.row].imageURL, titulo: newsList[indexPath.row].title, fecha: newsList[indexPath.row].description)
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    
}

extension NewsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: newsList[indexPath.row].linkURL) {
            UIApplication.shared.open(url)
        }
    }
}

extension NewsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 40, height: (self.view.frame.width - 40) / 3 * 2)
    }
}

