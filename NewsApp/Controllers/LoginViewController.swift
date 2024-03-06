//
//  LoginViewController.swift
//  NewsApp
//
//  Created by Ziyomukhammad Usmonov on 04/03/2024.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "your_logo_image_name")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var usersList: [Users] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        checkIsLogged()
        layout()
        getUsers()
        
        configureMockedUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func configureView() {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
    }
    
    private func checkIsLogged() {
        let username = UserDefaults.standard.value(forKey: "username") as? String ?? ""
        if username != "" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func layout() {
        view.addSubview(logoImageView)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            emailTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 80),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 50),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            loginButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    func getUsers() -> Void {
        do {
            usersList = try context.fetch(Users.fetchRequest())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func configureMockedUsers() {
        if self.usersList.count == 0 {
            self.addUsers(email: "usera", password: "passworda")
            self.addUsers(email: "userb", password: "passwordb")
            self.getUsers()
        }
    }
    
    private func addUsers(email: String, password: String) -> Void {
        let user1 = Users(context: self.context)
        user1.email = email
        user1.password = password
        
        do {
            try context.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc private func loginButtonTapped() {
        var isFound = false
        if emailTextField.text == "" {
            self.showAlert(str: "Please enter username")
            return
        } else if passwordTextField.text == "" {
            self.showAlert(str: "Please enter password")
            return
        } else {
            for user in usersList {
                if user.email == emailTextField.text &&
                    user.password == passwordTextField.text {
                    isFound = true
                    break
                }
            }
        }
        
        if isFound {
            UserDefaults.standard.setValue(emailTextField.text!, forKey: "username")
            UserDefaults.standard.synchronize()
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showAlert(str: "Invalid email or password")
        }
    }
    
    private func showAlert(str: String) -> Void {
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
