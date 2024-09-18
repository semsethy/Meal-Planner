import UIKit
import CoreData

protocol IngredientsDelegate: AnyObject {
    func didTapDeleteIngredientButton(at indexPath: IndexPath)
}

@available(iOS 13.0, *)
class IngredientsCell: UITableViewCell {

    weak var delegate: IngredientsDelegate?
    var indexPath: IndexPath?
    var ingredients: ShoppingListIngredient?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private lazy var checkboxButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        return button
    }()

    var isChecked: Bool = false {
        didSet {
            checkboxButton.isSelected = isChecked
            applyColorTheme()
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        applyColorTheme()  // Apply color theme during initialization
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        checkboxButton.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(25)
            make.centerY.equalTo(contentView)
            make.height.width.equalTo(30)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(checkboxButton.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(20)
        }
    }

    @objc private func checkboxTapped() {
        isChecked.toggle()
        if let ingredient = ingredients {
            ingredient.shopIsChecked = isChecked
            do {
                try context.save()
            } catch {
                print("Failed to save isChecked state: \(error)")
            }
        }
    }

    func configure(with ingredient: ShoppingListIngredient, at indexPath: IndexPath) {
        self.indexPath = indexPath
        self.ingredients = ingredient
        self.titleLabel.attributedText = nil
//        self.titleLabel.textColor = .black
        self.isChecked = ingredient.shopIsChecked
        self.titleLabel.text = ingredient.shopIngredients
//        updateLabelStyle()
        applyColorTheme()
    }

//    private func updateLabelStyle() {
//        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
//        
//    }

    @objc func deleteIngredientButtonAction() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapDeleteIngredientButton(at: indexPath)
    }

    @objc private func handleUserInterfaceStyleChange() {
        applyColorTheme()
    }

    private func applyColorTheme() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"

        // Define colors for light and dark modes
        let lightPrimaryColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let lightTextColor = UIColor.black
        let darkPrimaryColor = UIColor.white
        let darkTextColor = UIColor(white: 0.9, alpha: 1)
        let darkBackgroundColor = UIColor(white: 0.1, alpha: 1)
        let lightBackgroundColor = UIColor.white

        // Apply colors based on the theme
        let primaryColor = isDarkMode ? darkPrimaryColor : lightPrimaryColor
        let textColor = isDarkMode ? darkTextColor : lightTextColor
        let backgroundColor = isDarkMode ? darkBackgroundColor : lightBackgroundColor

        contentView.backgroundColor = backgroundColor
        checkboxButton.tintColor = primaryColor
//        titleLabel.textColor = textColor
        if isChecked {
            let attributeString = NSMutableAttributedString(string: titleLabel.text ?? "")
            attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            titleLabel.textColor = isDarkMode ? UIColor(white: 0.5, alpha: 1) : UIColor(white: 0.5, alpha: 1)
            titleLabel.attributedText = attributeString
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = ingredients?.shopIngredients

            
            titleLabel.textColor = isDarkMode ? UIColor(white: 1, alpha: 1) : UIColor.black
        }
    }
}
