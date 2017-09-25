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

class RestaurantData: NSObject {
  var placeID: String!
  var name: String!
  //  var isOpen: Bool?
  var rating: Float = 0.0
  var address: String!
  var location: CLLocationCoordinate2D
  var photoRef: [[String:AnyObject]]?
  var icon: UIImage?
  
  init(withJSONdata data:[String:AnyObject]) {
    placeID = data["place_id"] as! String
    name = data["name"] as! String
    //    isOpen = (data["opening_hours"] as! [String:AnyObject])["open_now"] as! Bool
    if data["rating"] != nil
    {
      rating = data["rating"] as! Float
    }
    if data["vicinity"] != nil
    {
      address = data["vicinity"] as! String
    } else if data["formatted_address"] != nil {
      address = data["formatted_address"] as! String
    }
    photoRef = data["photos"] as? [[String:AnyObject]]
    location = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: ((data["geometry"] as! [String:AnyObject])["location"] as! [String:AnyObject])["lat"] as! Float)!,
                                      longitude: CLLocationDegrees(exactly: ((data["geometry"] as! [String:AnyObject])["location"] as! [String:AnyObject])["lng"] as! Float)!)
    do {
      let iconData = try Data(contentsOf: URL(string: data["icon"] as! String)!)
      icon = UIImage(data: iconData)
    } catch {
      print(error.localizedDescription)
    }
    
  }
  
}

class GoogleManager: NSObject {
  
  private override init() { }
  
  static let shared = GoogleManager()
  
  var components = URLComponents(string: "https://maps.googleapis.com")!
  let googlePlacesAPI = (UIApplication.shared.delegate as! AppDelegate).googlePlacesAPIkey
  var camera: GMSCameraPosition!
  var locationManager: CLLocationManager!
  var currentLocation: CLLocation?
  var previousLocation: CLLocation?
  var zoomLevel: Float = 15.0
  var searchRadius: Int = 50
  
  var placesClient = GMSPlacesClient.shared()
  var placesID: Array<String> = []
  
  var isFirstSearch = true
  
  
  
  // MARK: - Get Photo Methods
  func getPhotosFor(reference:String, maxWidth:Int, completionHandler: @escaping (UIImage?) -> Void)
  {
    components.path = "/maps/api/place/photo"
    let sizeQuery = URLQueryItem(name: "maxwidth", value: String(format:"%li", maxWidth))
    let referenceQuery = URLQueryItem(name: "photoreference", value: reference)
    let keyQuery = URLQueryItem(name: "key", value: googlePlacesAPI)
    components.queryItems = [sizeQuery, referenceQuery, keyQuery]
    
    let urlRequest = URLRequest(url: components.url!)
    
    performQuery(with: urlRequest) { (data:Data) in
      guard let image = UIImage(data: data) else {
        completionHandler(nil)
        return
      }
      completionHandler(image)
    }
  }
  
  // MARK: - Query Search Methods
  func getRestaurantsNear(coordinates: CLLocationCoordinate2D, radius:Int, completionHandler: @escaping ([RestaurantData]) -> Void)
  {
    var restaurants: [RestaurantData]  = []
    components.path = "/maps/api/place/nearbysearch/json"
    let typeQuery = URLQueryItem(name: "type", value: "restaurant")
    let locationQuery = URLQueryItem(name: "location", value: String(format: "%.7f,%.7f", coordinates.latitude, coordinates.longitude))
    let radiusQuery = URLQueryItem(name: "radius", value: String(format:"%li", radius))
    let keyQuery = URLQueryItem(name: "key", value: googlePlacesAPI)
    components.queryItems = [typeQuery, locationQuery, radiusQuery, keyQuery]
    
    let urlRequest = URLRequest(url: components.url!)
    
    performQuery(with: urlRequest) { (data:Data) in
      do {
        let jsonData = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:AnyObject]
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
    }
  }
  
  func searchRestaurantWith(searchText:String, coordinates:CLLocation?, completionHandler: @escaping ([RestaurantData]) -> Void)
  {
    var restaurants: [RestaurantData]  = []
    components.path = "/maps/api/place/textsearch/json"
    let inputQuery = URLQueryItem(name: "query", value: searchText)
    let typeQuery = URLQueryItem(name: "type", value: "restaurant")
    let keyQuery = URLQueryItem(name: "key", value: googlePlacesAPI)
    if let coordinates = coordinates
    {
      let locationQuery = URLQueryItem(name: "location", value: String(format: "%.7f,%.7f", coordinates.coordinate.latitude, coordinates.coordinate.longitude))
      components.queryItems = [inputQuery, typeQuery, locationQuery, keyQuery]
    } else {
      components.queryItems = [inputQuery, typeQuery, keyQuery]
    }
    
    let urlRequest = URLRequest(url: components.url!)
    
    performQuery(with: urlRequest) { (data:Data) in
      do {
        let jsonData = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:AnyObject]
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
    }
  }
  
  func performQuery(with urlRequest:URLRequest, returnJSONData: @escaping (Data) -> ())
  {
    let configuration = URLSessionConfiguration.default
    let session = URLSession(configuration: configuration)
    let dataTask = session.dataTask(with: urlRequest)
    { (data: Data?, response: URLResponse?, error: Error?) in
      if (error != nil)
      {
        print(error!.localizedDescription)
      } else {
        returnJSONData(data!)
      }
    }
    dataTask.resume()
  }
}
