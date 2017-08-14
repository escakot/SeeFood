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

class GoogleManager: NSObject, CLLocationManagerDelegate {
  
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
  var zoomLevel: Float = 15.0
  var searchRadius: Int = 20
  
  var placesClient = GMSPlacesClient.shared()
  var places: [GMSPlace] = []
  
  
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
  {
    currentLocation = locations.last!
    print("Location: \(currentLocation!)")
    
    getPlacesNear(location: currentLocation!.coordinate, radius: searchRadius) { (places) in
      self.places = places
    }
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
  
  
  // MARK: - Google Places Methods
  func getPlacesNear(location:CLLocationCoordinate2D, radius:Int, completionHandler: @escaping (Array<GMSPlace>) -> Void)
  {
    performNearbySearch(coordinates: location, radius: radius) { (placesID) in
      var nearbyPlaces: [GMSPlace] = []
      for placeID in placesID
      {
        self.placesClient.lookUpPlaceID(placeID, callback: { (place:GMSPlace?, error:Error?) in
          if (error == nil)
          {
            nearbyPlaces.append(place!)
          } else {
            print(error!.localizedDescription)
          }
        })
      }
      completionHandler(nearbyPlaces)
    }
  }
  
  
  
  // MARK: - Query Search Methods
  func performNearbySearch(coordinates: CLLocationCoordinate2D, radius:Int, completionHandler: @escaping (Array<String>) -> Void)
  {
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
        var placesID: [String] = []
        do {
          let jsonData = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String:AnyObject]
          let placesArray = jsonData["results"] as! [[String:AnyObject]]
          
          for placesDict in placesArray
          {
            placesID.append(placesDict["place_id"] as! String)
          }
        } catch {
          print(error.localizedDescription)
        }
        
        completionHandler(placesID)
        
      } else {
        print(error!.localizedDescription)
      }
    })
    dataTask.resume()
  }
  
  
  
}
