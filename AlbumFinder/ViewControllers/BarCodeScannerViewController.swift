//
//  BarCodeScannerViewController.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 16/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//


/* En este ViewController se utiliza la cámara principal del iPhone para leer códigos de barras.
    He desarrollado la aplicación utilizando el simulador porque no tengo acceso a un dispositivo físico
    de modo que no he podido probar el funcionamiento de esta parte, pero he leído la documentación de apple y pienso que debería funcionar, pero si no funciona es porque no he podido hacer pruebas para corregir los posibles errores. Gracias por su comprensión */
import UIKit
import AVFoundation

class BarCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate  {
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var barcode: String!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            //Al iniciar la vista, comprobamos que esté capturando video. En caso contrario, lo iniciamos.
        if (captureSession?.isRunning == false) {
            captureSession?.startRunning()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("No se encontró una cámara en el dispositivo.")
            navigationController?.popToRootViewController(animated: true)
            return
        }
        
        do {
            //Obtenemos una instancia de AVCaptureDeviceInput usando el dispositivo elegido
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Añadimos el dispositivo de entrada a la sesión.
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            //Definimos el delegado e indicamos el hilo en el que debe trabajar.
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]  //Indicamos el tipo de código de barras que estamos leyendo. EAN-13.
            
            
            //Finalmente enseñamos el video que captura la cámara al usuario.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            //iniciamos la sesion.
            captureSession?.startRunning()
            
        } catch {
            print("No es posible inciar la sesion de captura")
            navigationController?.popToRootViewController(animated: true)

            return
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Cuando se detecta algún objeto, obtenemos el primer elemento.
        
        if let barcodeData = metadataObjects.first {
            
            // lo convertimos en AVMetadataMachineReadableCodeObject
            
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;
            
            
            if let readableCode = barcodeReadable {
                
                //Llamamos al método barcodeDetected y le enviamos el código detectado.
                
                barcodeDetected(code: readableCode.stringValue!);
            }
            
            // Una pequeña vibración para indicar al usuario que hemos detectado un código de barras.
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Cerramos la sesión (lo cuál hace que el teléfono deje de vibrar).
            
            captureSession?.stopRunning()
        }
    }
    
    func barcodeDetected(code: String) {
        
            //Eliminamos los espacios en blanco.
        let codigoSinEspacios = code.trimmingCharacters(in: (NSCharacterSet.whitespaces))
            
            // Apple detecta los códigos EAN y UPC, los UPC los convierte a EAN poniéndole un 0 delante lo cual puede ser problemático para la API.
            // Comprobamos si el primer caracter es un 0.
            
        let codigoSinEspaciosString = "\(codigoSinEspacios)"
        var codigoSinCero: String
        
        
        //Si tiene un cero como primer caracter.
        if codigoSinEspaciosString.hasPrefix("0") && codigoSinEspaciosString.count > 1 {
            codigoSinCero = String(codigoSinEspaciosString.dropFirst())  //Lo eliminamos
                
            barcode = codigoSinCero
                
        } else {
            
            barcode = codigoSinEspaciosString
        }
        
        
    }    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "resultsFromBarcodeSegue") {
            if let destinationVC = segue.destination as? ResultsViewController {
                destinationVC.barcode = self.barcode
            }
        }
    }

}
