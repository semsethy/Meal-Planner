import UIKit

class SavedRecipeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        applyColorTheme() // Apply color theme on initialization
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        applyColorTheme()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(16)
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
        }
    }
    
    // MARK: - Color Theme
    private func applyColorTheme() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let lightPrimaryColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let lightTextColor = UIColor.black
        let lightBackgroundColor = UIColor.white
        
        let darkPrimaryColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        let darkTextColor = UIColor.white
        let darkBackgroundColor = UIColor(white: 0.1, alpha: 1)
        
        // Apply colors based on the theme
        let primaryColor = isDarkMode ? darkPrimaryColor : lightPrimaryColor
        let textColor = isDarkMode ? darkTextColor : lightTextColor
        let backgroundColor = isDarkMode ? darkBackgroundColor : lightBackgroundColor
        
        contentView.layer.borderColor = primaryColor.cgColor
        contentView.backgroundColor = backgroundColor
        iconImageView.tintColor = primaryColor
        titleLabel.textColor = textColor
    }
}
