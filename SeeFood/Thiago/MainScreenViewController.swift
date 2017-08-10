//
//  MainScreenViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import GoogleMaps

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var mapListButton: UIButton!
    
    @IBOutlet weak var mainTable: UITableView!
    
    @IBOutlet weak var customNav: UIView!
    
    
    
    var mapView: GMSMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMap()
    }


    
    
    
    @IBAction func switchMapListButton(_ sender: UIButton) {
        
        if self.mainTable.alpha == 0 {
            self.mainTable.alpha = 1
            self.mapView?.removeFromSuperview()
            sender.setTitle("Map", for: .normal)
        }
        else{
            self.mainTable.alpha = 0
            self.view.addSubview(self.mapView!)
            sender.setTitle("List", for: .normal)
        }
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 3,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        if self.mainTable.alpha == 0 {
                            self.mapView?.frame.origin.x = self.view.frame.origin.x
                            self.mainTable.frame.origin.x = -500
                        }
                        else{
                            self.mapView?.frame.origin.x = 500
                            self.mainTable.frame.origin.x = self.view.frame.origin.x
                        }
                        self.view.layoutIfNeeded()
        }, completion: nil)

        
    }
    
    
    
    
    //MARK: Map Setup
    
    func setupMap(){
    
    let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
    let f = self.view.frame
        
    let mapFrame = CGRect(x: 500, y: 102, width: f.size.width, height: f.size.height)
        
    self.mapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
    
    // Creates a marker in the center of the map.
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
    marker.title = "Sydney"
    marker.snippet = "Australia"
    
    do {
    // Set the map style by passing the URL of the local file.
    if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
    mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
    } else {
    NSLog("Unable to find style.json")
    }
    } catch {
    NSLog("One or more of the map styles failed to load. \(error)")
    }
    
        marker.map = mapView
        
        
    }
    
    
    
    
    
    
    
    //MARK: TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        cell.cellLogoImage.image = UIImage(named: "defaultrestlogo.png")
        cell.cellRestaurantTitle.text = "La Banane"
        cell.cellRatingsImage.image = UIImage(named: "")
        cell.cellPhotoCountLabel.text = "0 Photos"
        
        return cell
    }

    
    
    
    
    
}
