//
//  Track+CoreDataProperties.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 15/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//
//

import Foundation
import CoreData

//Generado por CoreData, define los atributos del tipo "Track"
extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var track_title: String?
    @NSManaged public var track_duration: String?
    @NSManaged public var track_number: NSNumber?
    @NSManaged public var album: Album?

}
