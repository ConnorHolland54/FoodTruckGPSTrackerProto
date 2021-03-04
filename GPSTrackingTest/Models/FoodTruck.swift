//
//  FoodTruck.swift
//  GPSTrackingTest
//
//  Created by Connor Holland on 3/3/21.
//

import UIKit
import MapKit

class FoodTruck: NSObject, MKAnnotation {
    var title: String?
    dynamic var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
