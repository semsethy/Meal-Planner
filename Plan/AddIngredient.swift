//
//  AddIngredient.swift
//  Meal Preparing
//
//  Created by JoshipTy on 2/8/24.
//

import UIKit

protocol AddIngredientDelegate: AnyObject {
    func didAddIngredient(ingredient: String)
}
class AddIngredient: UIViewController, UITextFieldDelegate {
    let textField = UITextField()
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        return button
    }()
    var delegate: AddIngredientDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textField)
        view.addSubview(saveButton)
        textField.delegate = self
        textField.layer.cornerRadius = 15
       
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(view).offset(20)
            make.leading.equalTo(view).offset(20)
            make.height.equalTo(40)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(view).offset(20)
            make.leading.equalTo(textField.snp.trailing).offset(10)
            make.trailing.equalTo(view).offset(-20)
            make.height.equalTo(40)
            make.width.equalTo(50)
        }
        setUIColor() // Apply color theme when the view loads
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    func setUIColor() {
        // Check if dark mode is enabled based on the user setting in UserDefaults
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        if isDarkMode {
            textField.backgroundColor = UIColor(white: 0.2, alpha: 1) // Darker background for dark mode
            view.backgroundColor = UIColor(white: 0.1, alpha: 1) // Darker background for the view
            textField.textColor = .white // White text for dark mode
            saveButton.tintColor = .white
            saveButton.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.4, alpha: 1) // Darker green color
            
            let placeholderAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.lightGray // Lighter placeholder color for dark mode
            ]
            let attributedPlaceholder = NSAttributedString(string: "Enter Ingredients", attributes: placeholderAttributes)
            textField.attributedPlaceholder = attributedPlaceholder
        } else {
            textField.backgroundColor = UIColor(white: 0.9, alpha: 1) // Light background for light mode
            view.backgroundColor = .white // White background for the view
            textField.textColor = .black // Black text for light mode
            saveButton.tintColor = .white
            saveButton.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Original green color
            
            let placeholderAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.gray // Gray placeholder color for light mode
            ]
            let attributedPlaceholder = NSAttributedString(string: "Enter Ingredients", attributes: placeholderAttributes)
            textField.attributedPlaceholder = attributedPlaceholder
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        dismiss(animated: true)
        return true
    }
    @objc func saveButtonAction(){
        let text = textField.text ?? ""
        delegate?.didAddIngredient(ingredient: text)
        
        dismiss(animated: true)
    }
}
