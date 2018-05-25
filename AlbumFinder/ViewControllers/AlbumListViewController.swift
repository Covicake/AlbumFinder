//
//  ViewController.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 9/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.

//App Icon made by https://www.flaticon.com/authors/prosymbols" from https://www.flaticon.com/
//

import UIKit
import CoreData

/*En este ViewController veremos una lista con los álbumes que estén guardados en la base de datos. Si los pulsamos,
la aplicación nos lleva a los detalles del álbum pulsado. Si pulsamos "buscar" vamos a SearchViewController*/

class AlbumListViewController: UIViewController {

    @IBOutlet weak var albumTableView: UITableView!  //Outlet del TableView.
    
    
    var albumes: [Album] = []  //Un array de objetos tipo "Album" (Los almacenados en la base de datos)
    var selectedAlbumIndex: Int! //El índice de la fila que el usuario elige en el tableView.
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()  //Cargamos datos desde la base de datos, si existen.
    }
    
    func loadData(){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
        
        
        do {
            albumes = try managedContext.fetch(fetchRequest)
                
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        


        albumTableView.reloadData()  //Una vez finalizada la carga de datos, actualizamos el tableView.
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Definimos el delegado y la fuente de datos. En este caso, es el propio viewController.
        albumTableView.dataSource = self
        albumTableView.delegate = self
        
        
    }
    
    //Utilizamos el segue para enviar información a la siguiente pantalla, que nos mostrará los detalles del álbum que haya elegido el usuario en el tableView.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailFromListSegue") {
            if let destinationVC = segue.destination as? AlbumDetailViewController {
                
                //Define un álbum del tipo "DownloadedAlbum" con los datos que tiene el objeto "Album" del tableView.
                let album: DownloadedAlbum = DownloadedAlbum(titulo: albumes[selectedAlbumIndex].title!, artista: albumes[selectedAlbumIndex].artist!, year: albumes[selectedAlbumIndex].year!, image: albumes[selectedAlbumIndex].image!, id: albumes[selectedAlbumIndex].id!)
                
                
                let tracks = albumes[selectedAlbumIndex].tracks //Recoge un array de tipo Track correspondiente al álbum elegido

                destinationVC.tracks = tracks  //Envia el array de pistas
                destinationVC.album = album  //Envia el album: DownloadedAlbum
            }
        }
    }

}


//En esta extensión definimos el tableView.
extension AlbumListViewController: UITableViewDataSource, UITableViewDelegate{
    
    //Si el usuario pulsa sobre un álbum, la aplicación va a AlbumDetailViewController y envía los datos necesarios.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAlbumIndex = indexPath.row
        performSegue(withIdentifier: "detailFromListSegue", sender: self)
    }
    
    //Dice al TableView cuántas filas hay.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumes.count
    }
    
    //Define el contenido de cada fila utilizando la celda personalizada "AlbumListCell"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = albumes[indexPath.row] //Obtenemos el objeto Album a partir del array de álbumes.
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell") as! AlbumListCell //Declaramos nuestra celda personalizada
        
        if (indexPath.row % 2 == 0){ //Si la clelda es par, la ponemos de color gris claro
            cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
            
        }else{ //Si no, blanca.
            cell.backgroundColor = UIColor.white
        }
        
        //Damos información a la celda para rellenar todos sus campos
        cell.artistLabel.text = album.artist
        cell.titleLabel.text = album.title
        cell.yearLabel.text = album.year
        cell.cellimageView.image = UIImage(data: album.image! as Data)
        return cell
        
    }
    
    //Permite eliminar la celda con un swipe y recarga la tabla y la base de datos.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if editingStyle == .delete{
            let album = albumes[indexPath.row]
            context.delete(album)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()

        }
        
        loadData()
        albumTableView.reloadData()
    }
    
}

