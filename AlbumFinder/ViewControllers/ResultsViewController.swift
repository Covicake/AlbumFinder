//
//  ResultsViewController.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 12/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//

import UIKit


    /* ResultsViewController puede llamarse desde "SearchViewController" o desde "BarCodeScannerViewController"
        de modo que al iniciar la vista, diferenciamos la procedencia mediante los datos obtenidos. Es decir, si venimos desde "SearchViewController" debemos tener un artista, título o año y ningún "barcode", en cambio si venimos desde "BarCodeScannerViewController" tendremos un barcode y ninguno de los otros tres.
 
    ResultsViewController se encarga de descargar y enseñar en un TableView los resultados de la consulta a Discogs y de controlar qué página de los resultados estamos viendo y permitirnos navegar entre ellas.
 
 Aprovecho para describir el comportamiento de las páginas:
    Al entrar en la vista se descarga la primera página de los resultados, una vez finalizada la descarga, se descarga la página siguiente. Mientras la página siguiente se está descargando, el usuario no puede pulsar el botón "pág+" que lo llevaría. Una vez finalizada la descarga, el botón se habilita. Si el usuario va a la segunda página, comienza a descargarse la tercera y la primera se guarda en "albumes_pagina_anterior"
    Si el usuario está en una página superior a la primera, el botón "pág-" aparece en la vista. Si el usuario vuelve a la primera página, el botón desaparece. Con el botón "pág+" sucede algo similar, pero respecto a la página final.
 
    Si el usuario está en la página 3, por ejemplo, tendremos los resultados de la página 4 en "albumes_pagina_siguiente" y los de la página 2 en "albumes_pagina_anterior". Si el usuario retrocede una página, entonces "albumes_actual" toma el valor de "albumes_pagina_anterior". "albumes_pagina_anterior" descarga la página 1. Y "albumes_pagina_siguiente" toma el antiguo valor de "pagina_actual".
 
    De este modo, cuando el usuario termina de leer los resultados de una página, ya tiene la siguiente y la anterior descargadas y puede navegar sin retraso. Sigue teniendo que esperar un poco si desea avanzar dos páginas seguidas, por ejemplo.
 
        */

class ResultsViewController: UIViewController {
    
    
    var albumes_pagina_anterior: [DownloadedAlbum] = []  //Almacena resultados de la página anterior a la actual
    var albumes_actual: [DownloadedAlbum] = []          //Almacena resultados de la página actual.
    var albumes_pagina_siguiente: [DownloadedAlbum] = [] //Almacena resultados de la siguiente página.
    
    var selectedAlbumIndex: Int = 0 //Al igual que en AlbumListViewController, guarda el índice de la fila seleccionada por el usuario
    var artista: String = ""  //Artista del álbum, se recibe de SearchViewController
    var titulo: String = ""  //Titulo del album, se recibe de SearchViewController
    var año: String = ""  //Año de lanzamiento del album, se recibe de SearchViewController
    var paginaActual: Int = 1 //Indica en qué página estamos actualmente.
    var barcode: String = "" //Código de barras del álbum, se recibe de "BarCodeScannerViewController"
    
    //Tres timers que utilizaremos para comprobar el estado de la descarga de:
    var timer: Timer!  //album_actual e imágenes
    var timer2: Timer! //album_pagina_siguiente
    var timer3: Timer! //album_pagina_anterior

    
    //Outlets.
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var siguientePaginaBtn: UIButton!
    @IBOutlet weak var anteriorPaginaBtn: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        //Lo primero que hace el ViewController es comprobar si hemos recibido un código de barras.
        
