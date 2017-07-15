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
    
    // n th number of coordinates , having (n-1) number of sections in the route. ( Which will fetch from Back-end )
    
    /*  // [ My Home Position ]
    let path = [(12.944567,77.649899) , (12.944847, 77.649982) , (12.945008,77.649492) , (12.944841,77.649175)]
    let sectionCoordinates = [
                                [(12.944567,77.649899), (12.944589, 77.649897), (12.944624, 77.649896), (12.944697, 77.649906), (12.944753, 77.649929), (12.944821, 77.649967), (12.944847, 77.649982)],
                                [(12.944874, 77.649892),(12.944885, 77.649838),(12.944934, 77.649707), (12.944950, 77.649653),(12.944979, 77.649567),(12.945008,77.649492)],
                                [(12.944975, 77.649425), (12.944946, 77.649384), (12.944907, 77.649304), (12.944841,77.649175)]
                             ]
    */
    
    // [Chery Hills]
    let cherryHillPath = [(12.950268, 77.641723), (12.950439, 77.641744), (12.950376, 77.642187)]
    let cherryHillsSectionCoordinates = [
             [(12.950268, 77.641723), (12.950299, 77.641718),(12.950325, 77.641718), (12.950351, 77.641720),(12.950385, 77.641731), (12.950408, 77.641742),(12.950439, 77.641744)],
             [(12.950441, 77.641796),(12.950427, 77.641839), (12.950419, 77.641892), (12.950414, 77.641951), (12.950401, 77.642013), (12.950388, 77.642072), (12.950375, 77.642144), (12.950376, 77.642187)]
         ]
    
    private var mapView : GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myLocation = CLLocationCoordinate2D(latitude: cherryHillPath.first?.0 ?? 0, longitude: cherryHillPath.first?.1 ?? 0)
        let cabLocation = CLLocationCoordinate2D(latitude: cherryHillPath.last?.0 ?? 0, longitude: cherryHillPath.last?.1 ?? 0)
        
        mapSetUp(location: myLocation)
        
        createMarker(location: myLocation, mapView: mapView, markerTitle: "Bangalore", snippet: "India")
        createMarker(location: cabLocation, mapView: mapView, markerTitle: "Cab Location", snippet: "Waiting")
        drawPath(map: mapView, pathArray: cherryHillPath)
    }
    
    
    @IBAction func openARView(_ sender: UIBarButtonItem) {
        if let arVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARViewController") as? UINavigationController {
            if let vc = arVC.visibleViewController as? ARViewController {
                vc.sectionCoordinates = cherryHillsSectionCoordinates
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
}
