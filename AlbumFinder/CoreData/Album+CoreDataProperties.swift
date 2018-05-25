//
//  Album+CoreDataProperties.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 15/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//
//

import Foundation
import CoreData

//Generado por CoreData, define los atributos del tipo "Album" y métodos para añadir y eliminar "Tracks", que es otra tabla relacionada. (La Relación entre Album y Track es de uno a muchos: Cada Album tiene muchas pistas).
extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var artist: String?
    @NSManaged public var id: String?
    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    @NSManaged public var year: String?
    @NSManaged public var tracks: Set<Track>

}

// MARK: Generated accessors for tracks
extension Album {

    @objc(addTracksObject:)
    @NSManaged public func addToTracks(_ value: Track)

    @objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: Track)

    @objc(addTracks:)
    @NSManaged public func addToTracks(_ values: Set<Track>)

    @objc(removeTracks:)
    @NSManaged public func removeFromTracks(_ values: Set<Track>)

}
