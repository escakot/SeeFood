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
    locationManager.startUpdatingLocation()
    locationManager.delegate = self
  }
  
  static let shared = GoogleManager()
  
  var camera: GMSCameraPosition!
  var locationManager: CLLocationManager!
  var currentLocation: CLLocation?
  var placesClient = GMSPlacesClient.shared()
  var zoomLevel: Float = 15.0
  
  var nearbyPlaces: [GMSPlace] = []
  var selectedPlace: GMSPlace?
  
  
  func getNearbyPlaces()
  {
    nearbyPlaces.removeAll()
    
    placesClient.currentPlace { (placeLikelihood: GMSPlaceLikelihoodList?,error: Error?) in
      if let error = error
      {
        print(error.localizedDescription)
        return
      }
      
      if let likelihoodList = placeLikelihood
      {
        for likelihood in likelihoodList.likelihoods
        {
          let place = likelihood.place
          self.nearbyPlaces.append(place)
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
  {
    let location = locations.last!
    print("Location: \(location)")
    
    camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
    
    getNearbyPlaces()
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
    case .authorizedWhenInUse:
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
  
}
