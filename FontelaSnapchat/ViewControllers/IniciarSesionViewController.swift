import UIKit
import FirebaseAuth
import FirebaseDatabase

class IniciarSesionViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func IniciarSesionTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            mostrarAlerta(mensaje: "Por favor, ingresa un correo electrónico y contraseña válidos.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                print("Intentando iniciar sesión")
                if let error = error {
                    print("Se presentó el siguiente error: \(error)")
                    
                    // Mostrar la alerta para crear un nuevo usuario
                    self.mostrarAlertaCrearUsuario()
                } else {
                    print("Inicio de sesión exitoso")
                    self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                }
            }
    }

    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Alerta", message: mensaje, preferredStyle: .alert)
        let btnAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alerta.addAction(btnAceptar)
        present(alerta, animated: true, completion: nil)
    }

    func mostrarAlertaCrearUsuario() {
        let alerta = UIAlertController(title: "Error de inicio de sesión", message: "Usuario no encontrado. ¿Desea crear un nuevo usuario?", preferredStyle: .alert)

        let btnCrear = UIAlertAction(title: "Crear", style: .default) { (UIAlertAction) in
            self.performSegue(withIdentifier: "crearUsuarioSegue", sender: nil)
        }

        let btnCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)

        alerta.addAction(btnCrear)
        alerta.addAction(btnCancelar)

        present(alerta, animated: true, completion: nil)
    }
}
