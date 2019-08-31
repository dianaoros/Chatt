//
//  LoginController.swift
//  Chatt
//
//  Created by Diana Oros on 7/17/19.
//  Copyright © 2019 Diana Oros. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UITextFieldDelegate {
    
    var messagesController: MessagesController?
    
    var inputsContainerViewHeightAnchor : NSLayoutConstraint?
    var firstNameLabelHeightAnchor : NSLayoutConstraint?
    var firstNameTextFieldHeightAnchor : NSLayoutConstraint?
    var lastNameLabelHeightAnchor : NSLayoutConstraint?
    var lastNameTextFieldHeightAnchor : NSLayoutConstraint?
    var emailLabelHeightAnchor : NSLayoutConstraint?
    var emailLabelTopAnchor : NSLayoutConstraint?
    var emailTextFieldHeightAnchor : NSLayoutConstraint?
    var passwordLabelHeightAnchor : NSLayoutConstraint?
    var passwordTextFieldHeightAnchor : NSLayoutConstraint?
    var firstNameSeparatorViewHeightAnchor : NSLayoutConstraint?
    var lastNameSeparatorViewHeightConstraint : NSLayoutConstraint?
    
    lazy var logoImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "signup_camera")
        imageView.contentMode = UIImageView.ContentMode.scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImageWhenSigningUp)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var loginRegisterSegmentedControl : UISegmentedControl = {
        let control = UISegmentedControl(items: ["Login", "Signup"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        control.tintColor = UIColor.white
        let font = UIFont.systemFont(ofSize: 18)
        control.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        control.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return control
    }()
    
    let inputsContainerView : UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor.black
        view.backgroundColor = UIColor(red: 163/255, green: 22/255, blue: 92/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let firstNameLabel : UILabel = {
        let label = UILabel()
        label.text = "What is your first name?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = UIColor.green
        return label
    }()
    
    let firstNameTextField : UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.textColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = UITextAutocorrectionType.no
//        textField.backgroundColor = UIColor.red
        return textField
    }()
    
    let firstNameSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let lastNameLabel : UILabel = {
        let label = UILabel()
        label.text = "Your last name?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = UIColor.green
        return label
    }()
    
    let lastNameTextField : UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.textColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = UITextAutocorrectionType.no
//        textField.backgroundColor = UIColor.red
        return textField
    }()
    
    let lastNameSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailLabel : UILabel = {
        let label = UILabel()
        label.text = "What is your email?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = UIColor.green
        return label
    }()
    
    let emailTextField : UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.textColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.emailAddress
        textField.autocorrectionType = UITextAutocorrectionType.no
//        textField.backgroundColor = UIColor.red
        return textField
    }()
    
    let emailSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var passwordLabel : UILabel = {
        let label = UILabel()
        label.text = "Create your password"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = UIColor.green
        return label
    }()
    
    let passwordTextField : UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.textColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        textField.autocorrectionType = UITextAutocorrectionType.no
