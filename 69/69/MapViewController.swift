//
//  MapViewController.swift
//  69
//
//  Created by Vlados iOS on 7/13/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import UIKit
import GoogleMaps

protocol IMapScene: UIViewController {
    var onGameStartHandler: (() -> Void)? { get set }
    
    var gameConfiguration: GameConfiguration? { get set }
}

final class MapViewController: UIViewController,
                               IMapScene {
    // MARK: - Properties
    private var mapView: GMSMapView?
    
    var gameConfiguration: GameConfiguration?
    
    // MARK: Flow handlers
    var onGameStartHandler: (() -> Void)?
    
    // MARK: - Lifecycle
    override func loadView() {
        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(gameConfiguration?.power)
    }
    
    // MARK: - Support methods
    private func setupMap() {
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
        onGameStartHandler?()
        
        return true
    }
}
