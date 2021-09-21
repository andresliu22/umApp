//
//  MotiveListVC.swift
//  un
//
//  Created by Andres Liu on 1/24/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import SideMenu

class MotiveListVC: UIViewController {

    @IBOutlet weak var motivosTableView: UITableView!
    let transparentView = UIView()
    var defaultOrder = "Inversion"
    var indexOrder = 0
    let dataLabelOrder = ["totalInversion","totalCurrentScope","totalCurrentImpressions","totalClicks","totalCTR","totalCPC","videoViews10","totalVTR","postReactions","postComments","postShares"]
    
    var imageView = ImageViewWithUrl()
    var motivoSeleccionado = ""
    var arrayMotivos = [MotiveEle]()

    var campaignName = ""
    var startDate = ""
    var endDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MotiveManager.shared.motiveListVC = self
        motivosTableView.dataSource = self
        motivosTableView.delegate = self
        
        getMotivos()
    }
    
    func getMotivos() {
    
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "campaign": campaignName, "starDate": startDate, "endDate": endDate, "idCurrency": UserDefaults.standard.integer(forKey: "moneda")]
        
        arrayMotivos.removeAll()
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                for categoria in jsonData["categories"].arrayValue {
                    let data = categoria["reportData"]
                    let motivo = MotiveEle(id: categoria["idCategoryTitle"].int ?? 0, name: categoria["categoryTitle"].string ?? "", imageUrl: categoria["verArteUrl"].string ?? "", activeValue: data[self.dataLabelOrder[self.indexOrder]].float ?? 0.0)
                    self.arrayMotivos.append(motivo)
                }
                self.arrayMotivos.sort { $0.activeValue > $1.activeValue }
                self.motivosTableView.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }

    @objc func showImageView() {
        let frames = self.view.frame
        transparentView.frame = frames
        self.view.addSubview(transparentView)
        self.view.addSubview(imageView)
        
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
        self.imageView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        
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
    
    @IBAction func showFilters(_ sender: UIButton) {
        let motiveListFilter = storyboard?.instantiateViewController(withIdentifier: "MotiveListFilter") as! SideMenuNavigationController
        motiveListFilter.presentationStyle = .menuSlideIn
        motiveListFilter.presentationStyle.presentingEndAlpha = 0.5
        motiveListFilter.presentationStyle.onTopShadowOpacity = 1
        motiveListFilter.menuWidth = self.view.frame.width * 0.75
        
        present(motiveListFilter, animated: true) {
            MotiveFilterManager.shared.motiveListFiltersVC.defaultOrder = self.defaultOrder
            MotiveFilterManager.shared.motiveListFiltersVC.indexOrder = self.indexOrder
            MotiveFilterManager.shared.motiveListFiltersVC.buttonOrder.setTitle(self.defaultOrder, for: .normal)
        }
    }
    
    @IBAction func returnToPerformance(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension MotiveListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMotivos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MotivosCell")
        
        let eyeImg = UIImage(systemName: "eye")!.withTintColor(.black, renderingMode: .alwaysOriginal)
        cell.imageView!.image = eyeImg
        
        self.imageView.url = arrayMotivos[indexPath.row].imageUrl
        cell.imageView!.isUserInteractionEnabled = true
        let onTap = UITapGestureRecognizer(target: self, action: #selector(showImageView))
        onTap.numberOfTouchesRequired = 1
        onTap.numberOfTapsRequired = 1
        cell.imageView!.addGestureRecognizer(onTap)
        
        cell.textLabel?.font = UIFont(name: "Georgia",
                                      size: 15.0)
        
        cell.textLabel?.text = (arrayMotivos[indexPath.row].name)
        
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right")!.withTintColor(.black, renderingMode: .alwaysOriginal))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.motivoSeleccionado = arrayMotivos[indexPath.row].name
        let motiveVC = storyboard?.instantiateViewController(identifier: "MotiveVC") as! MotiveVC
        
        motiveVC.motiveId = arrayMotivos[indexPath.row].id
        motiveVC.vcTitle = self.motivoSeleccionado
        motiveVC.campaignName = campaignName
        motiveVC.startDate = startDate
        motiveVC.endDate = endDate
        
        self.navigationController?.pushViewController(motiveVC, animated: true)
    }
    
}

extension MotiveListVC: UITableViewDelegate {
    
}
