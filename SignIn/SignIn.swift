import UIKit
import SnapKit
import KeychainSwift
import FirebaseAuth

class SignIn: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign In"
        label.font = .boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email:"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let userTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .done
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.paddingLeft(12) // Custom method to add padding (optional)
        return textField
    }()

    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password:"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let passTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.paddingLeft(12) // Custom method to add padding (optional)
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create New Account!", for: .normal)
        return button
    }()

    private let forgetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        return button
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private var bottomConstraint = NSLayoutConstraint()

    private let keychain = KeychainSwift()
    private let tapGesture = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTextField.delegate = self
        passTextField.delegate = self
        userTextField.delegate = self
        passTextField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(tapGestureAction))
        
        setupViews()
        setupConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        setUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    func setUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Background colors
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
        contentView.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
        titleLabel.textColor = isDarkMode ? .white : .black
        // Button colors
        forgetButton.tintColor = isDarkMode ? .white : .black
        registerButton.tintColor = isDarkMode ? .white : .black
        loginButton.backgroundColor = isDarkMode ? UIColor(red: 0.2, green: 0.5, blue: 0.4, alpha: 1) : UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        loginButton.setTitleColor(isDarkMode ? .white : .white, for: .normal)  // Assuming you want the text color to remain white in both modes

        // Text field styles
        passTextField.layer.borderColor = isDarkMode ? UIColor.lightGray.cgColor : UIColor.gray.cgColor
        let passPlaceholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isDarkMode ? UIColor.lightGray : UIColor.gray
        ]
        let passAttributedPlaceholder = NSAttributedString(string: "Enter your password", attributes: passPlaceholderAttributes)
        passTextField.attributedPlaceholder = passAttributedPlaceholder
        passTextField.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
        passTextField.textColor = isDarkMode ? .white : .black
        passwordLabel.textColor = isDarkMode ? .white : .black

        userTextField.layer.borderColor = isDarkMode ? UIColor.lightGray.cgColor : UIColor.gray.cgColor
        let userPlaceholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isDarkMode ? UIColor.lightGray : UIColor.gray
        ]
        let userAttributedPlaceholder = NSAttributedString(string: "Enter your email address", attributes: userPlaceholderAttributes)
        userTextField.attributedPlaceholder = userAttributedPlaceholder
        userTextField.textColor = isDarkMode ? .white : .black
        userTextField.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
        emailLabel.textColor = isDarkMode ? .white : .black

        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor.black]
        appearance.shadowColor = isDarkMode ? UIColor.clear : UIColor.black.withAlphaComponent(0.2)  // Slight shadow for light mode

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = isDarkMode ? UIColor.white : UIColor.black
    }

    private func setupViews() {
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill

        // Add arranged subviews to stack view
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(userTextField)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(passTextField)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(forgetButton)
        stackView.addArrangedSubview(registerButton)

        // Add stack view to content view
        contentView.addSubview(stackView)
        
        // Add target actions to buttons
        loginButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonAction), for: .touchUpInside)
        forgetButton.addTarget(self, action: #selector(forgetButtonAction), for: .touchUpInside)
    }

    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        bottomConstraint = NSLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            bottomConstraint
        ])
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }

        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(150)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.width.equalTo(contentView).offset(-40)
            make.bottom.equalTo(contentView).inset(20)
        }

        // Set heights for individual components
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        emailLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        userTextField.snp.makeConstraints { make in
            make.height.equalTo(44) // Ensure a stable height for the text field
        }
        passwordLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        passTextField.snp.makeConstraints { make in
            make.height.equalTo(44) // Ensure a stable height for the text field
        }
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        forgetButton.snp.makeConstraints { make in
            make.height.equalTo(25)
        }
        registerButton.snp.makeConstraints { make in
            make.height.equalTo(25)
        }
    }

    @objc private func loginButtonAction() {
        guard let user = userTextField.text,
              let pass = passTextField.text else {
            return
        }
        
        keychain.set(user, forKey: "Username")
        
        Auth.auth().signIn(withEmail: user, password: pass) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert(message: "Error: \(error.localizedDescription)")
                return
            }
            self?.navigateToTabBar()
        }
    }

    private func navigateToTabBar() {
        let tabBar = TabBar()
        tabBar.modalTransitionStyle = .crossDissolve
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }

    @objc private func registerButtonAction() {
        let viewController = CreateAccount()
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }

    @objc private func forgetButtonAction() {
        let viewController = PasswordResetViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func tapGestureAction() {
        view.endEditing(true)
    }
    
    @objc private func showKeyboard(notification: Notification) {
        guard let size = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        bottomConstraint.constant = size.height
        view.layoutIfNeeded()
    }
    
    @objc private func hideKeyboard() {
        bottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
}

extension SignIn: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userTextField {
            passTextField.becomeFirstResponder()
        } else {
            passTextField.resignFirstResponder()
        }
        return true
    }
}
