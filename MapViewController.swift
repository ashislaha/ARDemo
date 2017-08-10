//
//  MapViewController.swift
//  ARDemo
//
//  Created by Ashis Laha on 13/07/17.
//  Copyright © 2017 Ashis Laha. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class MapViewController: UIViewController , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var appleMap: MKMapView!
    
    let defaultZoomLabel : Float = 19.0
    let polylineStokeWidth : CGFloat = 10.0
    
    private var mapView : GMSMapView!
    private var userLocationMarker : GMSMarker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerLocationManager()
        //handleAppleMap()
        handleGoogleMap()
    }
    
    private func registerLocationManager() {
        guard let appDelegate = UIApplication.shared.delegate  as? AppDelegate else { return }
        appDelegate.locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            appDelegate.locationManager.startUpdatingLocation()
            appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        } else {
            appDelegate.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //MARK:- Apple Map Set up
    
    private func handleAppleMap() {
        self.appleMap.delegate = self
        self.appleMap.showsUserLocation = true
        
        let myLocation = CLLocationCoordinate2D(latitude: GPXFile.cherryHillPath.first?.0 ?? 0, longitude: GPXFile.cherryHillPath.first?.1 ?? 0)
        let cabLocation = CLLocationCoordinate2D(latitude: GPXFile.cherryHillPath.last?.0 ?? 0, longitude: GPXFile.cherryHillPath.last?.1 ?? 0)
        
        createRegion(coordinate: myLocation)
        // add annotations
        createAnnotation(location: cabLocation, title: "Cab location")
    }
    
    private func createAnnotation(location : CLLocationCoordinate2D, title : String ) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = title
        self.appleMap.addAnnotation(annotation)
    }
    
    private func createRegion(coordinate : CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.appleMap.setRegion(region, animated: true)
    }
    
    // MARK:- Open AR View
    
    @IBAction func openARView(_ sender: UIBarButtonItem) {
        if let arVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARViewController") as? UINavigationController {
            if let vc = arVC.visibleViewController as? ARViewController {
                vc.sectionCoordinates = GPXFile.cherryHillsSectionCoordinates
                vc.carLocation = GPXFile.cherryHillsCarLocation
            }
            self.present(arVC, animated: true, completion: nil)
        }
    }
    
    //MARK:- Google Map Set up
    
    private func handleGoogleMap() {
        let myLocation = CLLocationCoordinate2D(latitude: GPXFile.cherryHillPath.first?.0 ?? 0, longitude: GPXFile.cherryHillPath.first?.1 ?? 0)
        let cabLocation = CLLocationCoordinate2D(latitude: GPXFile.cherryHillPath.last?.0 ?? 0, longitude: GPXFile.cherryHillPath.last?.1 ?? 0)
        googleMapSetUp(location: myLocation)
        createMarker(location: myLocation, mapView: mapView, markerTitle: "From Location", snippet: "")
        createMarker(location: cabLocation, mapView: mapView, markerTitle: "Cab Location", snippet: "Waiting...")
        drawPath(map: mapView, pathArray: GPXFile.cherryHillPath)
    }
    
    private func googleMapSetUp(location : CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: defaultZoomLabel)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        mapView.isUserInteractionEnabled = true
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(mapView)
    }
    
    private func createMarker(location : CLLocationCoordinate2D, mapView : GMSMapView, markerTitle : String, snippet : String, image : UIImage? = nil, markerName : String? = nil) {
        let marker = GMSMarker(position: location)
        marker.title =  markerTitle
        marker.snippet = snippet
        if let image = image {
            marker.icon = image
        }
        if let markerName = markerName {
            marker.userData = markerName
        }
        marker.map = mapView
    }
    
    private func removeMarker(marker : GMSMarker) {
        marker.map = nil
    }
    
    private func drawPath(map : GMSMapView, pathArray : [(Double, Double)]) {
        let path = GMSMutablePath()
        for each in pathArray {
            path.add(CLLocationCoordinate2D(latitude: each.0, longitude: each.1))
        }
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.blue
        polyline.strokeWidth = polylineStokeWidth
        polyline.geodesic = true
        polyline.map = map
    }
}

extension MapViewController : MKMapViewDelegate , CLLocationManagerDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView : MKAnnotationView?
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView?.canShowCallout = true
        annotationView?.isEnabled = true
        return annotationView
    }
    
    private func sameLocation(location1 : CLLocationCoordinate2D, location2 : CLLocationCoordinate2D) -> Bool  {
        return location1.latitude == location2.latitude && location1.longitude == location2.longitude
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            createRegion(coordinate: location.coordinate)
            if let userLocationMarker = self.userLocationMarker {
                removeMarker(marker: userLocationMarker)
            }
            userLocationMarker = GMSMarker(position: location.coordinate)
            userLocationMarker.title = "User Location"
            userLocationMarker.snippet = ""
            if let image = UIImage(named: "blue-dot") {
                userLocationMarker.icon = image
            }
            userLocationMarker.map = mapView
        }
    }
    
    // Getting a new heading
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let rotation = newHeading.magneticHeading * Double.pi / 180
        print("rotation : \(rotation)")
    }
}
