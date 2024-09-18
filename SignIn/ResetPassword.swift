import UIKit
import FirebaseAuth
import SnapKit

/// A view controller that provides a user interface for resetting a password.
class PasswordResetViewController: UIViewController {

    // MARK: - UI Elements

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Your Email"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
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
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    private var bottomConstraint = NSLayoutConstraint()
    private let tapGesture = UITapGestureRecognizer()
    private var isDarkMode: Bool {
        UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
    }
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        configureNavigationBar()
        setupKeyboardNotifications()
        setUIColor()
        setupDelegates()
        
        resetButton.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(tapGestureAction))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    
    // MARK: - UI Setup

    private func setupUI() {
        // Add views to the hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(resetButton)
    }
    
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
            make.top.equalTo(contentView).offset(170)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.width.equalTo(contentView).offset(-40)
            make.bottom.equalTo(contentView).inset(20)
        }

        // Set height for elements
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
        }

        emailLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
        }

        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        resetButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }

    // MARK: - Color and Style Configuration

    private func setUIColor() {
        // Set background and text colors based on dark mode
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
        emailTextField.layer.borderColor = isDarkMode ? UIColor.lightGray.cgColor : UIColor.gray.cgColor
        emailTextField.textColor = isDarkMode ? .white : .black
        emailTextField.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
        emailLabel.textColor = isDarkMode ? .white : .black
        titleLabel.textColor = isDarkMode ? .white : .black

        // Set reset button color
        resetButton.backgroundColor = isDarkMode ? UIColor(red: 0.2, green: 0.5, blue: 0.4, alpha: 1) : UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        resetButton.setTitleColor(.white, for: .normal)

        // Set placeholder color
        let placeholderColor = isDarkMode ? UIColor.lightGray : UIColor.gray
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor
        ]
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your email address", attributes: placeholderAttributes)

        // Configure navigation bar appearance
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

    // MARK: - Navigation Bar

    private func configureNavigationBar() {
        self.title = "Change Password"
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    // MARK: - Keyboard Notifications

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func showKeyboard(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        bottomConstraint.constant = keyboardFrame.height
        view.layoutIfNeeded()
    }
    
    @objc private func hideKeyboard() {
        bottomConstraint.constant = 0
        view.layoutIfNeeded()
    }

    // MARK: - Action Methods

    @objc private func handleResetPassword() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email address.")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "Error: \(error.localizedDescription)")
                return
            }
            self?.showAlert(message: "Please check your email to reset password") {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func tapGestureAction() {
        view.endEditing(true)
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    
    // MARK: - Setup Methods

    private func setupDelegates() {
        emailTextField.delegate = self
    }
}

// MARK: - UITextFieldDelegate

extension PasswordResetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UITextField Extension

extension UITextField {
    /// Adds padding to the left of the text field.
    /// - Parameter amount: The amount of padding to add.
    func paddingLeft(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
