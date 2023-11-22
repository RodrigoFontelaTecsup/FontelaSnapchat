//
//  VerSnapViewController.swift
//  FontelaSnapchat
//
//  Created by Rodrigo Fontela on 21/11/23.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseStorage
import AVFoundation

class VerSnapViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblMensaje: UILabel!
    
    
    var snap = Snap()
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMensaje.text = "Mensaje: " + snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagenURL), completed: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        
        Storage.storage().reference().child("imagenes").child("\(snap.imagenID).jpg").delete
        {   (error) in
            print("Se elimino la imagen correctamente")
        }
    }
}
