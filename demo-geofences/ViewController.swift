//
//  ViewController.swift
//  demo-geofences
//
//  Created by Daniel Otero Cortes on 17/7/17.
//  Copyright © 2017 Daniel Otero Cortes. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet weak var geofencesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager : CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = (UIApplication.shared.delegate as? AppDelegate)?.locationManager
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))
        mapView.addGestureRecognizer(longPressGR)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        mapView.showsUserLocation = true;
        if let region = locationManager?.monitoredRegions.first as? CLCircularRegion {
            let mapRegion = MKCoordinateRegion(center: region.center, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(mapRegion, animated: true)
        }
        setupView()
    }
    
    func setupView() {
        mapView.removeOverlays(mapView.overlays)
        if let locationManager = locationManager, let region = locationManager.monitoredRegions.first as? CLCircularRegion {
            self.geofencesLabel.text = "Geofence ON"
            mapView.addOverlay(MKCircle(center: region.center, radius: region.radius))
        } else {
            self.geofencesLabel.text = "Geofence OFF"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleGeofences(_ sender: Any) {
        if let region = locationManager?.monitoredRegions.first {
            locationManager?.stopMonitoring(for: region)
            locationManager?.allowsBackgroundLocationUpdates = false
        } else if let location = locationManager?.location {
            startMonitoringRegion(coordinate: location.coordinate)
        } else {
            let alert = UIAlertController(title: nil, message: "Unable to set geofence", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
        setupView()
    }
    
    func startMonitoringRegion(coordinate: CLLocationCoordinate2D, radious: CLLocationDistance = 1000) {
        let region = CLCircularRegion(center: coordinate, radius: radious, identifier: "MonitoredRegion")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        // If already exists a region with same id will be updated
        locationManager?.startMonitoring(for: region)
        locationManager?.allowsBackgroundLocationUpdates = true

        setupView()
    }
    
    @objc func onLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            startMonitoringRegion(coordinate: locationOnMap)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.3)
        return circleRenderer
    }
}

