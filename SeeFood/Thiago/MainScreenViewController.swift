
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

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate, GMSMapViewDelegate {
   
   //MARK: Properties
   
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet weak var mapListButton: UIButton!
   @IBOutlet weak var mainTable: UITableView!
   @IBOutlet weak var customNav: UIView!
   @IBOutlet weak var myWebView: UIWebView!
   var arrayOfRestaurants: [RestaurantData] = []
   var arrayOfImages: [UIImage] = []
   var mapView: GMSMapView?
   var locationManager = CLLocationManager()
   var searchAreaButton: UIButton!
   var isMapView = false
   let refreshControl = UIRefreshControl()
   
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      //MARK: Background Animation
      let htmlPath = Bundle.main.path(forResource: "WebViewContent", ofType: "html")
      let htmlURL = URL(fileURLWithPath: htmlPath!)
      let html = try? Data(contentsOf: htmlURL)
      self.myWebView.load(html!, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: htmlURL.deletingLastPathComponent())
      DispatchQueue.main.async {
         self.view.bringSubview(toFront: self.myWebView)
      }
      
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestWhenInUseAuthorization()
      locationManager.delegate = self
      locationManager.requestLocation()
    
      //SearchBar Delegate
      searchBar.delegate = self
      searchBar.backgroundImage = UIImage()
    
      //Refresh Control
      refreshControl.attributedTitle = NSAttributedString(string: "Pull to find nearby Restaurants")
      refreshControl.addTarget(self, action: #selector(refreshPull), for: UIControlEvents.valueChanged)
      mainTable.addSubview(refreshControl)
   }
   
  
   
   @IBAction func switchMapListButton(_ sender: UIButton)
   {
      isMapView = !isMapView
      if sender.title(for: .normal) == "Map" {
         if self.mapView == nil {
            self.setupMap()
            self.view.addSubview(self.mapView!)
         }
      }
      
      UIView.animate(withDuration: 1,
                     delay: 0,
                     usingSpringWithDamping: 0.9,
                     initialSpringVelocity: 3,
                     options: UIViewAnimationOptions.curveEaseIn,
                     animations: {
                        if sender.title(for: .normal) == "Map" {
                           self.mapView?.isHidden = false
                           self.mapView?.frame.origin.x = self.view.frame.origin.x
                           self.mainTable.frame.origin.x = -500
                        }
                        else{
                           self.mainTable.isHidden = false
                           self.mapView?.frame.origin.x = 500
                           self.mainTable.frame.origin.x = self.view.frame.origin.x
                           self.mainTable.reloadData()
                        }
                        self.view.layoutIfNeeded()
      }, completion: {(done: Bool) in
         if sender.title(for: .normal) == "Map" {
            sender.setTitle("List", for: .normal)
            self.mainTable.isHidden = true
         }
         else {
            sender.setTitle("Map", for: .normal)
            self.mapView?.isHidden = true
         }
      })
   }
   
   
   
   
   
   
   //MARK: Google API Call
   func getRestaurants(coordinates: CLLocationCoordinate2D) {
      let mapZoom = (self.mapView?.camera.zoom) ?? 15
      let searchRadius = 10000/mapZoom
      GoogleManager.shared.getRestaurantsNear(coordinates: coordinates, radius: Int(searchRadius)) { (restaurants: [RestaurantData]) in
         self.arrayOfRestaurants = restaurants
         self.updateTableOrMap()
      }
   }
   
   
   func updateTableOrMap()
   {
      var count = 0
      arrayOfRestaurants.sort { $0.rating > $1.rating }
      for rest in self.arrayOfRestaurants {
         count += 1
         
         guard let reference = rest.photoRef else{
            rest.icon = UIImage(named: "defaultrestlogo.png")
            continue
         }
         GoogleManager.shared.getPhotosFor(reference: reference[0]["photo_reference"] as! String, maxWidth: 200) { (restaurantImage:UIImage?) in
            rest.icon = restaurantImage
            if count == self.arrayOfRestaurants.count && !self.isMapView{
               DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                  self.mainTable.reloadData()
                  self.myWebView.isHidden = true
                  self.refreshControl.endRefreshing()
               })
            }
            else if self.isMapView {
               DispatchQueue.main.async {
                  self.mapView?.clear()
                  
                  for restaurant in self.arrayOfRestaurants {
                     let marker = GMSMarker()
                     marker.icon = GMSMarker.markerImage(with: self.UIColorFromRGB(rgbValue: 0xB21823))
                     marker.position = CLLocationCoordinate2D(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude)
                     marker.title = restaurant.name
//                     marker.snippet = "Lorem"
                     marker.map = self.mapView
                  }
               }
            }
         }
      }
   }
   
   
   
   
   
   
   //MARK: Map Setup
   
   func setupMap(){
      
      let userLocation = PFGeoPoint(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
      let camera = GMSCameraPosition.camera(withLatitude: userLocation.latitude, longitude: userLocation.longitude, zoom: 15.0)
      
      
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
//         marker.snippet = "Lorem"
         marker.map = mapView
      }
      
      
   }
   
   
   //MARK: GoogleMaps Delegate
   func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
      print("infoWindowTapped")
      print(marker.description)
      self.performSegue(withIdentifier: "SegueToDetailFromMap", sender: marker)
   }
   
   func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
      if self.searchAreaButton == nil {
         searchAreaButton = UIButton.init(frame: CGRect(x: (self.view.frame.width/2), y: (self.view.frame.origin.y) + 10, width: 170, height: 28))
         searchAreaButton.center.x = view.frame.width/2
         searchAreaButton.setTitle("SEARCH THIS AREA", for: .normal)
         searchAreaButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 9)
         searchAreaButton.titleLabel!.tintColor = .red
         searchAreaButton.backgroundColor = UIColor(red: 215/255, green: 29/255, blue: 41/255, alpha: 0.8)
         searchAreaButton.addTarget(self, action: #selector(searchThisArea), for: .touchUpInside)
         self.mapView?.addSubview(searchAreaButton)
         self.mapView?.bringSubview(toFront: searchAreaButton)
      }
      else if self.searchAreaButton.isHidden {
         self.searchAreaButton.isHidden = false
      }
      else {
         self.mapView?.addSubview(searchAreaButton)
         self.mapView?.bringSubview(toFront: searchAreaButton)
      }
   }
   
   func searchThisArea(){
      print("Search Pressed")
      self.searchAreaButton.isHidden = true
      self.arrayOfRestaurants.removeAll()
      self.mapView?.clear()
      getRestaurants(coordinates: (self.mapView?.camera.target)!)
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
      
      cell.cellLogoImage.image = restaurant.icon
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
   
   func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      searchBar.resignFirstResponder()
   }
   
   func refreshPull()
   {
      locationManager.requestLocation()
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
      let location = locations.last!.coordinate
      getRestaurants(coordinates: location)
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
   
   
   
   
   
   //MARK: - Segue
   
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
   
   @IBAction func unwindSegue(segue:UIStoryboardSegue) { }
   
   // MARK: - SearchBarDelegate/GoogleSearch
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
   {
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      perform(#selector(performRestaurantSearch), with: searchText, afterDelay: 0.3)
   }
   
   func performRestaurantSearch(sender:Any?)
   {
      let searchText = sender as! String
      if searchText == ""
      {
         self.getRestaurants(coordinates: (locationManager.location?.coordinate)!)
         print("Nearby Search")
      } else {
         GoogleManager.shared.searchRestaurantWith(searchText: searchText, coordinates: locationManager.location) { (restaurants) in
            self.arrayOfRestaurants = restaurants
            self.updateTableOrMap()
            print("Searching!")
         }
         
      }
   }
   
}
