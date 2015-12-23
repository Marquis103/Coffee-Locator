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

    @IBOutlet var coffeeMap: MKMapView!
    
    var locationManager:CLLocationManager?
    let distanceSpan:Double = 500
    var lastLocation:CLLocation?
    var venues:Results<Venue>?
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onVenuesUpdated"), name: API.notifications.venuesUpdated, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshVenues(location: CLLocation?, getDataFromFourSquares:Bool = false) {
        if location != nil {
            lastLocation = location
        }
        
        if let location = lastLocation {
            if getDataFromFourSquares == true {
                CoffeeAPI.sharedInstance.getCoffeeShopsWithLocation(location)
            }
            
            let realm = try! Realm()
            venues = realm.objects(Venue)
            
            for venue in venues! {
                let annotation = CoffeeAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
                
                coffeeMap.addAnnotation(annotation)
            }
            
            tableView.reloadData()
        }
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
                locationManager.distanceFilter = 50
                locationManager.startUpdatingLocation()
            }
        }
    }
}

extension ViewController : MKMapViewDelegate {
    
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if let coffeeMap = self.coffeeMap {
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, self.distanceSpan, self.distanceSpan)
            coffeeMap.setRegion(region, animated: true)
            self.refreshVenues(newLocation, getDataFromFourSquares: true)
        }
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let venue = venues?[indexPath.row] {
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)), self.distanceSpan, self.distanceSpan)
            
            self.coffeeMap.setRegion(region, animated: true)
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