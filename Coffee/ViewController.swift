//
//  ViewController.swift
//  Coffee
//
//  Created by Marquis Dennis on 12/22/15.
//  Copyright © 2015 Marquis Dennis. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class ViewController: UIViewController {
  //MARK: Properties
  @IBOutlet var tableView: UITableView!
  @IBOutlet var coffeeMap: MKMapView!
  var locationManager:CLLocationManager?
  var lastLocation:CLLocation?
  var venues:[Venue]?
  let distanceSpan:Double = 8046 //5 mile radius
  
  //MARK: View Controller Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onVenuesUpdated"), name: API.notifications.venuesUpdated, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let coffeeMap = self.coffeeMap {
      coffeeMap.delegate = self
    }
    
    if let tableView = self.tableView {
      tableView.delegate = self
      tableView.dataSource = self
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    if locationManager == nil {
      locationManager = CLLocationManager()
      
      if let locationManager = locationManager {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = distanceSpan
        locationManager.startUpdatingLocation()
      }
    }
  }
  
  //MARK: Functions
  
  func refreshVenues(location: CLLocation?, getDataFromFourSquares:Bool = false) {
      if location != nil {
          lastLocation = location
      }
      
      if let location = lastLocation {
          if getDataFromFourSquares == true {
            CoffeeAPI.sharedInstance.getCoffeeShopsWithLocation(location, withRadius: String(distanceSpan))
          }
          
          let (start, stop) = calculateCoordinatesWithRegion(location)
          let predicate = NSPredicate(format: "latitude < %f AND latitude > %f AND longitude > %f AND longitude < %f", start.latitude, stop.latitude, start.longitude, stop.longitude)
          
          let realm = try! Realm()
          venues = realm.objects(Venue).filter(predicate).sort {
              location.distanceFromLocation($0.coordinate) < location.distanceFromLocation($1.coordinate)
          }
          
          for venue in venues! {
              let annotation = CoffeeAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
              
              coffeeMap.addAnnotation(annotation)
          }
          
          tableView.reloadData()
      }
  }
    
  func calculateCoordinatesWithRegion(location:CLLocation) -> (CLLocationCoordinate2D, CLLocationCoordinate2D)
  {
      let region = MKCoordinateRegionMakeWithDistance(location.coordinate, distanceSpan, distanceSpan)
      
      var start:CLLocationCoordinate2D = CLLocationCoordinate2D()
      var stop:CLLocationCoordinate2D = CLLocationCoordinate2D()
      
      start.latitude  = region.center.latitude  + (region.span.latitudeDelta  / 2.0)
      start.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
      stop.latitude   = region.center.latitude  - (region.span.latitudeDelta  / 2.0)
      stop.longitude  = region.center.longitude + (region.span.longitudeDelta / 2.0)
      
      return (start, stop)
  }
    
  func onVenuesUpdated() {
      refreshVenues(nil)
  }
    
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
      if annotation.isKindOfClass(MKUserLocation) {
          return nil
      }
      
      var view = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationIdentifier")
      
      if view == nil {
          view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
      }
      
      view?.canShowCallout = true
      
      return view
  }
}

//MARK: MapKit Protocols
extension ViewController : MKMapViewDelegate {
    
}

extension ViewController : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let coffeeMap = self.coffeeMap {
        let region = MKCoordinateRegionMakeWithDistance(locations[0].coordinate, self.distanceSpan, self.distanceSpan)
        coffeeMap.setRegion(region, animated: true)
        self.refreshVenues(locations[0], getDataFromFourSquares: true)
    }
  }
}

//MARK: TableView Protocols
extension ViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let venue = venues?[indexPath.row] {
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)), self.distanceSpan, self.distanceSpan)
            
            coffeeMap.setRegion(region, animated: true)
        }
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        }
        
        if let venue = venues?[indexPath.row] {
            cell!.textLabel?.text = venue.name
            cell!.detailTextLabel?.text = venue.address
        }
        
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}