
import UIKit

protocol optionsActionViewAlertDelegate: AnyObject {
    func didSelectDelete()
    func didSelectAddToShopppingList()
    func didSelectSetMealTime()
}
@available(iOS 13.0, *)
class optionsActionViewAlert: UIViewController {
    
    weak var delegate: optionsActionViewAlertDelegate?
    var isMealTimeSet: Bool = false // New property to track meal time status
    
    private lazy var addToShopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add To Shopping List", for: .normal)
        button.setImage(UIImage(systemName: "bag.fill.badge.plus"), for: .normal)
        button.layer.borderWidth = 1.0
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -190, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -170, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(addToShopButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var selectMealTimeButton: UIButton = {
        let button = UIButton(type: .system)
        // Update title based on isMealTimeSet
        button.setTitle(isMealTimeSet ? "Edit Cooking Time" : "Set Cooking Time", for: .normal)
        button.setImage(UIImage(systemName: "alarm.fill"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -215, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -190, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(selectMealTimeButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove from Meal Plan", for: .normal)
        button.setImage(UIImage(systemName: "trash.circle"), for: .normal)
        button.layer.borderWidth = 1.0
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -175, bottom: 0, right: 0) // Space between image and title
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -155, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 16
        view.addSubview(addToShopButton)
        view.addSubview(deleteButton)
        view.addSubview(selectMealTimeButton)
        
        addToShopButton.snp.makeConstraints { make in
            make.top.equalTo(view).offset(40)
            make.leading.trailing.equalTo(view).inset(-10)
            make.height.equalTo(40)
        }
        selectMealTimeButton.snp.makeConstraints { make in
            make.top.equalTo(addToShopButton.snp.bottom)
            make.leading.trailing.equalTo(view).inset(-10)
            make.height.equalTo(40)
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(selectMealTimeButton.snp.bottom)
            make.leading.trailing.equalTo(view).inset(-10)
            make.height.equalTo(40)
        }
        setUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    func setUIColor() {
        // Determine if dark mode is enabled
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        // Define colors for light mode
        let backgroundColorLight = UIColor.white
        let buttonTintColorLight = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let buttonTitleColorLight = UIColor.black
        let borderColorLight = UIColor.systemGray5.cgColor
        let deleteButtonTintColorLight = UIColor.red
        
        // Define colors for dark mode
        let backgroundColorDark = UIColor(white: 0.2, alpha: 1)
        let buttonTintColorDark = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let buttonTitleColorDark = UIColor.white
        let borderColorDark = UIColor.systemGray3.cgColor
        let deleteButtonTintColorDark = UIColor.red // Adjust as needed for dark mode
        
        // Apply colors based on the current mode
        let backgroundColor = isDarkMode ? backgroundColorDark : backgroundColorLight
        let buttonTintColor = isDarkMode ? buttonTintColorDark : buttonTintColorLight
        let buttonTitleColor = isDarkMode ? buttonTitleColorDark : buttonTitleColorLight
        let borderColor = isDarkMode ? borderColorDark : borderColorLight
        let deleteButtonTintColor = isDarkMode ? deleteButtonTintColorDark : deleteButtonTintColorLight

        // Apply the colors to UI elements
        view.backgroundColor = backgroundColor
        addToShopButton.layer.borderColor = borderColor
        addToShopButton.setTitleColor(buttonTitleColor, for: .normal)
        addToShopButton.tintColor = buttonTintColor
        selectMealTimeButton.tintColor = buttonTintColor
        selectMealTimeButton.setTitleColor(buttonTitleColor, for: .normal)
        deleteButton.tintColor = deleteButtonTintColor // Tint color for image
        deleteButton.setTitleColor(buttonTitleColor, for: .normal)
        deleteButton.layer.borderColor = borderColor
    }

    
    @objc func addToShopButtonAction() {
        delegate?.didSelectAddToShopppingList()
        dismiss(animated: true, completion: nil)
    }
    @objc func selectMealTimeButtonAction() {
        dismiss(animated: true){[weak self ] in
            self?.delegate?.didSelectSetMealTime()
        }
    }
    @objc func deleteButtonAction() {
        delegate?.didSelectDelete()
        dismiss(animated: true, completion: nil)
    }
}
