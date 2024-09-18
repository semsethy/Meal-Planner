import UIKit
import Firebase
import FirebaseAuth
import SnapKit

/// A view controller that handles user account creation and user interface for the sign-up process.
class CreateAccount: UIViewController {
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create New Account"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username:"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.paddingLeft(12)
        return textField
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email:"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.paddingLeft(12)
        return textField
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password:"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.paddingLeft(12)
        return textField
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(signUpButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(signInButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private var bottomConstraint = NSLayoutConstraint()
    
    private var isDarkMode: Bool {
        UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupKeyboardNotifications()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        setUIColor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    
    // MARK: - Private Methods
    
    /// Handles changes in the user interface style and updates colors accordingly.
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    
    /// Configures colors based on the current user interface style.
    func setUIColor() {
        // Background and text colors
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
        titleLabel.textColor = isDarkMode ? .white : .black
        usernameLabel.textColor = isDarkMode ? .white : .black
        usernameTextField.textColor = isDarkMode ? .white : .black
        emailLabel.textColor = isDarkMode ? .white : .black
        emailTextField.textColor = isDarkMode ? .white : .black
        passwordLabel.textColor = isDarkMode ? .white : .black
        passwordTextField.textColor = isDarkMode ? .white : .black

        // Placeholder colors
        let placeholderColor = isDarkMode ? UIColor.lightGray : UIColor.gray
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Enter your username", attributes: [.foregroundColor: placeholderColor])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your email address", attributes: [.foregroundColor: placeholderColor])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter your password", attributes: [.foregroundColor: placeholderColor])

        // Border colors
        let borderColor = isDarkMode ? UIColor.lightGray.cgColor : UIColor.gray.cgColor
        usernameTextField.layer.borderColor = borderColor
        emailTextField.layer.borderColor = borderColor
        passwordTextField.layer.borderColor = borderColor

        // Button colors
        signUpButton.backgroundColor = isDarkMode ? UIColor(red: 0.2, green: 0.5, blue: 0.4, alpha: 1) : UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        signUpButton.setTitleColor(.white, for: .normal)

        // Attributed string for sign in button
        let fullText = "Already have an account? Sign In"
        let attributedString = NSMutableAttributedString(string: fullText)
        let alreadyHaveAccountRange = (fullText as NSString).range(of: "Already have an account?")
        let signInRange = (fullText as NSString).range(of: "Sign In")
        attributedString.addAttribute(.foregroundColor, value: isDarkMode ? UIColor.lightGray : UIColor.black, range: alreadyHaveAccountRange)
        attributedString.addAttribute(.foregroundColor, value: isDarkMode ? UIColor(red: 0.4, green: 0.8, blue: 0.7, alpha: 1) : UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1), range: signInRange)
        signInButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    /// Sets up the user interface.
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(signUpButton)
        stackView.addArrangedSubview(signInButton)
        
        // Configure text fields
        [usernameTextField, emailTextField, passwordTextField].forEach {
            $0.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
            $0.layer.cornerRadius = 8
        }
    }
    
    /// Sets up constraints for UI elements.
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        bottomConstraint = NSLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint
        ])
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(200)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.width.equalTo(contentView).offset(-40)
            make.bottom.equalTo(contentView).inset(20)
        }

        // Set height for buttons and text fields
        [signUpButton, usernameTextField, emailTextField, passwordTextField].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
        }
        
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        usernameLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
        }
        emailLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
        }
        passwordLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
        }
    }
    
    /// Sets up keyboard notifications to adjust UI when the keyboard is shown or hidden.
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Action Methods
    
    /// Handles the sign-up button action.
    @objc private func signUpButtonAction() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter username, email, and password.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert(message: "Error creating user: \(error.localizedDescription)")
                return
            }
            
            // Navigate to TabBar
            let tabBar = TabBar()
            tabBar.modalTransitionStyle = .crossDissolve
            tabBar.modalPresentationStyle = .fullScreen
            self?.present(tabBar, animated: true)
            
            guard let userID = authResult?.user.uid else { return }
            self?.saveUsername(username, userID: userID)
        }
    }
    
    /// Saves the username to Firestore.
    private func saveUsername(_ username: String, userID: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(["username": username]) { error in
            if let error = error {
                print("Error saving username: \(error.localizedDescription)")
            }
        }
    }
    
    /// Handles the sign-in button action.
    @objc private func signInButtonAction() {
        let viewController = UINavigationController(rootViewController: SignIn())
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    /// Dismisses the keyboard when tapping outside the text fields.
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// Adjusts the bottom constraint of the scroll view when the keyboard is shown.
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        bottomConstraint.constant = keyboardFrame.height
        view.layoutIfNeeded()
    }
    
    /// Resets the bottom constraint of the scroll view when the keyboard is hidden.
    @objc private func keyboardWillHide(notification: Notification) {
        bottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    /// Shows an alert with a specified message.
    private func showAlert(message: String, isSuccess: Bool = false) {
        let alert = UIAlertController(title: isSuccess ? "Success" : "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension CreateAccount: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
