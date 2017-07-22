//
//  MapViewController.swift
//  ARDemo
//
//  Created by Ashis Laha on 13/07/17.
//  Copyright © 2017 Ashis Laha. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController , UIGestureRecognizerDelegate {
    
    let defaultZoomLabel : Float = 19.0
    let polylineStokeWidth : CGFloat = 10.0
    var worldTrackingFactor : Float = 100000
    
    private var mapView : GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myLocation = CLLocationCoordinate2D(latitude: GPXFile.cherryHillPath.first?.0 ?? 0, longitude: GPXFile.cherryHillPath.first?.1 ?? 0)
        let cabLocation = CLLocationCoordinate2D(latitude: GPXFile.cherryHillPath.last?.0 ?? 0, longitude: GPXFile.cherryHillPath.last?.1 ?? 0)
        
        mapSetUp(location: myLocation)
        
        createMarker(location: myLocation, mapView: mapView, markerTitle: "My Location", snippet: "")
        createMarker(location: cabLocation, mapView: mapView, markerTitle: "Cab Location", snippet: "Waiting...")
        drawPath(map: mapView, pathArray: GPXFile.cherryHillPath)
    }
    
    
    @IBAction func openARView(_ sender: UIBarButtonItem) {
        if let arVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARViewController") as? UINavigationController {
            if let vc = arVC.visibleViewController as? ARViewController {
                vc.sectionCoordinates = GPXFile.cherryHillsSectionCoordinates
                vc.carLocation = GPXFile.cherryHillsCarLocation
                vc.worldTrackingFactor = worldTrackingFactor
            }
            self.present(arVC, animated: true, completion: nil)
        }
    }
    
    private func mapSetUp(location : CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: defaultZoomLabel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isUserInteractionEnabled = true
        view = mapView
    }
    
    private func createMarker(location : CLLocationCoordinate2D, mapView : GMSMapView, markerTitle : String, snippet : String ) {
        let marker = GMSMarker(position: location)
        marker.title =  markerTitle
        marker.snippet = snippet
        marker.map = mapView
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
    
    @IBAction func mappingFacorAction(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "MappingFactor", message: "Use for mapping from GeoCoordinate to Real World", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "100000", style: .default) { [weak self] (action) in
            self?.worldTrackingFactor = 100000
            actionSheet.dismiss(animated: true, completion: nil)
        }
        let action2 = UIAlertAction(title: "75000", style: .default) { [weak self] (action) in
            self?.worldTrackingFactor = 75000
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        let action3 = UIAlertAction(title: "50000", style: .default) { [weak self] (action) in
            self?.worldTrackingFactor = 50000
            actionSheet.dismiss(animated: true, completion: nil)
        }
        let action4 = UIAlertAction(title: "10000", style: .default) { [weak self] (action) in
            self?.worldTrackingFactor = 10000
            actionSheet.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        actionSheet.addAction(action4)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
}
