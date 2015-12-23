//
//  CoffeeAnnotation.swift
//  Coffee
//
//  Created by Marquis Dennis on 12/22/15.
//  Copyright © 2015 Marquis Dennis. All rights reserved.
//

import Foundation
import MapKit

class CoffeeAnnotation: NSObject {
    let title:String?
    let subtitle:String?
    let coordinate:CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}

extension CoffeeAnnotation : MKAnnotation {
    
}