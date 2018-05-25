//
//  SearchViewController.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 9/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//

import UIKit

//SearchViewController pide al usuario que escriba el nombre del artista y/o titulo del album y/o año de lanzamiento del mismo. Además tiene un botón para realizar la búsqueda una vez esos datos estén introducidos (comprobando que al menos uno de ellos no esté vacío) y otro botón para escanear el código de barras de un álbum.

class SearchViewController: UIViewController {

    
    @IBOutlet weak var mensajeLabel: UILabel!
    
    @IBOutlet weak var artistaLabel: UITextField!
    
    @IBOutlet weak var tituloLabel: UITextField!
    
    @IBOutlet weak var añoLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func BuscarBtn(_ sender: UIButton) { //Si el usuario pulsa el botón "Buscar"
        
            //Comprobamos que al menos uno de los campos contengan texto.
        if((artistaLabel.text == "") && (tituloLabel.text == "") && (añoLabel.text == "")){
            mensajeLabel.text = "Debe rellenar al menos un campo" //Si no es así, muestra un mensaje.
        }else{
            performSegue(withIdentifier: "resultSegue", sender: self) //Si hay algún campo con texto, realizamos la búsqueda en la siguiente pantalla. "ResultsViewController" enviandole el contenido de todos los campos.
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "resultSegue") {
            if let destinationVC = segue.destination as? ResultsViewController {
                destinationVC.artista = DataFetcher.dataFetcher.correctorCaracteresEspeciales(cadena: self.artistaLabel.text!)
                destinationVC.titulo = DataFetcher.dataFetcher.correctorCaracteresEspeciales(cadena: self.tituloLabel.text!)
                destinationVC.año = self.añoLabel.text!
            }
        }
        
    }
}
