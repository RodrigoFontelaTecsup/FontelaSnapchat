//
//  CrearUsuarioViewController.swift
//  FontelaSnapchat
//
//  Created by Rodrigo Fontela on 14/11/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseDatabase
import Firebase

class CrearUsuarioViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func registrarseTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            print("Intentando iniciar sesion")
            if error != nil{
                print("Se presento el siguiente error: \(error)")
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion:  { (user, error) in
                    print("Intentando crear un usuario")
                    if error != nil {
                        print("Se presento el siguiente error al crear el usuario: \(error)")
                    } else {
                        print("El usuario fue creado exitosamente")
                        Database.database().reference().child("usuarios").child(user!.user.uid).child("email").setValue(user!.user.email)
                            
                        let alerta = UIAlertController(title: "Creacion de usuario", message: "Usuario: \(self.emailTextField.text!) se creo correctamente", preferredStyle: .alert)
                        let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: { (UIAlerAction) in
                            self.performSegue(withIdentifier: "registroExitosoSegue", sender: nil)
                        })
                        alerta.addAction(btnOK)
                        self.present(alerta, animated: true, completion: nil)
                    }
                })
            } else {
                print("Inicio de sesion exitoso")
                self.performSegue(withIdentifier: "registroExitosoSegue", sender: nil)
            }
        }
    }
}
