//
//  AlbumDetailViewController.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 12/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//

import UIKit
import CoreData

//Última pantalla de la aplicación. Enseña la imagen de portada, titulo, artista y año del album en grande y un
//tableView con la lista de canciones del mismo.

//Debemos distinguir si venimos desde AlbumListViewController (Primera pantalla con datos cargados en la base de datos) o desde "ResultsViewController" (pantalla anterior con datos descargados de internet)
class AlbumDetailViewController: UIViewController {
    
    var album: DownloadedAlbum! //Un objeto tipo DownloadedAlbum para almacenar temporalmente la información que mostramos.
    var tracks: Set<Track>!  //Una lista de canciones, en este caso la que está guardada en la base de datos
    var track_number: [NSNumber]!  //El número de cada canción dentro del álbum.
    var timer: Timer! //Un timer para comprobar el estado de la descarga de las canciones.
    var showButton: Bool = false  //Para saber si mostramos o no el botón de "guardar", dependiendo de si estamos mostrando los detalles de un album de la base de datos, o si es un album recién descargado.
    
    //El botón solo se muestra para los álbumes recién descargados.

    
    //Outlets.
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var artistaLabel: UILabel!
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var trackTableView: UITableView!
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var GuardarBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Si venimos desde ResultsViewController, habremos definido "showButton = true"
        if(showButton == true){
            GuardarBtn.isHidden = false //De modo que no ocultamos el botón e iniciamos un timer para comprobar la descarga que iniciamos desde la pantalla anterior.
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkDownload), userInfo: nil, repeats: true)
        }
        
        //Definimos el dataSource y delegate de la tableView.
        trackTableView.dataSource = self
        trackTableView.delegate = self
        
        //Con el album recibido desde cualquiera de los dos viewControllers, rellenamos los labels y definimos la imagen.
        artistaLabel.text = album.artista
        tituloLabel.text = album.titulo
        yearLabel.text = album.year
        albumImageView.image = album.image
        
        //Si venismos desde AlbumListViewController, el botón debe ocultarse para no duplicar datos
        if(showButton == false){
            GuardarBtn.isHidden = true
            sortTracks() //Además, la base de datos guarda las pistas en un orden aleatorio, de modo que hay que ordenarlas.
        }
        
        
    }
    
    //Llamada solo si venimos desde AlbumListViewController
    func sortTracks(){
        
        var tracks2: [Track] = [] //Creamos un array de objetos tipo Track
        
        for _ in tracks{
            tracks2.append(tracks.popFirst()!) //Y lo rellenamos con el contenido de  tracks: Set<Track>
                                            //a efectos prácticos estamos casteando de Set<Track> a NSArray<Track>
        }
        
        //Ordenamos la lista mediante el método sorted y "track_number" que es un NSNumber.
        tracks2 = tracks2.sorted(by: {($0.track_number?.compare($1.track_number!) == .orderedAscending)})
       
        //Recorremos el array por índices
        for i in 0...tracks2.count-1{
            album.setTrackList(titulo: "\(tracks2[i].track_number!). \(tracks2[i].track_title!)", duracion: tracks2[i].track_duration!) //Y definimos el diccionario pasándole el título (con número de pista antepuesto) y su duración para cada pista del álbum.
        }
        trackTableView.reloadData() //Recargamos la tabla al terminar.
        }
    
    
    //Comprueba el estado de la descarga de la lista de canciones, solo se llama si venimos desde ResultsViewController
    @objc func checkDownload(){
        if(DataFetcher.dataFetcher.trackDone == true){

            timer.invalidate()
            trackTableView.reloadData()
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) { //Si se pulsa el botón guardar...
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // Obtenemos el contexto
        let managedContext =
            appDelegate.persistentContainer.viewContext


        
        // Declaramos las entidades (las tablas en la base de datos)
        let entity = NSEntityDescription.entity(forEntityName: "Album", in: managedContext)!
        let entity2 = NSEntityDescription.entity(forEntityName: "Track", in: managedContext)!


        //Y obtenemos una instancia para la tabla de Album.
        let tmpAlbum = Album(entity: entity, insertInto: managedContext)

        
        // 3
        tmpAlbum.title = self.album.titulo  //Le asignamos el título
        tmpAlbum.artist = self.album.artista  //Artista
        tmpAlbum.year = self.album.year   //Año de lanzamiento
        tmpAlbum.id = self.album.id      //Id

        //Para guardar la imagen en la base de datos hace falta convertirla a NSData
        let imageAsNSData = UIImageJPEGRepresentation(self.album.image, 1.0)
        tmpAlbum.image = imageAsNSData as NSData?  //Y la guardamos.
        
        //Para cada pista en la lista de canciones
        for i in 0...album.trackList.count-1{
            let track = Track(entity: entity2, insertInto: managedContext)  //Obtenemos una instancia para la tabla de Track
            track.track_title = album.trackList[i]["titulo"]  //Le asignamos titulo de cancion
            track.track_duration = album.trackList[i]["duracion"] //Duracion
            track.track_number = i + 1 as NSNumber  //Numero de pista como NSNumber
            track.album = tmpAlbum  //Y decimos que esta pista pertenece al album que acabamos de crear.
        }
        
        do {

            try managedContext.save() //Guardamos
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")  //A menos que haya un error
        }
        navigationController?.popToRootViewController(animated: true) //Volvemos a la primera pantalla
    }
}


//TABLEVIEW
extension AlbumDetailViewController: UITableViewDataSource, UITableViewDelegate{
    
    //Definimos el número de filas del tableView, tantas como pistas hayan.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return album.trackList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = album.trackList[indexPath.row] //Definimos la fuente del contenido de la celda
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") as! DetailTableViewCell //Definimos la celda
        
        if (indexPath.row % 2 == 0){ //Si es par, gris claro de fondo
            cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
            
        }else{ //Si no, blanco.
            cell.backgroundColor = UIColor.white
        }
        
        //Llenamos los campos de la celda.
        cell.trackNameLabel.text = track["titulo"]
        cell.trackDurationLabel.text = track["duracion"]
        return cell
    }
    
}