        if(barcode != ""){
            DataFetcher.dataFetcher.FetchDataFromURL(artista: "", titulo: "", año: "", pagina: "", barcode: self.barcode) //Si es así, realizamos la búsqueda solo con ese parámetro pues es más que suficiente.
        }else{
            DataFetcher.dataFetcher.FetchDataFromURL(artista: self.artista, titulo: self.titulo, año: self.año, pagina: String(self.paginaActual), barcode: self.barcode)
            //En caso contrario, realizamos la búsqueda con lo que haya escrito el usuario.
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Define el dataSource y delegate del TableView.
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        
            //Este Timer ejecuta periodicamente una función que comprueba si ya se han descargado los datos o no para poder mostrarlos en el UITableView.
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkDownload), userInfo: nil, repeats: true)
    }
    
    
    //Esta función sirve para ordenar los resultados descargados antes de mostrarlos por pantalla.
    func sortResults(){
        var sortedAlbumes: [DownloadedAlbum] = [] //Crea un array en el que almacenaremos los datos temporalmente
        if (artista != ""){
            
            
            for album in albumes_actual{  //Pone al principio los elementos que mejor se correspondan con "artista" si el usuario especificó alguno.
                if album.artista.lowercased().elementsEqual(artista.lowercased()){
                    sortedAlbumes.append(album)
                }
            }
            //Si existía algun resultado que se correspondiera con lo escrito por el usuario, ordenamos los álbumes de ese artista por fecha de lanzamiento.
            if(!sortedAlbumes.isEmpty){
                sortedAlbumes = sortedAlbumes.sorted(by: {($0.year < $1.year)})
            }
            
            for album in albumes_actual{
                //Añadimos el resto de álbumes sin ordenar.
                if !album.artista.lowercased().elementsEqual(artista.lowercased()){
                    sortedAlbumes.append(album)
                }
            }

            
        }else if(titulo != ""){
            for album in albumes_actual{  //Pone al principio los elementos que mejor se correspondan con "titulo" si el usuario especificó alguno.
                if album.titulo.lowercased().elementsEqual(titulo){
                    sortedAlbumes.append(album)
                }
            }
            for album in albumes_actual{
                if !album.titulo.lowercased().elementsEqual(titulo){ //El resto los pone después.
                    sortedAlbumes.append(album)
                }
            }
        }
        else{ //Si no hay ni título ni artista, no hay que ordenar nada.
            sortedAlbumes = albumes_actual
        }
        if(sortedAlbumes.isEmpty){ //Si no hay ningún resultado, cambiamos el título de la pantalla para notificar al usuario.
            self.title = "No hay ninguna coincidencia"
        }
        self.albumes_actual.removeAll() //Vaciamos el array
        self.albumes_actual = sortedAlbumes //Lo rellenamos con los datos ordenados
        resultsTableView.reloadData()  //Actualizamos la tabla.
    }
    
    //Comprueba periodicamente si todas las imágenes están descargadas hasta que lo estén.
    @objc func checkImageDownload(){
        var i: Int = 0      //Contador.
        for album in albumes_actual{
            if album.imageDownloaded == true{   //Recorremos el vector de álbumes y comprobamos si ya ha descargado su imagen
                i += 1                          // Si la ha descargado, sumamos uno al contador.
            }
        }
        
        //Si el número de álbumes con imagen descargada es igual que el número de álbumes,
        if i == self.albumes_actual.count{
            timer.invalidate()              //Detenemos el Timer.
        }
        resultsTableView.reloadData() //Cada vez que se ejecuta, recarga la tabla para mostrar las imágenes que se hayan descargado hasta el momento.
    }
    
    //Comprueba periódicamente si la siguiente página ya se descargó
    @objc func checkNextPageDownload(){
        
        if(DataFetcher.dataFetcher.done == true){ //Si ya se descargó
            timer2.invalidate() //Detiene el timer
            self.albumes_pagina_siguiente = DataFetcher.dataFetcher.albumes //Y carga los resultados en "albumes_pagina_siguiente"
            siguientePaginaBtn.isUserInteractionEnabled = true //Activa el botón para ir a la página siguiente
        }

    }
    
    
    //Igual que el anterior, pero para la página anterior a la actual.
    @objc func checkPreviousPageDownload(){
       
        if(DataFetcher.dataFetcher.done == true){
            timer3.invalidate()
            self.albumes_pagina_anterior = DataFetcher.dataFetcher.albumes
            anteriorPaginaBtn.isUserInteractionEnabled = true
        }

    }
    
    
    //Comprueba periódicamente que el resultado de la búsqueda ya se haya descargado
    @objc func checkDownload(){
        if(DataFetcher.dataFetcher.done == true){ //Si ya se descargó
            timer.invalidate()                   //Desactiva el timer.
            self.albumes_actual = DataFetcher.dataFetcher.albumes  // Recuperamos el resultado de la consulta
            sortResults()                                   // Método para ordenar los resultados antes de mostrarlos en pantalla.
            
                    //Creamos otro Timer para comprobar el estado de la descarga de las imágenes
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkImageDownload), userInfo: nil, repeats: true)
            
            if (DataFetcher.dataFetcher.pages > paginaActual){ //Si hay más de una página de resultados
                siguientePaginaBtn.isHidden = false           //Mostramos el botón para ir a la siguiente página.
                
                                                        //Creamos un timer para comprobar la descarga de la pagina siguiente
                timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkNextPageDownload), userInfo: nil, repeats: true)

                DataFetcher.dataFetcher.FetchDataFromURL(artista: self.artista, titulo: self.titulo, año: self.año, pagina: String(self.paginaActual+1), barcode: self.barcode) //E iniciamos su descarga
            }
        }
    }
    

    
    // MARK: - Navigation

    // Envía los datos del álbum elegido y descarga su lista de canciones para mostrarlos en AlbumDetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailFromResultSegue") {
            if let destinationVC = segue.destination as? AlbumDetailViewController {
                destinationVC.album = albumes_actual[selectedAlbumIndex]
                destinationVC.showButton = true //Enseña el botón de guardar álbum.
                DataFetcher.dataFetcher.FetchTrackList(album: destinationVC.album)
            }
        }
    }
    
    
    //Si pulsamos el botón "pág+"
    @IBAction func siguientePaginaBtn(_ sender: UIButton) {
        
        paginaActual += 1 //Avanzamos a la siguiente página
        albumes_pagina_anterior = albumes_actual //La página anterior será la que hasta ahora era la actual
        albumes_actual = albumes_pagina_siguiente //La página "actual" será la que hasta ahora era la siguiente.
        
        //Descargamos la página siguiente, si existe
        if (DataFetcher.dataFetcher.pages > paginaActual){
            siguientePaginaBtn.isUserInteractionEnabled = false //Desactivamos el botón temporalmente
            DataFetcher.dataFetcher.FetchDataFromURL(artista: self.artista, titulo: self.titulo, año: self.año, pagina: String(self.paginaActual+1), barcode: self.barcode) //Descargamos la página
            //Iniciamos el timer para comprobar su descarga
            timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkNextPageDownload), userInfo: nil, repeats: true)
        }else{ //Si no hay más páginas
            siguientePaginaBtn.isHidden = true  // Ocultamos el boton.
        }
        //Si la página anterior es como mínimo "1", mostramos el botón de volver a la página anterior
        if (paginaActual-1 > 0){
            anteriorPaginaBtn.isHidden = false
        }
        
        resultsTableView.reloadData() //Recargamos la tabla con los datos de la página siguiente a la que mostraba
        
    }
    
    //Si pulsamos el botón "pág-"
    @IBAction func anteriorPaginaBtn(_ sender: UIButton) {
        
        paginaActual -= 1 //Retrocedemos a la página anterior
        
        if (paginaActual == 1){ //Si la nueva página es la 1, escondemos el botón.
            anteriorPaginaBtn.isHidden = true
        }
        

        albumes_pagina_siguiente = albumes_actual //La página siguiente se convierte en la que era la actual
        albumes_actual = albumes_pagina_anterior //La página actual se convierte en la que era la anterior.
        
        
        if (paginaActual > 1){   //Si la página anterior (después de pulsar el botón) es mínimo la primera, la precargamos.
            //Descargamos la página anterior si existe
            DataFetcher.dataFetcher.FetchDataFromURL(artista: self.artista, titulo: self.titulo, año: self.año, pagina: String(self.paginaActual-1), barcode: self.barcode)
            anteriorPaginaBtn.isUserInteractionEnabled = false //Deshabilitamos el botón temporalmente
            //Iniciamos el timer que comprueba la descarga de la página
            timer3 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkPreviousPageDownload), userInfo: nil, repeats: true)
        }
        
        if (paginaActual < DataFetcher.dataFetcher.pages){ //Si la página actual no es la última
            siguientePaginaBtn.isHidden = false //El botón página siguiente seguirá en pantalla
        }
        
        resultsTableView.reloadData() //Recargamos la tabla con los nuevos datos.

        
    }
}


//TABLE VIEW
extension ResultsViewController: UITableViewDataSource, UITableViewDelegate{
    
    
    //Si el usuario pulsa en un álbum, obtenemos su índice y lo enviamos a ResultsViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedAlbumIndex = indexPath.row
        self.performSegue(withIdentifier: "detailFromResultSegue", sender: self)
    }
    
    //Definimos el número de filas que tendrá la tabla. Tantos como resultados haya (máximo 15)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumes_actual.count
    }
    
    //Definimos los datos de cada fila.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let album = albumes_actual[indexPath.row] //El album será un AlbumDownloaded almacenado en "albumes_actual"
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell") as! AlbumListCell //Definimos la celda
        
        if (indexPath.row % 2 == 0){ //Si es par, el fondo de la celda será gris claro
            cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
            
        }else{ //Si no, blanco.
            cell.backgroundColor = UIColor.white
        }
         //Rellenamos los datos de la celda con la información del álbum.
        cell.artistLabel.text = album.artista
        cell.titleLabel.text = album.titulo
        cell.yearLabel.text = album.year
        cell.cellimageView.image = album.image
        
        return cell
    }
    
}
