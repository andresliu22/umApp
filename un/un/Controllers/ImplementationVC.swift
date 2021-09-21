//
//  ImplementationVC.swift
//  un
//
//  Created by Andres Liu on 1/18/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import SideMenu

class ImplementationVC: UIViewController {

    @IBOutlet weak var campaignTableView: UITableView!
    
    var arrayCampaigns = [Campaign]()
    
    var arrayMedia = [Int]()
    var arrayCampaign = [Int]()

    var mediaList = [FilterBody]()
    var campaignList = [FilterBody]()
    
    let transparentView = UIView()
    var imageView = ImageViewWithUrl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ImplementationManager.shared.implementationVC = self
        campaignTableView.dataSource = self
        campaignTableView.delegate = self
        
        getMedia()
    }
    
    func getMedia(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.mediaURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success Media")
                //print(jsonData)
                var count = 1
                for media in jsonData["mediaInversionList"].arrayValue {
                    let newMedia: FilterBody = FilterBody(id: media["id"].int!, name: media["name"].string!)
                    self.mediaList.append(newMedia)
                    if count == 1 {
                        self.arrayMedia.append(newMedia.id)
                    }
                    count += 1
                }
                self.getCampaign()
            } else {
                print("Failure")
            }
        })
    }
    
    public func getCampaign(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.implementacionCampaignsURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de campaña")
                    return
                }
                var count = 1
                for campaign in jsonData["campaignList"].arrayValue {
                    let isContained = self.campaignList.contains { $0.id == campaign["idCampaign"].int! }
                    
                    if !isContained {
                        let newCampaign: FilterBody = FilterBody(id: campaign["idCampaign"].int!, name: campaign["name"].string!)
                        self.campaignList.append(newCampaign)
                        if count == 1 {
                            self.arrayCampaign.append(newCampaign.id)
                        }
                        count += 1
                    }
                }
                self.getCampaigns()
            } else {
                print("Failure")
            }
        })
    }
    
    func getCampaigns() {
        
        guard arrayCampaign.count > 0 else {
            showAlert(title: "Error", message: "No hay datos con determinado filtro")
            return
        }
        
        guard arrayMedia.count > 0 else {
            showAlert(title: "Error", message: "No hay datos con determinado filtro")
            return
        }
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "idCampaign": arrayCampaign[0], "idMedium": arrayMedia[0]]
        
        serverManager.serverCallWithHeaders(url: serverManager.campaignURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                self.arrayCampaigns.removeAll()
                print(jsonData)
                for campaign in jsonData["categories"].arrayValue {
                    let campaignElement = Campaign(name: jsonData["title"].string!, categoryTitle: campaign["categoryTitle"].string!, imageUrl: campaign["imageUrl"].string!, date: campaign["date"].string ?? "", media: campaign["medium"].string!)
                    self.arrayCampaigns.append(campaignElement)
                }
                print(self.arrayCampaigns)
                print(self.arrayCampaigns.count)
                self.campaignTableView.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    @objc func showImageView() {
        let frames = self.view.frame
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        self.view.addSubview(imageView)
        
        self.imageView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        
        let imageUrl = imageView.url!
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL) {
                imageView.image = UIImage(data: data as Data)
            }
        }
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            self.imageView.frame = CGRect(x: (self.view.frame.maxX - self.imageView.image!.size.width)/2, y: (self.view.frame.maxY - self.imageView.image!.size.height)/2, width: self.imageView.image!.size.width, height: self.imageView.image!.size.height)
        }, completion: nil)
    }

    @objc func removeTransparentView() {
        let frames = self.view.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0
            self.imageView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        }, completion: nil)
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
       let size = image.size

       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height

       // Figure out what our orientation is, and use that to form the rectangle
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }

       // This is the rect that we've calculated out and this is what is actually used below
       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

       // Actually do the resizing to the rect using the ImageContext stuff
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       image.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()

       return newImage!
   }
    
    @IBAction func showFilters(_ sender: UIButton) {
        let implementationFilters = storyboard?.instantiateViewController(withIdentifier: "ImplementationFilters") as! SideMenuNavigationController
        implementationFilters.presentationStyle = .menuSlideIn
        implementationFilters.presentationStyle.presentingEndAlpha = 0.5
        implementationFilters.presentationStyle.onTopShadowOpacity = 1
        implementationFilters.menuWidth = self.view.frame.width * 0.75
        
        present(implementationFilters, animated: true) {
            ImplementationFilterManager.shared.implementationFiltersVC.arrayMedia = self.arrayMedia
            ImplementationFilterManager.shared.implementationFiltersVC.arrayCampaign = self.arrayCampaign
            
            ImplementationFilterManager.shared.implementationFiltersVC.mediaList = self.mediaList
            ImplementationFilterManager.shared.implementationFiltersVC.campaignList = self.campaignList
            ImplementationFilterManager.shared.implementationFiltersVC.changeButtonTitle(ImplementationFilterManager.shared.implementationFiltersVC.buttonMedia, self.arrayMedia, self.mediaList)
            ImplementationFilterManager.shared.implementationFiltersVC.changeButtonTitle(ImplementationFilterManager.shared.implementationFiltersVC.buttonCampaign, self.arrayCampaign, self.campaignList)
        }
        
    }
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension ImplementationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCampaigns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "CampaignCell")
        
        let eyeImg = UIImage(systemName: "eye")!.withTintColor(.black, renderingMode: .alwaysOriginal)
        cell.imageView!.image = eyeImg
        self.imageView.url = arrayCampaigns[indexPath.row].imageUrl
        cell.imageView!.isUserInteractionEnabled = true
        let onTap = UITapGestureRecognizer(target: self, action: #selector(showImageView))
        onTap.numberOfTouchesRequired = 1
        onTap.numberOfTapsRequired = 1
        cell.imageView!.addGestureRecognizer(onTap)
        
        cell.backgroundColor = UIColor.white
        cell.textLabel?.font = UIFont(name: "Georgia",
                                      size: 15.0)
        cell.detailTextLabel?.font = UIFont(name: "Georgia",
                                           size: 12.0)
        
        cell.textLabel?.text = "\(arrayCampaigns[indexPath.row].categoryTitle) \(arrayCampaigns[indexPath.row].name)"
        
        cell.detailTextLabel?.text = arrayCampaigns[indexPath.row].date
        
        var rightImg = UIImage(named: "enProceso")!
        if arrayCampaigns[indexPath.row].date == "" {
            rightImg = UIImage(named: "enProceso")!
        } else {
            rightImg = UIImage(named: "alAire")!
        }
        let dateImg = resizeImage(image: rightImg, targetSize: CGSize(width: 80.0, height: 40.0))
        cell.accessoryView = UIImageView(image: dateImg)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension ImplementationVC: UITableViewDelegate {}
