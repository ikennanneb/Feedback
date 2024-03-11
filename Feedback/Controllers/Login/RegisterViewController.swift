//
//  RegisterViewController.swift
//  Feedback
//
//  Created by Ikenna on 3/7/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    
    private let scrollView: UIScrollView =
    {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView =
    {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let firstNameField: UITextField =
    {
        let field = UITextField()
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "First Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameField: UITextField =
    {
        let field = UITextField()
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "Last Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField: UITextField =
    {
        let field = UITextField()
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "Email Address",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField =
    {
        let field = UITextField()
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = UIColor(named: "green1")
        button.layer.cornerRadius = 12
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Register"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        view.backgroundColor = .white
        
        loginButton.addTarget(self,
                              action: #selector(registerButtonTapped), for: .touchUpInside)
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        firstNameField.frame = CGRect(x: 30,
                                      y: 130,
                                      width: scrollView.width - 60,
                                      height: 52)
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom + 30,
                                  width: scrollView.width - 60,
                                  height: 52)
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom + 30,
                                  width: scrollView.width - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom + 30,
                                  width: scrollView.width - 60,
                                  height: 52)
        loginButton.frame = CGRect(x: 30,
                                  y: passwordField.bottom + 30,
                                  width: scrollView.width - 60,
                                  height: 52)
    }
    
    @objc private func registerButtonTapped()
    {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else
              {
                  alertUserLoginError()
                  return
              }
        
        // Firebase Register
        
        DatabaseManager.shared.userExists(with: email, completion: {[weak self] exists in
            guard let strongSelf = self else {return}
            
            guard !exists else
            {
                // User already exists
                strongSelf.alertUserLoginError(message: "Looks like a user account for that email address already exists.")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
                guard authResult != nil, error == nil else
                {
                    print("Error creating user")
                    return
                }
                
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "name")
                
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                
                let feedbackUser = FeedbackAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                
                DatabaseManager.shared.insertUser(with: feedbackUser, completion: {success in
                     if success
                    {
                         // Upload image
                         guard let image = strongSelf.imageView.image, let data = image.pngData() else
                         {
                             return
                         }
                         let fileName = feedbackUser.profilePictureFileName
                         StorageManager.shared.uploadProfilePicture(with: data,
                                                                    fileName: fileName,
                                                                    completion: { result in
                             switch result{
                             case .success(let downloadUrl):
                                 UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                 print(downloadUrl)
                             case .failure(let error):
                                 print("Storage manager error: \(error)")
                             }
                         })
                     }
                })
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)

            })
        })
        
    }
    
    func alertUserLoginError(message: String = "Please enter all information to log in")
    {
        let alert = UIAlertController(title: "Whoops", 
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", 
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
    }

}

extension RegisterViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool 
    {
        if textField == firstNameField
        {
            lastNameField.becomeFirstResponder()
        }
        if textField == lastNameField
        {
            emailField.becomeFirstResponder()
        }
        if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            registerButtonTapped()
        }
        
        return true
    }
}
