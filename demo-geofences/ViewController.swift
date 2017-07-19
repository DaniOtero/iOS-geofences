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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var geofencesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager : CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            locationManager = appDelegate.locationManager
            locationManager?.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        mapView.showsUserLocation = true;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func notify(msg : String) {
        let content = UNMutableNotificationContent()
        content.title = "Autentia"
        content.body = msg
        let request = UNNotificationRequest(identifier: "geofence", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    @IBAction func toggleGeofences(_ sender: Any) {
        if let locationManager = self.locationManager {
            let region = self.regionToMonitor()
            if(locationManager.monitoredRegions.count > 0) {
                self.geofencesLabel.text = "Geofences OFF"
                locationManager.stopMonitoring(for: region)
                mapView.removeOverlays(mapView.overlays)
            } else {
                self.geofencesLabel.text = "Geofences ON"
                locationManager.startMonitoring(for: region)
                mapView.add(MKCircle(center: region.center, radius: region.radius))
            }
        } else {
            notify(msg: "Unable to set geofence")
        }
    }
    
    func regionToMonitor() -> CLCircularRegion {
        let autentia = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 40.453163, longitude: -3.509220), radius: 100, identifier: "autentia")
        autentia.notifyOnExit = true
        autentia.notifyOnEntry = true
        return autentia
    }
    
    // MARK: - CLLocationManagerDelegagte methods
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        notify(msg: "Hello from Autentia")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        notify(msg: "Bye from Autentia")
    }
    
    // MARK: MapKitViewDelegate methods
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.3)
        return circleRenderer
    }
}

