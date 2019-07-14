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
    var onGameContinueHandler: (() -> Void)? { get set }
    
    var gameConfiguration: GameConfiguration? { get set }
    
    func showProjectileAnimation()
}

final class MapViewController: UIViewController,
IMapScene {
    // MARK: - Properties
    private var mapView: GMSMapView?
    private var playersMarkers = [GMSMarker]()
    private var chickenMarker: GMSMarker?
    
    private var enemyPlayer: Player?
    
    var gameConfiguration: GameConfiguration?
    var players = [Player]()
    
    // MARK: Flow handlers
    var onGameStartHandler: ((_ enemyPlayer: Player) -> Void)?
    var onGameContinueHandler: (() -> Void)?
    
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
        
        let projectileCoordinates = calculateProjectileCoordinates()
        showChickenAnimation(from: currentLocation, to: projectileCoordinates)
    }
    
    private func calculateProjectileCoordinates() -> CLLocationCoordinate2D {
        guard let gameConfiguration = gameConfiguration else {
            return enemyPlayer!.location.toCoordinates()
        }
        
        let supposedIdealAngle = 45 * gameConfiguration.distanceToEnemy / gameConfiguration.slingshotType.maxDistance
        let supposedRoundedAngle = Int(supposedIdealAngle)
        print(supposedRoundedAngle)
        
        if supposedRoundedAngle > gameConfiguration.angle - 5 &&
            supposedRoundedAngle < gameConfiguration.angle + 5 {
            return enemyPlayer!.location.toCoordinates()
        }
        else {
            let currentLocation = mapView!.myLocation!.coordinate
            let enemyCoordinates = enemyPlayer!.location.toCoordinates()
            let boundingBox = GMSCoordinateBounds(coordinate: currentLocation,
                                                  coordinate: enemyCoordinates)
            
            return boundingBox.southWest
        }
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
    
    private func showChickenAnimation(from startCoordinates: CLLocationCoordinate2D, to endCoordinates: CLLocationCoordinate2D) {
        if chickenMarker == nil {
            let image = UIImage(named:"chicken")
            
            chickenMarker = GMSMarker()
            chickenMarker!.position = startCoordinates
            chickenMarker!.icon = image
            chickenMarker!.setIconSize(scaledToSize: CGSize(width: 40, height: 50))
            chickenMarker!.map = mapView
            chickenMarker!.appearAnimation = .pop
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let `self` = self else { return }
                CATransaction.begin()
                CATransaction.setAnimationDuration(2.0)
                self.chickenMarker!.position = endCoordinates
                CATransaction.commit()
                CATransaction.setCompletionBlock({
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        self?.chickenMarker?.map = nil
                        self?.chickenMarker = nil
                        self?.onGameContinueHandler?()
                    }
                })
            }
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
            let enemyLocation = CLLocation(latitude: enemyPlayer!.location.latitude,
                                           longitude: enemyPlayer!.location.longitude)
            if let distanceToEnemy = mapView.myLocation?.distance(from: enemyLocation) {
                gameConfiguration?.distanceToEnemy = distanceToEnemy
            }
            
            gameConfiguration?.isGameStarted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let `self` = self else { return }
                self.onGameStartHandler?(self.enemyPlayer!)
            }
        }
        
        return true
    }
}

extension GMSMarker {
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
}
