import UIKit
import FirebaseAuth
import SnapKit

// OTP Code
class ConOTPViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reset Your Password"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let otpLabel: UILabel = {
        let label = UILabel()
        label.text = "OTP Code:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let otpTextField: UITextField = {
        let textField = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray // Change this to your desired color
        ]
        let attributedPlaceholder = NSAttributedString(string: "Enter OTP Code", attributes: placeholderAttributes)
        textField.attributedPlaceholder = attributedPlaceholder
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.paddingLeft(12)  // Apply padding here
        return textField
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "New Password:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let newPasswordTextField: UITextField = {
        let textField = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray // Change this to your desired color
        ]
        let attributedPlaceholder = NSAttributedString(string: "Enter your password", attributes: placeholderAttributes)
        textField.attributedPlaceholder = attributedPlaceholder
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.paddingLeft(12)  // Apply padding here
        return textField
    }()
    
    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm Password:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray // Change this to your desired color
        ]
        let attributedPlaceholder = NSAttributedString(string: "Confirm new password", attributes: placeholderAttributes)
        textField.attributedPlaceholder = attributedPlaceholder
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.paddingLeft(12)  // Apply padding here
        return textField
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return button
    }()
    
    private var bottomConstraint = NSLayoutConstraint()
    private let tapGesture = UITapGestureRecognizer()
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        configureNavigationBar()
        
        otpTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    private func setupUI() {
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        // Add arranged subviews to stack view
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(otpLabel)
        stackView.addArrangedSubview(otpTextField)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(newPasswordTextField)
        stackView.addArrangedSubview(confirmPasswordLabel)
        stackView.addArrangedSubview(confirmPasswordTextField)
        stackView.addArrangedSubview(resetButton)
        
        // Add stack view to content view
        contentView.addSubview(stackView)
        view.addSubview(scrollView)
        view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(tapGestureAction))
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        scrollView.addSubview(contentView)
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
            make.top.equalTo(contentView).offset(100)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.width.equalTo(contentView).offset(-40)
            make.bottom.equalTo(contentView).inset(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
        }

        otpLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }

        otpTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        passwordLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        newPasswordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }

        confirmPasswordLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }

        confirmPasswordTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        resetButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    private func configureNavigationBar() {
        self.title = "Verify OTP"
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Make the otpTextField the first responder
        otpTextField.becomeFirstResponder()
    }
    
    @objc private func handleResetPassword() {
        guard let otp = otpTextField.text, !otp.isEmpty else {
            showAlert(message: "Please enter the OTP code.")
            return
        }
        
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
            showAlert(message: "Please enter a new password.")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == newPassword else {
            showAlert(message: "Passwords do not match.")
            return
        }
        
        // Reset the password using Firebase Auth
        Auth.auth().confirmPasswordReset(withCode: otp, newPassword: newPassword) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "Error: \(error.localizedDescription)")
                return
            }
            
            // Success
            self?.showAlert(message: "Password has been successfully reset.")
        }
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
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
extension ConOTPViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == otpTextField{
            newPasswordTextField.becomeFirstResponder()
        }
        else if textField == newPasswordTextField{
            confirmPasswordTextField.becomeFirstResponder()
        }
        else {
            confirmPasswordTextField.resignFirstResponder()
        }
        return true
    }
}
