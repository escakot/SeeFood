//
//  ImgurManager.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-09-18.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit

class ImgurManager: NSObject {
  
  var imgurComponents = URLComponents(string: "https://api.imgur.com")
  let boundaryConstant = "----------lp0zaQ1mXskWo20CnDjeI39vnfjri48"
  let imgurClientID = "8152929a5336325"
  
  func postPhotoToImgur (title:String, imageData:Data, completionHandler: @escaping (String?) -> Void)
  {
    imgurComponents?.path = "/3/image"
    var params: [String: String] = [:];
    params["type"] = "file"
    params["name"] = title
    
    let contentType = String(format: "multipart/form-data; boundary=%@", boundaryConstant)
    
    var urlRequest = URLRequest(url: imgurComponents!.url!)
    urlRequest.allHTTPHeaderFields = ["authorization":String(format:"Client-ID %@", imgurClientID),
                                      "Content-Type":contentType]
    urlRequest.httpMethod = "POST"
    
    var body = Data()
    
    for (key, param) in params
    {
      body.append(String(format:"--%@\r\n", boundaryConstant).data(using: String.Encoding.utf8)!)
      body.append(String(format:"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key).data(using: String.Encoding.utf8)!)
      body.append(String(format:"%@\r\n", param).data(using: String.Encoding.utf8)!)
    }
    
    body.append(String(format:"--%@\r\n", boundaryConstant).data(using: String.Encoding.utf8)!)
    body.append(String(format:"Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n").data(using: String.Encoding.utf8)!)
    body.append(String(format:"Content-Type: image/jpeg\r\n\r\n").data(using: String.Encoding.utf8)!)
    body.append(imageData)
    body.append(String(format:"\r\n").data(using: String.Encoding.utf8)!)
    body.append(String(format:"--%@--\r\n", boundaryConstant).data(using: String.Encoding.utf8)!)
    
    urlRequest.httpBody = body
    
    performQuery(with: urlRequest) { (data: Data) in
      do {
        let responseData = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:AnyObject]
        print(responseData.description)
        let imageLink = responseData["data"]!["link"] as! String
//        let imagePath = imageLink.replacingOccurrences(of: "http", with: "https")
        completionHandler(imageLink)
      } catch {
        print(error.localizedDescription)
        completionHandler(nil)
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
      }
      
      returnJSONData(data!)
    }
    dataTask.resume()
  }
}
