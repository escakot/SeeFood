//
//  DetailViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import Parse

class MainCollectionView: UICollectionView {
  
  var isCameraLibraryViewOn = false
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let indexPath = self.indexPathForItem(at: point)
    if indexPath != nil && !isCameraLibraryViewOn
    {
      return true
    }
    
    return false
  }
}

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerPreviewingDelegate, UITableViewDelegate, UITableViewDataSource {
  
  //MARK: Properties
  @IBOutlet weak var mainCollectionView: MainCollectionView!
  @IBOutlet weak var restaurantNameLabel: UILabel!
  @IBOutlet weak var defaultPhoto: UIImageView!
  @IBOutlet weak var defaultLabel: UILabel!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var mainTableView: UITableView!
  @IBOutlet weak var switchListToPhoto: UIButton!
  var cameraLibraryView: UIView!
  var imagePicker: UIImagePickerController!
  var imageWasSelected: Bool!
  var restaurant: RestaurantData!
  var parseRestaurant: Restaurant!
  var arrayOfMenuItems: [MenuItem] = []
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let listImage = UIImage(named: "list.png")
    switchListToPhoto.setImage(listImage, for: .normal)
    self.view.addSubview(self.backButton)
    registerForPreviewing(with: self, sourceView: mainCollectionView)
    restaurantNameLabel.text = restaurant.name
    
    //MARK: Query Restaurant
    ParseManager.shared.queryRestaurantWith(id: restaurant.placeID) { (savedRestaurant:Restaurant?) in
      if savedRestaurant == nil {
        print("No Retaurants with id: \(self.restaurant.placeID)")
        ParseManager.shared.createRestaurantProfileWith(id: self.restaurant.placeID, name: self.restaurant.name, completionHandler: { (created:Bool, createdRestaurant:Restaurant?) in
          print("Restaurant Created Status: \(created)")
          self.defaultPhoto.isHidden = false
          self.defaultLabel.isHidden = false
          self.parseRestaurant = created ? createdRestaurant! : nil
        })
      }
      else{
        self.parseRestaurant = savedRestaurant
        print("Restaurant found: \(self.parseRestaurant.name)")
        
        //MARK: Query Items
        ParseManager.shared.queryMenuItemsFor(self.parseRestaurant) { (array: Array<MenuItem>?) in
          if (array?.isEmpty)!{
            self.defaultPhoto.isHidden = false
            self.defaultLabel.isHidden = false
            print("There are no Menu Items for \(self.parseRestaurant.name)")
          }else{
            self.arrayOfMenuItems = array!
            DispatchQueue.main.async {
              self.mainCollectionView.reloadData()
            }
          }
        }
      }
    }
    
    // Image Picker
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    
    // Creating cameraLibraryView
    cameraLibraryView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: view.frame.width * 0.75 / 2))
    cameraLibraryView.center = view.center
    cameraLibraryView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    
    let cameraImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cameraLibraryView.frame.width * 0.75 / 2, height: cameraLibraryView.frame.height * 0.75))
    cameraImageView.center = CGPoint(x: cameraLibraryView.frame.width/2 - cameraLibraryView.frame.width * 0.25/6 - cameraImageView.frame.width/2, y: cameraLibraryView.frame.height/2)
    cameraLibraryView.layer.cornerRadius = 15
    cameraImageView.image = UIImage(named: "camera-icon.png")
    let cameraTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
    cameraImageView.isUserInteractionEnabled = true
    cameraImageView.addGestureRecognizer(cameraTap)
    
    let libraryImageView = UIImageView(frame: cameraImageView.frame)
    libraryImageView.center = CGPoint(x: cameraLibraryView.frame.width/2 + cameraLibraryView.frame.width * 0.25/6 + libraryImageView.frame.width/2, y: cameraLibraryView.frame.height/2)
    libraryImageView.image = UIImage(named: "photo-library-icon.png")
    let libraryTap = UITapGestureRecognizer(target: self, action: #selector(libraryTapped))
    libraryImageView.isUserInteractionEnabled = true
    libraryImageView.addGestureRecognizer(libraryTap)
    
    cameraLibraryView.addSubview(cameraImageView)
    cameraLibraryView.addSubview(libraryImageView)
    
    imageWasSelected = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    if imageWasSelected {
      ParseManager.shared.queryMenuItemsFor(self.parseRestaurant) { (array: Array<MenuItem>?) in
        if (array?.isEmpty)!{
          self.defaultPhoto.isHidden = false
          self.defaultLabel.isHidden = false
          print("There are no Menu Items for \(self.parseRestaurant.name)")
        }else{
          self.arrayOfMenuItems = array!
          DispatchQueue.main.async {
            self.mainCollectionView.reloadData()
          }
        }
      }
    }
  }
  
  
  
  
  
  
  //MARK: CollectionView Method
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.arrayOfMenuItems.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell: CustomCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
    
    ParseManager.shared.queryReviewFor(self.arrayOfMenuItems[indexPath.row]) { (reviews: Array<Review>?) in
      reviews?[0].image.getDataInBackground(block: { (data: Data?, error:Error?) in
        if error == nil {
          DispatchQueue.main.async {
            cell.cellImage.image = UIImage(data: data!)
          }
        }
        else {
          print(error?.localizedDescription ?? "Error converting UIImage to PFFile")
        }
      })
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    performSegue(withIdentifier:"SegueToCellDetail" , sender: indexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (UIScreen.main.bounds.width-8)/4, height: UIScreen.main.bounds.height*1.5/10)
  }
  
  
  
  
  //MARK: IBActions
  
  @IBAction func addButton(_ sender: UIButton)
  {
    guard PFUser.current() != nil else {
      let alert = UIAlertController(title: "Login Required", message: "Please login to post a photo.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dimiss", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
      return
    }
    guard !view.subviews.contains(cameraLibraryView) else { return }
    mainCollectionView.isCameraLibraryViewOn = true
    view.addSubview(cameraLibraryView)
    cameraLibraryView.alpha = 0
    UIView.animate(withDuration: 0.6) {
      self.cameraLibraryView.alpha = 1.0
    }
  }
  
  @IBAction func swipeToDismissView(_ sender: UISwipeGestureRecognizer) {
    if sender.direction == .right {
      dismissViewLeftToRight()
    }
  }
  
  @IBAction func backButton(_ sender: UIButton)
  {
    dismissViewLeftToRight()
  }
  
  
  //MARK: Segue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "SegueToCellDetail"{
      let vc = segue.destination as! CellDetailViewController
      vc.arrayOfMenuItems = self.arrayOfMenuItems
      vc.selectedCellIndex = sender as! IndexPath
    }
  }
  
  
  func dismissViewLeftToRight(){
    let transition = CATransition()
    transition.duration = 0.3
    transition.type = kCATransitionPush
    transition.subtype = kCATransitionFromLeft
    self.view.window!.layer.add(transition, forKey: kCATransition)
    self.dismiss(animated: false, completion: nil)
  }
  
  // MARK: UIPickerController Delegate / Segue To Add View
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
    {
      imageWasSelected = true
      let navController = UIStoryboard(name: "Errol", bundle: nil).instantiateInitialViewController() as! UINavigationController
      let addReviewController = navController.viewControllers.first as! AddReviewViewController
      addReviewController.foodImage = pickedImage
      addReviewController.restaurant = parseRestaurant
      addReviewController.listOfMenuItems = arrayOfMenuItems
      cameraLibraryView.removeFromSuperview()
      dismiss(animated: true, completion: nil)
      present(navController, animated: true, completion: nil)
    }
  }
  
  
  // MARK: Touch Actions Methods
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else
    {
      return
    }
    if !cameraLibraryView.frame.contains(touch.location(in: view))
    {
      UIView.animate(withDuration: 0.6, animations: {
        self.cameraLibraryView.alpha = 0
      }, completion: { (success) in
        self.cameraLibraryView.removeFromSuperview()
        self.mainCollectionView.isCameraLibraryViewOn = false
      })
    }
  }
  
  // MARK: UIGesture Methods
  func cameraTapped(_ sender: UITapGestureRecognizer)
  {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
      let alert = UIAlertController(title: "Camera Error", message: "Camera is invalid or unavailable.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dimiss", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
      return
    }
    imagePicker.sourceType = UIImagePickerControllerSourceType.camera
    let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
    switch authStatus {
    case .notDetermined:
      AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
        if granted
        {
          self.present(self.imagePicker, animated: true, completion: nil)
        }
      })
      break
    case .authorized:
      present(imagePicker, animated: true, completion: nil)
      
      break
    case .denied:
      let alert = UIAlertController(title: "Please Allow Camera Access", message: "We need your permission to access your camera. You can change permissions in your settings.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (alert) in
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:nil))
      present(alert, animated: true, completion: nil)
    default:
      break
    }
    
  }
  func libraryTapped(_ sender: UITapGestureRecognizer)
  {
    imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    let authStatus = PHPhotoLibrary.authorizationStatus()
    switch authStatus {
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization({ (granted) in
        if granted == PHAuthorizationStatus.authorized
        {
          self.present(self.imagePicker, animated: true, completion: nil)
        }
      })
    case .authorized:
      present(imagePicker, animated: true, completion: nil)
      
    case .denied:
      let alert = UIAlertController(title: "Please Allow Photos Access", message: "We need your permission to access your photos. You can change permissions in your settings.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (alert) in
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:nil))
      present(alert, animated: true, completion: nil)
    default:
      break
    }
    
  }
  
  
  
  // MARK: Force Touch
  
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    
    guard let indexPath = mainCollectionView.indexPathForItem(at: location),
      let cell = mainCollectionView.cellForItem(at: indexPath) else {
        return nil }
    
    guard let detailViewController =
      storyboard?.instantiateViewController(
        withIdentifier: "CellDetailViewController") as?
      CellDetailViewController else { return nil }
    
    detailViewController.arrayOfMenuItems = self.arrayOfMenuItems
    detailViewController.selectedCellIndex = indexPath
    detailViewController.preferredContentSize =
      CGSize(width: 0.0, height: 600)
    
    previewingContext.sourceRect = cell.frame
    
    return detailViewController
    
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    showDetailViewController(viewControllerToCommit, sender: self)
  }
  
  
  
  
  
  
  //MARK: List to Collection Start
  @IBAction func listButton(_ sender: UIButton) {
    let listImage = UIImage(named: "list.png")
    let photoImage = UIImage(named:"photo.png")
    
    if (sender.currentImage?.isEqual(listImage))! {
      self.mainTableView.reloadData()
      //         self.mainTableView.addSubview(self.backButton)
      sender.setImage(photoImage, for: .normal)
    }
    else {
      //         self.mainCollectionView.addSubview(self.backButton)
      sender.setImage(listImage, for: .normal)
    }
    
    UIView.animate(withDuration: 0.5) {
      if (sender.currentImage?.isEqual(photoImage))! {
        self.mainTableView.alpha = 1
      }
      else{
        self.mainTableView.alpha = 0
      }
    }
    
  }
  
  
  
  
  
  //MARK: TableView Methods
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.arrayOfMenuItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: DetailTableCell = self.mainTableView.dequeueReusableCell(withIdentifier: "TableCell") as! DetailTableCell
    let item = self.arrayOfMenuItems[indexPath.row]
    
    ParseManager.shared.queryReviewFor(item) { (reviews: Array<Review>?) in
      reviews?[0].image.getDataInBackground(block: { (data: Data?, error:Error?) in
        if error == nil {
          for view in cell.cellImage.subviews { view.removeFromSuperview() }
          DispatchQueue.main.async {
            cell.cellImage.image = UIImage(data: data!)
          }
        }
        else {
          print(error?.localizedDescription ?? "Error converting UIImage to PFFile")
        }
      })
    }
    cell.cellLabel.text = item.title
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier:"SegueToCellDetail" , sender: indexPath)
  }
  
  
  
}


class DetailTableCell: UITableViewCell {
  @IBOutlet weak var cellImage: UIImageView!
  @IBOutlet weak var cellLabel: UILabel!
}
