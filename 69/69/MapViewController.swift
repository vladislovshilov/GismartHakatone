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
    var onGameStartHandler: ((_ enemyPlayer: Player) -> Void)? { get set }
    
    var gameConfiguration: GameConfiguration? { get set }
    
    func showProjectileAnimation()
}

final class MapViewController: UIViewController,
                               IMapScene {
    // MARK: - Properties
    private var mapView: GMSMapView?
    private var playersMarkers = [GMSMarker]()
    
    private var enemyPlayer: Player?
    
    var gameConfiguration: GameConfiguration?
    var players = [Player]()
    
    // MARK: Flow handlers
    var onGameStartHandler: ((_ enemyPlayer: Player) -> Void)?
    
    // MARK: - Lifecycle
    override func loadView() {
        setupMap()
        addPlayersOnMap()
    }
    
    // MARK: - IMapScene
    func showProjectileAnimation() {
        guard let currentLocation = mapView?.myLocation?.coordinate,
            let enemyPlayer = enemyPlayer else { return }
        
        let enemyLocation = enemyPlayer.location.toCoordinates()
        let boundingBox = GMSCoordinateBounds(coordinate: currentLocation,
                                              coordinate: enemyLocation)
        let cameraUpdate = GMSCameraUpdate.fit(boundingBox)
        
        mapView?.moveCamera(cameraUpdate)
    }
    
    // MARK: - Support methods
    private func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 53.9, longitude: 27.56667, zoom: 13.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView?.delegate = self
        mapView?.isMyLocationEnabled = true
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
        if let playerIndex = playersMarkers.firstIndex(of: marker), playerIndex < players.count {
            let newCameraPosition = GMSCameraPosition(target: marker.position, zoom: 15)
            mapView.animate(to: newCameraPosition)
            
            enemyPlayer = players[playerIndex]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.onGameStartHandler?(self.enemyPlayer!)
            }
        }
        
        return true
    }
}
