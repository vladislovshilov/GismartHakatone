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
    private var playersMarkers = [GMSMarker]()
    
    var gameConfiguration: GameConfiguration?
    var players = [Player]()
    
    // MARK: Flow handlers
    var onGameStartHandler: (() -> Void)?
    
    // MARK: - Lifecycle
    override func loadView() {
        setupMap()
        addPlayersOnMap()
    }
    
    // MARK: - Support methods
    private func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 53.9, longitude: 27.56667, zoom: 13.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView?.delegate = self
        view = mapView
    }
    
    private func addPlayersOnMap() {
        players.forEach { player in
            let marker = GMSMarker()
            marker.icon = player.iconImage
            marker.position = player.location.toCoordinates()
            
            marker.map = mapView
            playersMarkers.append(marker)
        }
    }
}

// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        onGameStartHandler?()
        
        return true
    }
}
