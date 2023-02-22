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
import RxSwift

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var currentLocationButton: UIButton!
    @IBOutlet var startTrackButton: UIButton!
    @IBOutlet var stopTrackButton: UIButton!
    @IBOutlet var loadPreviousTrackButton: UIButton!
    
    var marker: GMSMarker?
    var coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var geoCoder: CLGeocoder?
    private let locationManager = LocationManager()
    var route: GMSPolyline?
    var routePath = GMSMutablePath()
    
    var routeCoordinate = [CLLocationCoordinate2D]()
    var isUpdateLocation = false
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        configureMap()
        setupLocationManager()
    }
    
    private func configureMap() {
        
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
    
    private func setupLocationManager(){

        locationManager.autorizationStatus.subscribe(onNext: { [weak self] status in
            let locationStatus = status
            switch locationStatus {
            case .notDetermined:
                self?.locationManager.requestAuthorizationAccess()
            case .restricted, .denied:
                print("Location access denied")
            case .authorizedAlways, .authorizedWhenInUse:
                self?.locationManager.startUpdateLocation()
            @unknown default:
                break
            }
        })
        .disposed(by: disposeBag)
        locationManager.userLocation.subscribe(onNext: { [weak self] location in
            self?.drawPath(location: location)
        })
        .disposed(by: disposeBag)
    }
    
    @IBAction func didTapAddMarker(_ sender: UIButton) {
        if marker == nil {
            mapView.animate(toLocation: coordinate)
            addMarker(coordinate: coordinate)
        } else {
            removeMarker()
        }
    }
    
    @IBAction func updateLocation(_ sender: UIButton) {
        isUpdateLocation.toggle()

        routePath.removeAllCoordinates()
        mapView.clear()
        setupRoute()
        locationManager.startUpdateLocation()
        
    }
    
    @IBAction func stopTrack(_ sender: UIButton?) {
        savePath()
        mapView.clear()
        routePath.removeAllCoordinates()
        locationManager.stopUpdateLocation()
    }
    
    @IBAction func loadPreviousTrack(_ sender: UIButton) {
        if isUpdateLocation {
            alertTracking()
        } else {
            viewLastPath()
        }
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
            strongSelf.locationManager.stopUpdateLocation()
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
    
    private func drawPath(location: CLLocation){
        let position = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
        mapView.animate(to: position)
        routePath.add(location.coordinate)
        route?.path = routePath
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
