//
//  Constants.swift
//  pixelcity
//
//  Created by Graphene on 7/2/19.
//  Copyright © 2019 tam-lam. All rights reserved.
//

import Foundation
let API_KEY = "795249afa4a4fc38fd87544d201d98d3"


func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    return url
}
