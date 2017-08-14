//
//  MainScreenViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps
import GooglePlaces
import ObservableArray_RxSwift
import RxSwift

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var mapListButton: UIButton!
    
    @IBOutlet weak var mainTable: UITableView!
    
    @IBOutlet weak var customNav: UIView!
    
    var arrayOfRestaurants: [Restaurant] = []
    
    var mapView: GMSMapView?
  
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxSwiftForPlaces()
        getRestaurantObjects()
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
        
        let userLocation = PFGeoPoint(latitude: 43.642566, longitude: -79.387057)
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.latitude, longitude: userLocation.longitude, zoom: 14.0)
        
  
    let f = self.view.frame
        
    let mapFrame = CGRect(x: 500, y: 125, width: f.size.width, height: f.size.height)
        
    self.mapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
    
        
       
    // Set the map style by passing the URL of the local file.
    do {
    if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
    mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
    } else {
    NSLog("Unable to find style.json")
    }
    } catch {
    NSLog("One or more of the map styles failed to load. \(error)")
    }
        
        for restaurant in arrayOfRestaurants {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: restaurant.coordinates.latitude, longitude: restaurant.coordinates.longitude)
            marker.title = restaurant.name
            marker.snippet = "Lorem"
            marker.map = mapView
        }
    
        
    }
    
    
    
    
    
    
    //MARK: Google API Call
    func getRestaurantObjects(){
//        let myGeoPoint1 = PFGeoPoint(latitude: 43.642566, longitude: -79.387057)
//        let restaurant1 = Restaurant.init(name: "CN Tower", coordinates: myGeoPoint1)
//        let myGeoPoint2 = PFGeoPoint(latitude: 43.641438, longitude: -79.389353)
//        let restaurant2 = Restaurant.init(name: "Rogers Center", coordinates: myGeoPoint2)
//        arrayOfRestaurants.append(restaurant1)
//        arrayOfRestaurants.append(restaurant2)
      
      let sharedManager = GoogleManager.shared
      sharedManager.locationManager.requestLocation()
      
      
      
      
    
    }
  
  
  
    func setupRxSwiftForPlaces()
    {
      GoogleManager.shared.places.rx_elements().subscribe(onNext: { (places:[GMSPlace]) in
        
        
        //Thiago make your changes to the map here!
        //GoogleManager.shared.searchRadius = 50? //Change the value based on map
        //Call GoogleManager.shared.locationManager.requestLocation to update the map
        print(places)
        
      }).addDisposableTo(disposeBag)
    }
  
  
    
    
    
    
    
    
    
    
    
    //MARK: TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        
          let restaurant = arrayOfRestaurants[indexPath.row]
        
          cell.cellLogoImage.image = UIImage(named: "defaultrestlogo.png")
          cell.cellRestaurantTitle.text = restaurant.name
          cell.cellRatingsImage.image = UIImage(named: "Star.png")
          cell.cellPhotoCountLabel.text = "0 Photos"
        
        return cell
    }

    
    
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToDetail"{
            let index = self.mainTable.indexPathForSelectedRow
            let vc = segue.destination as! DetailViewController
            vc.restaurant = arrayOfRestaurants[(index?.row)!]
        }
    }
    
    
    
}
