//
//  MapViewController.swift
//  GPSTrackingTest
//
//  Created by Connor Holland on 3/4/21.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var trackingSwitch: UISwitch!
    
    //VARIABLES
    var locationManager:CLLocationManager?
    var previousLocation: CLLocation?
    let db = Firestore.firestore().collection("CurrentLocation")
    let regionInMeters: Double = 100
    var lat: CLLocationDegrees?
    var lon: CLLocationDegrees?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        trackingSwitch.isOn = false
        locationManagerSetup()
//        createAnnotation()
    }
    
    //METHODS
    
    func createAnnotation(isTracking: Bool) {
        let truck = FoodTruck(title: "FED", coordinate: CLLocationCoordinate2D(latitude: 40.0150, longitude: 105.2705))
        if isTracking == true {
            mapView.addAnnotation(truck)
            fetchCurrentLocation(truck: truck)
        } else {
//            mapView.removeAnnotation(truck)
            DispatchQueue.main.async {
                self.mapView.removeAnnotation(truck)
            }
        }
//        let truck = FoodTruck(title: "FED", coordinate: CLLocationCoordinate2D(latitude: 40.0150, longitude: 105.2705))
//        mapView.addAnnotation(truck)
//        fetchCurrentLocation(truck: truck)
    }
    
    func fetchCurrentLocation(truck: FoodTruck) {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            let docRef = self.db.document("cordinates")
            docRef.getDocument { (document, err) in
                if let document = document, document.exists {
                    print(document.data())

                    let data = document.data()
                    guard let lat = data!["lat"] as? Double, let lon = data!["lon"] as? Double else {return}
                    self.lat = lat
                    self.lon = lon

                    let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters)
                    self.mapView.setRegion(region, animated: true)

                    MKMapView.animate(withDuration: 0.25) {
                        truck.coordinate = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.lon!)
//                        self.getAddressFromLatLon(pdblLatitude: String(self.lat!), withLongitude: String(self.lon!))
                        print("Hi")
                    }
                } else {
                    print("No document found")
                }
            }
        }
    }
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = Double("\(pdblLatitude)")!
            //21.228124
            let lon: Double = Double("\(pdblLongitude)")!
            //72.833770
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)

        
            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]

                    if pm.count > 0 {
                        let pm = placemarks![0]
                        print(pm.country)
                        print(pm.locality)
                        print(pm.subLocality)
                        print(pm.thoroughfare)
                        print(pm.postalCode)
                        print(pm.subThoroughfare)
                        var addressString : String = ""
                        if pm.subThoroughfare != nil {
                            addressString = addressString + pm.subThoroughfare! + " "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.administrativeArea != nil {
                            addressString = addressString + pm.administrativeArea! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country!
                        }
                        print(addressString)
                        self.addressLabel.text = addressString
                  }
            })
        }
    
    
    
    
    //Original Location Methods
    func locationManagerSetup() {
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        previousLocation = centerViewOnUserLocation()
    }
    
    func centerViewOnUserLocation() -> CLLocation {
        if let user_location = locationManager?.location?.coordinate {
            return CLLocation(latitude: user_location.latitude, longitude: user_location.longitude)
        }
        return CLLocation(latitude: 0, longitude: 0)
    }
    
    
    
    //ACTIONS
    @IBAction func trackingSwitchToggled(_ sender: Any) {
        if trackingSwitch.isOn == true {
            locationManager?.startUpdatingLocation()
            createAnnotation(isTracking: true)
        } else {
            locationManager?.stopUpdatingLocation()
            createAnnotation(isTracking: false)
        }
    }
}


extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
//          centerViewOnUserLocation()
            if centerViewOnUserLocation().distance(from: previousLocation!) > 15 || centerViewOnUserLocation().distance(from: previousLocation!) == 0 {
                previousLocation = centerViewOnUserLocation()
//                let loc = centerViewOnUserLocation()
                self.getAddressFromLatLon(pdblLatitude: String((previousLocation?.coordinate.latitude)!), withLongitude: String((previousLocation?.coordinate.longitude)!))
                db.document("cordinates").setData(["lon": Double((previousLocation?.coordinate.longitude)!), "lat": Double((previousLocation?.coordinate.latitude)!)])
            } else {
                print("bye")
            }
        }
    }
    
}
