import UIKit
import SnapKit
import Firebase
import FirebaseAuth

class UsernameEditViewController: UIViewController {
    static let shared = UsernameEditViewController()
    var currentUsername: String?

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter new username"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let tapGesture = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyUserInterfaceStyle()
//        view.backgroundColor = .white
        title = "Edit Username"
        view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(tapGestureAction))
        setupUI()
        
        if let currentUsername = currentUsername {
            usernameTextField.text = currentUsername
        }

            // Add observer for user interface style changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
        
    }
    @objc private func handleUserInterfaceStyleChange() {
        applyUserInterfaceStyle()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .userInterfaceStyleChanged, object: nil)
    }
    
    private func applyUserInterfaceStyle() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1
                                                                                    , alpha: 1)
        
        // Configure usernameTextField appearance
        usernameTextField.backgroundColor = isDarkMode ? UIColor(white: 0.3, alpha: 1) : UIColor(white: 0.9, alpha: 1)
        usernameTextField.textColor = isDarkMode ? .white : .black
        usernameTextField.layer.borderColor = isDarkMode ? UIColor.white.cgColor : UIColor.clear.cgColor
        usernameTextField.layer.borderWidth = isDarkMode ? 1.0 : 0.0
        usernameTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter new username",
            attributes: [NSAttributedString.Key.foregroundColor: isDarkMode ? UIColor.lightGray : UIColor.darkGray]
        )
        
        // Configure saveButton appearance
        saveButton.setTitleColor(isDarkMode ? .white : .white, for: .normal)
        saveButton.backgroundColor = isDarkMode ? UIColor(white: 0.3, alpha: 1) : UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        saveButton.tintColor = .white
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor.black]
        appearance.shadowColor = isDarkMode ? UIColor.clear : UIColor.clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = isDarkMode ? UIColor.white : UIColor.black
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyUserInterfaceStyle() // Apply theme changes
    }
    
    private func setupUI() {
        view.addSubview(usernameTextField)
        view.addSubview(saveButton)
        usernameTextField.delegate = self
        
        usernameTextField.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            make.width.equalTo(300)
            make.height.equalTo(44)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
    }

    @objc private func saveButtonTapped() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            showAlert(with: "User is not authenticated.")
            return
        }
        guard let newUsername = usernameTextField.text, !newUsername.isEmpty else {
            showAlert(with: "Username cannot be empty.")
            return
        }
        
        saveUsername(newUsername, userID: userID)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func tapGestureAction() {
        view.endEditing(true)
    }
    
    private func showAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func saveUsername(_ username: String, userID: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).updateData(["username": username]) { error in
            if let error = error {
                print("Error saving username: \(error.localizedDescription)")
                self.showAlert(with: "Failed to save username. Please try again.")
            } else {
                print("Username successfully updated.")
            }
        }
    }
}

extension UsernameEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            usernameTextField.resignFirstResponder()
        }
        return true
    }
}
