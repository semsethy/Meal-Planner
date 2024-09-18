//
//  LetsGetStarted.swift
//  Meal Preparing
//
//  Created by JoshipTy on 28/7/24.
//

import UIKit
import SnapKit
import FirebaseAuth

@available(iOS 13.0, *)
class LetsGetStarted: UIViewController {
    
    // MARK: - UI Elements
    
    private let image = UIImageView()
    private let label1 = UILabel()
    private let label2 = UILabel()
    private let CreateAccountButton = UIButton(type: .system)
    private let label3 = UILabel()
    private let label4 = UILabel()
    private let SignInButton = UIButton(type: .system)
    private let stack = UIStackView()
    private let scroll = UIScrollView()
    private let mainView = UIView()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setUIColor()
        
        // Check if the user is already authenticated
        if Auth.auth().currentUser != nil {
            navigateToTabBar()
        }
        
        // Observe for changes in user interface style
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(scroll)
        scroll.addSubview(mainView)
        mainView.addSubview(image)
        mainView.addSubview(label2)
        mainView.addSubview(label3)
        mainView.addSubview(CreateAccountButton)
        mainView.addSubview(stack)
        
        stack.addArrangedSubview(label4)
        stack.addArrangedSubview(SignInButton)
        stack.axis = .horizontal
        stack.spacing = 1
        
        // Configure UI elements
        configureImage()
        configureLabels()
        configureButtons()
    }
    
    private func configureImage() {
        image.image = UIImage(named: "pexels-esrakorkmaz-24427087")
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
    }
    
    private func configureLabels() {
        label2.numberOfLines = 4
        label2.textAlignment = .center
        label2.font = .boldSystemFont(ofSize: 25)
        
        label3.text = "This app helps you prepare your daily meal by taking note or exploring your favorite meal."
        label3.numberOfLines = 4
        label3.textAlignment = .center
        label3.font = .systemFont(ofSize: 15)
        
        label4.text = "Already have an account?"
    }
    
    private func configureButtons() {
        CreateAccountButton.setTitle("Create New Account", for: .normal)
        CreateAccountButton.addTarget(self, action: #selector(CreateAccountAction), for: .touchUpInside)
        CreateAccountButton.layer.cornerRadius = 20
        
        let underlineStyle = NSUnderlineStyle.single.rawValue
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: underlineStyle
        ]
        let attributedTitle = NSAttributedString(string: "Sign In", attributes: attributes)
        SignInButton.setAttributedTitle(attributedTitle, for: .normal)
        SignInButton.addTarget(self, action: #selector(SignInAction), for: .touchUpInside)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        scroll.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(scroll)
            make.height.equalTo(scroll)
            make.width.equalTo(scroll)
        }
        
        image.snp.makeConstraints { make in
            make.top.equalTo(mainView).offset(-25)
            make.leading.trailing.equalTo(mainView)
            make.centerX.equalTo(mainView)
            make.height.equalTo(500)
        }
        
        label2.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(30)
            make.leading.greaterThanOrEqualTo(mainView).offset(40)
            make.trailing.greaterThanOrEqualTo(mainView).offset(-40)
            make.centerX.equalTo(mainView)
        }
        
        label3.snp.makeConstraints { make in
            make.top.equalTo(label2.snp.bottom).offset(30)
            make.leading.greaterThanOrEqualTo(mainView).offset(30)
            make.trailing.greaterThanOrEqualTo(mainView).offset(-30)
            make.centerX.equalTo(mainView)
        }
        
        CreateAccountButton.snp.makeConstraints { make in
            make.top.equalTo(label3.snp.bottom).offset(30)
            make.leading.equalTo(mainView).offset(40)
            make.trailing.equalTo(mainView).offset(-40)
            make.centerX.equalTo(mainView)
            make.height.equalTo(40)
        }
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(CreateAccountButton.snp.bottom).offset(30)
            make.centerX.equalTo(mainView)
            make.width.equalTo(250)
        }
        
        SignInButton.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
        
        label4.snp.makeConstraints { make in
            make.width.equalTo(200)
        }
    }
    
    // MARK: - User Interface Style
    
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    
    private func setUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Background colors
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
        mainView.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : .white
        
        // Text and label colors
        let textColorPrimary = isDarkMode ? UIColor.white : UIColor.black
        let textColorSecondary = isDarkMode ? UIColor.lightGray : UIColor.gray
        let buttonColor = isDarkMode ? UIColor(red: 0.2, green: 0.5, blue: 0.4, alpha: 1) : UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        
        let fullString = "Enjoy Your Days - With A Good Meal Preparation!"
        let attributedString = NSMutableAttributedString(string: fullString)
        let firstRange = NSRange(location: 0, length: "Enjoy Your Days".count)
        let secondRange = NSRange(location: "Enjoy Your Days".count + 1, length: "- With A Good Meal Preparation!".count)
        
        attributedString.addAttribute(.foregroundColor, value: buttonColor, range: firstRange)
        attributedString.addAttribute(.foregroundColor, value: textColorPrimary, range: secondRange)
        label2.attributedText = attributedString
        
        label3.textColor = textColorSecondary
        CreateAccountButton.backgroundColor = buttonColor
        CreateAccountButton.tintColor = .white
        label4.textColor = textColorPrimary
        SignInButton.tintColor = buttonColor
    }
    
    // MARK: - Navigation
    
    private func navigateToTabBar() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let viewController = TabBar()
            appDelegate.window?.rootViewController = viewController
        }
    }
    
    // MARK: - Actions
    
    @objc private func CreateAccountAction() {
        let viewC = CreateAccount()
        viewC.modalTransitionStyle = .crossDissolve
        viewC.modalPresentationStyle = .fullScreen
        present(viewC, animated: true)
    }
    
    @objc private func SignInAction() {
        let viewC = UINavigationController(rootViewController: SignIn())
        viewC.modalTransitionStyle = .crossDissolve
        viewC.modalPresentationStyle = .fullScreen
        present(viewC, animated: true)
    }
}
