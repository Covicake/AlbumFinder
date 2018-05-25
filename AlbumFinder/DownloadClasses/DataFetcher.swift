//
//  DataFetcher.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 11/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//

import UIKit


//Esta clase se utiliza para realizar la conexión con la api de Discogs y obtener los álbumbes, las listas de canciones y las imágenes de portada.

class DataFetcher{
    static let dataFetcher = DataFetcher()  //instancia estática de la clase que es llamada desde cualquier parte de la aplicación
    
    var album: DownloadedAlbum!  //El modelo para organizar los datos que recibimos.
    
    var albumes: [DownloadedAlbum] = [] //Array para almacenar los álbumes que se encuentren.
    
    var titulo: String!  //Título del álbum
    var artista: String!  //Artista del álbum
    var year: String!   //Año de lanzamiento del álbum
    var pagina: String!  //La API de Discogs pagina sus resultados según cuántos quieras ver por página. Yo he indicado que quiero 15 resultados por página porque: 1. No muchos artistas tienen más de 15 álbumes (LP) y 2. Para no demorar demasiado la transición desde que el usuario pulsa el botón buscar y que se enseñen los resultados. Entonces, 15 resultados por página, y tantas páginas como devuelva Discogs. Utilizaremos esta variable para indicar a discogs qué página de los resultados queremos.
    
    var done: Bool = false //Se pone a true cuando la descarga termina y false cuando la descarga inicia.
    var trackDone: Bool = false  //Funciona similar que la anterior, pero en el caso concreto de descargar las pistas de una canción.
    var pages: Int!  //Total de páginas de resultados que devuelve Discgos.
    
    
            //Este método descarga las imágenes de portada de los álbumes. Es llamada desde la propia clase álbum, de modo que cada álbum descarga su propia imagen una vez es instanciado.
    
    func FetchImageFromURL(imgAlbum: DownloadedAlbum){
        if(!imgAlbum.imageURL.elementsEqual("")){ //Si la url de la imagen no está vacía
            let url = URL(string: imgAlbum.imageURL)  //Convertimos el String en url
            let urlRequest = URLRequest(url: url!)  //Y creamos un urlRequest.
            
            let getImageFromUrl = URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in  //Creamos el dataTask con la url
                
                //Si hay algún error, se muestra por pantalla
                if let e = error {
                    print("Error Occurred: \(e)")
                    
                } else {
                    //Si no hay error, comprobamos que la respuesta no sea "nil"
                    if (response as? HTTPURLResponse) != nil {
                        
                        //Comprobamos que la respuesta contenga una imagen
                        if let imageData = data {
                            
                            //convertimos los datos binario en imagen.
                            let image = UIImage(data: imageData)
                            
                            //Y la asignamos al atributo correspondiente en la clase ÁlbumDownloaded
                            DispatchQueue.main.async {
                                imgAlbum.image = image
                                imgAlbum.imageDownloaded = true //También indicamos que se ha descargado la imagen.
                            }
                            
                        } else {
                            print("Imagen corrupta")
                        }
                    } else {
                        print("No se obtuvo respuesta del servidor")
                    }
                }
            })
            
