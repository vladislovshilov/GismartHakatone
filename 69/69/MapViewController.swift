//
//  MapViewController.swift
//  69
//
//  Created by Vlados iOS on 7/13/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import UIKit
import GoogleMaps

final class MapViewController: UIViewController {
    // MARK: - Properties
    private var mapView: GMSMapView?
    
    // MARK: - Lifecycle
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 53.9, longitude: 27.56667, zoom: 13.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView?.delegate = self
        view = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 53.846243, longitude: 27.696686)
        marker.map = mapView
    }
}

// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
        self.present(controller, animated: true, completion: nil)
        
        return true
    }
}
