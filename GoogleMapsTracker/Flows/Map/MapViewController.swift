//
//  MapViewController.swift
//  GoogleMapsTracker
//
//  Created by Оксана Каменчук on 14.02.2023.
//

import UIKit
import GoogleMaps
import CoreLocation
import Realm
import RealmSwift

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var currentLocationButton: UIButton!
    @IBOutlet var startTrackButton: UIButton!
    @IBOutlet var stopTrackButton: UIButton!
    @IBOutlet var loadPreviousTrackButton: UIButton!
    
    @IBOutlet var trackButton: UIButton!
    
    var marker: GMSMarker?
    var coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var geoCoder: CLGeocoder?
    var locationManager = CLLocationManager()
    var route: GMSPolyline?
    var routePath = GMSMutablePath()
    
    var routeCoordinate = [CLLocationCoordinate2D]()
    var isUpdateLocation = false
    
    @IBAction func didTapAddMarker(_ sender: UIButton) {
        if marker == nil {
            mapView.animate(toLocation: coordinate)
            addMarker(coordinate: coordinate)
        } else {
            removeMarker()
        }
    }
    
    @IBAction func didTapTrack(_ sender: Any) {
        locationManager.requestLocation()
                
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
                
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func updateLocation(_ sender: UIButton) {
        isUpdateLocation.toggle()

        routePath.removeAllCoordinates()
        mapView.clear()
        setupRoute()
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func stopTrack(_ sender: UIButton?) {
        savePath()
        mapView.clear()
        routePath.removeAllCoordinates()
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func loadPreviousTrack(_ sender: UIButton) {
        if isUpdateLocation {
            alertTracking()
        } else {
            viewLastPath()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        configureMap()
        configureLocationManager()
    }
    
    private func configureMap() {
        
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
    }
    
    private func addMarker(coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
    }
    
    private func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    func alertTracking(){
            
        let alert = UIAlertController(title: "Внимание!", message: "Для отображения маршрута необходимо остановить слежение!", preferredStyle: .alert)
        let actionCansel = UIAlertAction(title: "Отмена", style: .cancel)
        let actionOk = UIAlertAction(title: "Ок", style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isUpdateLocation = false
            strongSelf.locationManager.stopUpdatingLocation()
            strongSelf.mapView.clear()
            strongSelf.viewLastPath()
        }
        alert.addAction(actionCansel)
        alert.addAction(actionOk)
        self.present(alert, animated: true, completion: nil)
    }
        
    private func setupRoute(){
            
        route = GMSPolyline(path: routePath)
        route?.map = mapView
    }
        
    private func savePath(){
            
        let countDotRoute = routePath.count()
        for index in 0..<countDotRoute {
            routeCoordinate.append(routePath.coordinate(at: index))
        }
        let realmService = try! RealmService()
        realmService.removeCoordinate()
        realmService.putCoordinate(coordinates: routeCoordinate)
    }
        
    private func viewLastPath(){
            
        let realmService = try! RealmService()
        let coodinates = realmService.getCoodinate()
        routePath.removeAllCoordinates()
        for coordinate in coodinates {
            routePath.add(coordinate)
        }
        route = GMSPolyline(path: routePath)
        route?.map = mapView
        let bounds = GMSCoordinateBounds(path: routePath)
        let update = GMSCameraUpdate.fit(bounds)
        mapView.animate(with: update)
    }
    
    
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        print(coordinate)
        let manualMarker = GMSMarker(position: coordinate)
        manualMarker.map = mapView
        
        if geoCoder == nil {
            geoCoder = CLGeocoder()
        }
        
        geoCoder?.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { places, error in
            
            print(places?.last as Any)
            print(error as Any)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else { return }
        
        routePath.add(location.coordinate)
        route?.path = routePath
        
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15)
        mapView.animate(to: position)
        
        print(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
