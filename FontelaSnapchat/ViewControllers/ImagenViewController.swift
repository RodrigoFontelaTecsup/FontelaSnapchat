//
//  ImagenViewController.swift
//  FontelaSnapchat
//
//  Created by Rodrigo Fontela on 14/11/23.
//

import UIKit
import FirebaseStorage
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    
    var grabarAudio:AVAudioRecorder?
    
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    @IBOutlet weak var grabarButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        configurarGrabacion()
    }
    
    @IBAction func mediaTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData = ImageView.image?.jpegData(compressionQuality: 0.50)
        let cargarImagen = imagenesFolder.child("\(imagenID).jgp")
        cargarImagen.putData(imagenData!, metadata: nil) { (metadata, error) in
            if error != nil {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo um error al subir la imagen. Verifique su conexion a internet y vuelva a intentarlo", accion: "Aceptar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrio un error al subir imagen: \(error)")
                return
            } else {
                cargarImagen.downloadURL (completion: { (url, error) in
                    guard let enlaceURL = url else {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se prudujo un error al obtener informacion de imagen", accion: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                        print("Ocurrio un error al obtner informacion de Imagen \(error)")
                        return
                    }
                    self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: url?.absoluteString)
                })
            }
        }
        /*
        let alertaCarga = UIAlertController(title: "Cargando imagen...", message: "0%", preferredStyle: .alert)
        let progresoCarga: UIProgressView = UIProgressView(progressViewStyle: .default)
        cargarImagen.observe(.progress) {   (snapshot) in
            let porcentaje = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print(porcentaje)
            progresoCarga.setProgress(Float(porcentaje), animated: true)
            progresoCarga.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
            alertaCarga.message = String(round(porcentaje*100.0)) + " %"
            if porcentaje >= 1.0 {
                alertaCarga.dismiss(animated: true, completion: nil)
            }
        }
        let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alertaCarga.addAction(btnOK)
        alertaCarga.view.addSubview(progresoCarga)
        present(alertaCarga, animated: true, completion: nil)
        */
    }
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
                grabarAudio?.stop()
                grabarButton.setTitle("GRABAR", for: .normal)

                // Subir el archivo de audio a Firebase
                guard let audioURL = grabarAudio?.url else {
                    // Manejar el caso en que la URL del audio no esté disponible
                    return
                }

                let audiosFolder = Storage.storage().reference().child("audios")
                let audioData = try? Data(contentsOf: audioURL)
            let cargarAudio = audiosFolder.child("\(NSUUID().uuidString).m4a")

                cargarAudio.putData(audioData!, metadata: nil) { (metadata, error) in
                    if error != nil {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir el audio. Verifique su conexión a internet y vuelva a intentarlo", accion: "Aceptar")
                        print("Ocurrió un error al subir el audio: \(error)")
                        return
                    } else {
                        cargarAudio.downloadURL(completion: { (url, error) in
                            guard let enlaceURL = url else {
                                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información del audio", accion: "Cancelar")
                                print("Ocurrió un error al obtener información del audio \(error)")
                                return
                            }
                            // Puedes hacer algo con la URL del audio en Firebase, como almacenarla en tu base de datos
                            print("URL del audio en Firebase: \(enlaceURL.absoluteString)")
                        })
                    }
                }
            } else {
                grabarAudio?.record()
                grabarButton.setTitle("DETENER", for: .normal)
            }
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        ImageView.image = image
        ImageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let siguienteVC = segue.destination as! ElegirUsuarioViewController
        siguienteVC.imagenURL = sender as! String
        siguienteVC.descrip = descripcionTextField.text!
        siguienteVC.imagenID = imagenID
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnCANCELOK)
        present(alerta, animated: true, completion: nil)
    }
    
    func configurarGrabacion() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            let audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("********************")
            print(audioURL)
            print("********************")
            
            var settings : [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
     }
}
