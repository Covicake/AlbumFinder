//
//  DownloadAlbum.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 11/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//

import Foundation
import UIKit


//Esta clase define los atributos y métodos que deben tener los álbumes antes de ser guardados definitivamente en la base de datos. Es decir, cuando se descargan y están solo en memoria.

class DownloadedAlbum{
    
    var titulo: String! //Titulo del album
    var artista: String! //Artista del album
    var year: String!  //Año de lanzamiento del album
    var id: String!  //Id del album en discgos, necesario para descargar la lista de canciones
    var imageURL: String!  //La url donde está la imagen de portada
    var image: UIImage!  //La imagen de portada en sí
    var imageDownloaded: Bool = false  //Bool para saber si ya se ha descargado o no la imagen.
    
    var trackList: [Dictionary<String, String>] = []  //El tracklist es un array de diccionarios con dos pares key-value de tipo String
    
    
    //Tenemos dos constructores dependiendo de los datos de los que dispongamos:
    
    //Uno requiere la url de la imagen
    init(titulo: String, artista: String, year: String, imageURL: String, id: String){
        self.titulo = titulo
        self.artista = artista
        self.year = year
        self.imageURL = imageURL
        DataFetcher.dataFetcher.FetchImageFromURL(imgAlbum: self)
        self.id = id
    }
    
    //Y el otro la imagen en sí.
    init(titulo: String, artista: String, year: String, image: NSData, id: String){
        self.titulo = titulo
        self.artista = artista
        self.year = year
        self.image = UIImage(data: image as Data)
        self.id = id
    }
    
    //Con este método definimos el tracklist, que es un array de diccionarios, recibe un título y un string
    func setTrackList(titulo: String, duracion: String){

        let dictionary = ["titulo": titulo, "duracion": duracion]
        trackList.append(dictionary)

    }
}
