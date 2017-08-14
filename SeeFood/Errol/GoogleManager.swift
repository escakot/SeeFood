//
//  GoogleManager.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-11.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RxSwift
import ObservableArray_RxSwift

class RestaurantData: NSObject {
  var placeID: String!
  var name: String!
  var openingHours: Int
  var rating: Float
  var address: String!
  var photoRef: String!
  var icon: UIImage?
  
  init(withJSONdata data:[String:AnyObject]) {
    placeID = data["place_id"] as! String
    name = data["name"] as! String
    openingHours = (data["opening_hours"] as! [String:AnyObject])["open_now"] as! Int
    rating = data["rating"] as! Float
    address = data["vicinity"] as! String
    photoRef = data["photo_reference"] as! String
    do {
      let iconData = try Data(contentsOf: URL(string: data["icon"] as! String)!)
      icon = UIImage(data: iconData)
    } catch {
      print(error.localizedDescription)
    }
    
  }
  
}

class GoogleManager: NSObject {
  
  private override init()
  {
    super.init()
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.distanceFilter = 50
    locationManager.delegate = self
  }
  
  static let shared = GoogleManager()
  
  let googlePlacesAPI = "AIzaSyCoWsUggZmQ3s9qHVrhhhSfierog67FDdU"
  var camera: GMSCameraPosition!
  var locationManager: CLLocationManager!
  var currentLocation: CLLocation?
  var previousLocation: CLLocation?
  var zoomLevel: Float = 15.0
  var searchRadius: Int = 50
  
  var placesClient = GMSPlacesClient.shared()
  var placesID: Array<String> = []
  
  var isFirstSearch = true
  
  
  func getNearbyRestaurantsAt(coordinates: CLLocationCoordinate2D, completionHandler: @escaping () -> Void)
  {
    
  }
  
  
  
  
  // MARK: - Query Search Methods
  func performNearbySearch(coordinates: CLLocationCoordinate2D, radius:Int, completionHandler: @escaping ([RestaurantData]) -> Void)
  {
    var restaurants: [RestaurantData]  = []
    var components = URLComponents(string: "https://maps.googleapis.com")!
    components.path = "/maps/api/place/nearbysearch/json"
    let typeQuery = URLQueryItem(name: "type", value: "restaurant")
    let locationQuery = URLQueryItem(name: "location", value: String(format: "%.7f,%.7f", coordinates.latitude, coordinates.longitude))
    let radiusQuery = URLQueryItem(name: "radius", value: String(format:"%li", radius))
    let keyQuery = URLQueryItem(name: "key", value: googlePlacesAPI)
    components.queryItems = [typeQuery, locationQuery, radiusQuery, keyQuery]
    
    let urlRequest = URLRequest(url: components.url!)
    
    let configurations = URLSessionConfiguration.default
    let session = URLSession(configuration: configurations)
    let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?,error: Error?) in
      if error == nil
      {
        do {
          let jsonData = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String:AnyObject]
          let placesArray = jsonData["results"] as! [[String:AnyObject]]
          
          for placesDict in placesArray
          {
            guard placesDict["place_id"] != nil else {
              print("Place ID Is Nil")
              return
            }
            let restaurantInfo = RestaurantData(withJSONdata: placesDict)
            restaurants.append(restaurantInfo)
          }
          completionHandler(restaurants)
        } catch {
          print(error.localizedDescription)
          completionHandler(restaurants)
        }
        
        
      } else {
        print(error!.localizedDescription)
      }
    })
    dataTask.resume()
  }
  
  
  
}
