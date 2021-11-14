//
//  PlaceData.swift
//  Demo
//
//  Created by Jamil on 14/11/21.
//

import Foundation
import CoreLocation

class SoundInfo: NSObject {
    var id:Int64 = 0
    var coordinate: CLLocationCoordinate2D? = nil //CLLocationCoordinate2D?
    var audioFile: String = ""
    var isRecord: Bool = false
}
