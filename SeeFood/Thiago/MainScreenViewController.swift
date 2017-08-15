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

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //MARK: Properties

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mapListButton: UIButton!
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var customNav: UIView!
    var arrayOfRestaurants: [RestaurantData] = []
    var arrayOfImages: [UIImage] = []
    var mapView: GMSMapView?
    var locationManager = CLLocationManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
        getRestaurants(coordinates: (locationManager.location?.coordinate)!)
    }
    
    
    


    
    
    
    @IBAction func switchMapListButton(_ sender: UIButton) {
        
        if self.mainTable.alpha == 0 {
            self.mainTable.alpha = 1
            self.mainTable.isHidden = false
            self.mapView?.removeFromSuperview()
            sender.setTitle("Map", for: .normal)
        }
        else{
            self.setupMap()
            self.mainTable.alpha = 0
            self.mainTable.isHidden = true
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
    
    
    
    
    
    //MARK: Google API Call
    func getRestaurants(coordinates: CLLocationCoordinate2D) {
        
        GoogleManager.shared.getRestaurantsNear(coordinates: coordinates, radius: 500) { (restaurants: [RestaurantData]) in
            self.arrayOfRestaurants = restaurants
            for rest in self.arrayOfRestaurants {
                GoogleManager.shared.getPhotosFor(reference: rest.photoRef[0]["photo_reference"]as! String, maxWidth: 200) { (restaurantImage:UIImage?) in
                    self.arrayOfImages.append(restaurantImage!)
                    if self.arrayOfImages.count == self.arrayOfRestaurants.count-1 {
                        DispatchQueue.main.async{
                            self.mainTable.reloadData()
                        }
                    }else {
                        print(self.arrayOfImages.count)
                        print("Retaurant Count: \(self.arrayOfRestaurants.count)")
                    }
                }
            }
        }
        
        
          //  arrayOfRestaurants.sort { $0.rating < $1.rating }
        }

    
    
    
    
    
    
    
    //MARK: Map Setup

    func setupMap(){
        
        let userLocation = PFGeoPoint(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.latitude, longitude: userLocation.longitude, zoom: 16.0)
        
  
        let f = self.view.frame
        
        let mapFrame = CGRect(x: 500, y: 125, width: f.size.width, height: f.size.height)
        
        mapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
    
        mapView?.delegate = self
        
        mapView?.isMyLocationEnabled = true
       
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
            marker.icon = GMSMarker.markerImage(with: UIColorFromRGB(rgbValue: 0xB21823))
            marker.position = CLLocationCoordinate2D(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude)
            marker.title = restaurant.name
            marker.snippet = "Lorem"
            marker.map = mapView
        }
    
        
    }
    
    
    //MARK: GoogleMaps Delegate
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("infoWindowTapped")
        print(marker.description)
        self.performSegue(withIdentifier: "SegueToDetailFromMap", sender: marker)
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
        
        cell.cellLogoImage.image = arrayOfImages[indexPath.row]
        cell.cellRestaurantTitle.text = restaurant.name
        cell.cellRatingsImage.image = UIImage(named: "thumbsupIcon.png")
        cell.cellPhotoCountLabel.text = String(restaurant.rating)
        cell.cellLogoImage.layer.masksToBounds = true
        cell.cellLogoImage.layer.cornerRadius = 2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        mainTable.deselectRow(at: indexPath, animated: true)
    }
    

    
    
    

    
    
    //MARK: ColorFunction
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    //MARK: Location MAnager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
       //Call google API to do Query
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch (status) {
        case .restricted:
            print("Location access was restricted.")
            break
        case .denied:
            print("User denied access.")
            break
        case .notDetermined:
            print("Location status not determined.")
            break
        case .authorizedAlways:
            print("Location Status is Always")
            break
        case .authorizedWhenInUse:
            print("Location Status is OK.")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
    }

    
    
    
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToDetail"{
            print(sender.debugDescription)
            let index = self.mainTable.indexPathForSelectedRow
            let vc = segue.destination as! DetailViewController
            vc.restaurant = arrayOfRestaurants[(index?.row)!]
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            present(segue.destination, animated: false, completion: nil)
        }
            
        else if segue.identifier == "SegueToDetailFromMap"{
            let vc = segue.destination as! DetailViewController
            let marker = sender as! GMSMarker
            for rest in arrayOfRestaurants{
                if rest.name == marker.title {
                    vc.restaurant = rest
                }
            }
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            present(segue.destination, animated: false, completion: nil)
        }
        
    }
    

    
}