//        textField.backgroundColor = UIColor.red
        return textField
    }()
    
    let passwordSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var loginRegisterButton : UIButton = {
        let button = UIButton()
        button.setTitle("Signup", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 163/255, green: 22/255, blue: 92/255, alpha: 1)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(logoImageView)
        view.addSubview(loginRegisterSegmentedControl)
        setupInputsContainerViewConstraints()
        setupLoginRegisterButtonConstraints()
        setupLogoImageViewConstraints()
        setupLoginRegisterSegmentedControlConstraints()
        
        passwordTextField.delegate = self
        textFieldShouldReturn(passwordTextField)
//        DispatchQueue.main.async {
//            self.firstNameTextField.becomeFirstResponder()
//        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupLogoImageViewConstraints() {
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupLoginRegisterSegmentedControlConstraints() {
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupInputsContainerViewConstraints() {
        
        // Containter x, y, width, height Constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 360)
        inputsContainerViewHeightAnchor?.isActive = true
        
        // Add the subviews of the container to the container
        inputsContainerView.addSubview(firstNameLabel)
        inputsContainerView.addSubview(firstNameTextField)
        inputsContainerView.addSubview(firstNameSeparatorView)
        inputsContainerView.addSubview(lastNameLabel)
        inputsContainerView.addSubview(lastNameTextField)
        inputsContainerView.addSubview(lastNameSeparatorView)
        inputsContainerView.addSubview(emailLabel)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordLabel)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeparatorView)
        
        // firstNameLabel x y width height Constraints
        firstNameLabel.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        firstNameLabel.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        firstNameLabel.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        firstNameLabelHeightAnchor = firstNameLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/8)
        firstNameLabelHeightAnchor?.isActive = true
        
        // firstNameTextField x y width height Constraints
        firstNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        firstNameTextField.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        firstNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        firstNameTextFieldHeightAnchor = firstNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/8, constant: -10)
        firstNameTextFieldHeightAnchor?.isActive = true
        
        // firstNameSeparatorView x y width height Constraints
        firstNameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        firstNameSeparatorView.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor).isActive = true
        firstNameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        firstNameSeparatorViewHeightAnchor = firstNameSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        firstNameSeparatorViewHeightAnchor?.isActive = true
        
        // lastNameLabel x y width height Constraints
        lastNameLabel.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        lastNameLabel.topAnchor.constraint(equalTo: firstNameSeparatorView.bottomAnchor, constant: 12).isActive = true
        lastNameLabel.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        lastNameLabelHeightAnchor = lastNameLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/8)
        lastNameLabelHeightAnchor?.isActive = true
        
        // lastNameTextField x y width height Constraints
        lastNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        lastNameTextField.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor).isActive = true
        lastNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        lastNameTextFieldHeightAnchor = lastNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/8, constant: -10)
        lastNameTextFieldHeightAnchor?.isActive = true
        
        // lastNameSeparatorView x y width height Constraints
        lastNameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        lastNameSeparatorView.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor).isActive = true
        lastNameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        lastNameSeparatorViewHeightConstraint = lastNameSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        lastNameSeparatorViewHeightConstraint?.isActive = true
        
        // emailLabel x y width height Constraints
        emailLabel.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailLabelTopAnchor = emailLabel.topAnchor.constraint(equalTo: lastNameSeparatorView.bottomAnchor, constant: 12)
        emailLabelTopAnchor?.isActive = true
        emailLabel.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailLabelHeightAnchor = emailLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/8)
        emailLabelHeightAnchor?.isActive = true
        
        // emailTextField x y width height Constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/8, constant: -10)
        emailTextFieldHeightAnchor?.isActive = true
        
        // emailSeparatorView x y width height Constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //passwordLabel x y width height Constraints
        passwordLabel.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordLabel.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor, constant: 12).isActive = true
        passwordLabel.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordLabelHeightAnchor = passwordLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/8)
        passwordLabelHeightAnchor?.isActive = true
        
        // passwordTextField x y width height Constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/8, constant: -10)
        passwordTextFieldHeightAnchor?.isActive = true
        
        // passwordSeparatorView x y width height Constraints
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func setupLoginRegisterButtonConstraints() {
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 24).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            passwordLabel.text = "Enter your password"
            logoImageView.image = UIImage(named: "logo")
            logoImageView.isUserInteractionEnabled = false
        } else {
            passwordLabel.text = "Create your password"
            logoImageView.image = UIImage(named: "signup_camera")
            logoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImageWhenSigningUp)))
            logoImageView.isUserInteractionEnabled = true
        }
        //change height of inputsContainerView depending if it's on log in (0 in array) or signup (1 in array)
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 180 : 360
        
        //change height of firstNameLabel
        firstNameLabelHeightAnchor?.isActive = false
        firstNameLabelHeightAnchor = firstNameLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/8)
        firstNameLabelHeightAnchor?.isActive = true
        
        //change height for firstNameTextField
        firstNameTextFieldHeightAnchor?.isActive = false
        firstNameTextFieldHeightAnchor = firstNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/8, constant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : -10)
        firstNameTextFieldHeightAnchor?.isActive = true
        
        //change height for firstNameSeparatorView
        firstNameSeparatorViewHeightAnchor?.isActive = false
        firstNameSeparatorViewHeightAnchor = firstNameSeparatorView.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1)
        firstNameSeparatorViewHeightAnchor?.isActive = true
        
        //change height for lastNameLabel
        lastNameLabelHeightAnchor?.isActive = false
        lastNameLabelHeightAnchor = lastNameLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/8)
        lastNameLabelHeightAnchor?.isActive = true
        
        //change height for lastNameTextField
        lastNameTextFieldHeightAnchor?.isActive = false
        lastNameTextFieldHeightAnchor = lastNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/8, constant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : -10)
        lastNameTextFieldHeightAnchor?.isActive = true
        
        //change height for lastNameSeparatorView
        lastNameSeparatorViewHeightConstraint?.isActive = false
        lastNameSeparatorViewHeightConstraint = lastNameSeparatorView.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1)
        lastNameSeparatorViewHeightConstraint?.isActive = true
        
        //change Top Anchor for emailLabel
        emailLabelTopAnchor?.isActive = false
        emailLabelTopAnchor = emailLabel.topAnchor.constraint(equalTo: lastNameSeparatorView.topAnchor, constant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? -12 : 12)
        emailLabelTopAnchor?.isActive = true
        
        //change height for emailLabel
        emailLabelHeightAnchor?.isActive = false
        emailLabelHeightAnchor = emailLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/4 : 1/8)
        emailLabelHeightAnchor?.isActive = true
        
        //change height for emailTextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/4 : 1/8, constant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? -10 : -10)
        emailTextFieldHeightAnchor?.isActive = true
        
        //change height for passwordLabel
        passwordLabelHeightAnchor?.isActive = false
        passwordLabelHeightAnchor = passwordLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/4 : 1/8)
        passwordLabelHeightAnchor?.isActive = true
        
        //change height for passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/4 : 1/8, constant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? -10 : -10)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let userEmail = emailTextField.text, let userPassword = passwordTextField.text else {
            print("Sign up fields are not valid")
            return
        }
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("Login succesful")
                self.messagesController?.retrieveUserAndSetupNavBarTitle()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
}