            //iniciamos el dataTask.
            getImageFromUrl.resume()
            
        }else{
            //Si hay algún problema con la descarga, se carga una imagen por defecto en su lugar
            imgAlbum.image = UIImage(named: "defaultAlbumImage")
            imgAlbum.imageDownloaded = true
        }
        
    }
    
    //El usuario puede introducir muchos caracteres que URL(string: ) no soporta, de modo que los eliminamos con el método "addingPercentEncoding" indicando que solo debe permitir los caracteres que permita urlQuery.
    func correctorCaracteresEspeciales(cadena: String)->String{
        var cadena2 = cadena
        
        //Además eliminamos el "&" y el "+" porque son caracteres usados por la api y pueden dar problemas.
        cadena2 = cadena2.replacingOccurrences(of: "&", with: "")
        cadena2 = cadena2.replacingOccurrences(of: "+", with: "")
        cadena2 = cadena.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        return cadena2
        
    }
    
    
    //Este método descarga la lista de canciones de un álbum determinado una vez es elegido por el usuario.
    func FetchTrackList(album: DownloadedAlbum){
        self.trackDone = false  //Se pone false cuando se inicia la descarga y true cuando termina.
        let url = URL(string: "https://api.discogs.com/masters/"+album.id)  //Construimos la URL utilizando el id del álbum (Nos lo proporciona discogs cuando
                                                                            //descargamos el álbum)
        let urlRequest = URLRequest(url: url!)
        let trackListDownload = URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            
            if error != nil{
                print("error de descarga")
            }else{
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {  //Se hace la consulta a la url
                    
                    
                    if let trackListArray = jsonObj!.value(forKey: "tracklist") as? NSArray {  //Cargamos el array contenido en la etiqueta "tracklist"
                        
                        for track in 0...trackListArray.count-1{  //Recorremos el array.
                            if let trackDict = trackListArray[track] as? NSDictionary{
                                
                                //Y nos quedamos con el contenido de las etiquetas "title" y "duration"
                                let titulo = trackDict.value(forKey: "title") as! String
                                let duracion = trackDict.value(forKey: "duration") as! String
                                album.setTrackList(titulo: titulo, duracion: duracion)  //Añadimos las pistas al álbum.
                            }
                        }
                    }
                
                }
            }
            OperationQueue.main.addOperation({
                self.trackDone = true  //Una vez finalizada la descarga, ponemos esta variable en true.
                
            })
            
        })
        trackListDownload.resume()  //Se inicia el dataTask.
    }
    
    
    //Este método descarga una lista de álbumes resultado de una consulta a la API de discogs.
    func FetchDataFromURL(artista: String, titulo: String, año: String, pagina: String, barcode: String!){
        let KEY = "truWQWzyMiEfrexRnEww"  //API KEY
        let SECRET = "bQRdMPpswbANmvcIFBqbyKhuUerjKiTO"  //API SECRET
        let BASE_URL = "https://api.discogs.com/database/search?q="  //API QUERY URL
        
        var mainSearchTerm = ""  //Esto va justo después de "?q=" y es el término principal de la búsqueda, al que se da prioridad-
        self.done = false  //Ponemos "done" en false.
        self.artista = artista //El artista del álbum recibido por parámetro.
        self.titulo = titulo  //El título del álbum recibido por parámetro.
        self.year = año  //El año de lanzamiento del álbum recibido por parámetro.
        self.pagina = pagina  //La página de resultado que queremos ver recibida por parámetro.

        self.albumes.removeAll()  //Vaciamos el array porque vamos a rellenarlo.
        
        if (artista != ""){  //Si el usuario introdujo algo en el campo "artista"
            mainSearchTerm = self.artista  //Lo convertimos en nuestro término principal de búsqueda.
        }else if(titulo != ""){ //Si no hay artista, pero sí título, éste se convierte en nuestro término principal.
            mainSearchTerm = self.titulo
        }else{ //Y si no hay ni artista ni título, debe haber año, así que el término principal será el año de lanzamiento.
            mainSearchTerm = self.year
        }
        
        
        let urlString: String  //Declaramos un String sin inicializar
        if(barcode != ""){ //Si la búsqueda se se realiza mediante un código de barras, entonces solo necesitamos ese valor porque nos retornará un único resultado.
            urlString = "\(BASE_URL)\(barcode)&?artist=&title=&year=&barcode=\(barcode)&type=master&key=\(KEY)&secret=\(SECRET)"
        }else{ //Si no hay código de barras, utilizamos el artista, titulo y año para realizar la búsqueda.
            urlString = "\(BASE_URL)\(mainSearchTerm)&?artist=\(self.artista!)&title=\(self.titulo!)&year=\(self.year!)&format=album&type=master&per_page=15&page=\(pagina)&key=\(KEY)&secret=\(SECRET)"
        }
        


        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
    
        
            let JSONdownload = URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            
            if (error != nil){
                print("Ha habido un error")
            }else{
                
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {  //Se hace la consulta a la url
                
                
                if let resultsArray = jsonObj!.value(forKey: "results") as? NSArray {  //Cargamos el array contenido en la etiqueta "results"
                    
                    for result in resultsArray{  //Recorremos el array.
                        
                        if let resultsDict = result as? NSDictionary {  //Cada elemento del array es un diccionario.
                            var splited: [Substring] = [] //Definimos un array de substrings.
                            let titulo_y_artista = resultsDict.value(forKey: "title") as! String  //Obtenemos el título y artista que están contenidos en la etiqueta "title" con el formato: artista - titulo.
                            splited = titulo_y_artista.split(separator: "-") //Separamos la cadena por " - "
                            var artista = splited[0] //Artista será el primer trozo
                            var titulo: Substring = "" //Título será el resto de trozos (puede haber más de un guión).
                            for i in 1...splited.count-1 {
                                titulo.append(contentsOf: splited[i])
                                if(i+1 != splited.count){
                                    titulo.append(contentsOf: "-")
                                }
                            }
                            
                            artista.removeLast()//Eliminamos el caracter vacío que hay al final de artista("artista ")
                            titulo.removeFirst() //Y el primero que hay en titulo (" titulo")
                            var year: String
                            if ((resultsDict.value(forKey: "year")) != nil){
                                year = resultsDict.value(forKey: "year") as! String
                            }else{
                                year = "-" //Si la etiqueta "year" no contiene información, asignamos "-" en su lugar.
                            }
                            let imageURL = resultsDict.value(forKey: "thumb") as! String //Obtenemos la URL de la imagen de portada.
                            let id = resultsDict.value(forKey: "id") as! Int //Y el id del álbum.
                            
                            //Inicializamos un álbum de tipo DownloadedAlbum con todos estos datos.
                            self.album = DownloadedAlbum(titulo: String(titulo), artista: String(artista), year: year, imageURL: imageURL, id: String(id))
                            }
                        self.albumes.append(self.album) //Lo añadimos a nuestro array de resultados.
                        }
                    }
                
                if let pagesDict = jsonObj!.value(forKey: "pagination") as? NSDictionary{  //Obtenemos el contenido de la etiqueta "pagination" que está al mismo nivel que "results"
                            self.pages = pagesDict.value(forKey: "pages") as! Int //Y obtenemos el número de páginas.
                        }
                }
                
                
                OperationQueue.main.addOperation({
                    self.done = true  //Marcamos done cuando termina la descarga.
                })
            }
    })
        JSONdownload.resume()
    }
    
}
