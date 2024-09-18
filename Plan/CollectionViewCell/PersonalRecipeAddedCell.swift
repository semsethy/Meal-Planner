import UIKit
import CoreData

protocol PersonalRecipeAddedCellDelegate: AnyObject {
    func didTapAddToPlanButton(at indexPath: IndexPath)
}

@available(iOS 13.0, *)
class PersonalRecipeAddedCell: UITableViewCell {
    
    weak var delegate: PersonalRecipeAddedCellDelegate?
    var indexPath: IndexPath?
    var itemPer: PersonalRecipe?
    var itemFav: FavoriteRecipe?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var iconTimeSpent: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "alarm.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var timeSpentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var addToPlanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(addToPlanButtonAction), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(addToPlanButton)
        contentView.addSubview(iconTimeSpent)
        contentView.addSubview(timeSpentLabel)
        contentView.backgroundColor = .white
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(25)
            make.height.width.equalTo(60)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
        }
        addToPlanButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).offset(-20)
            make.width.height.equalTo(30)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
            make.trailing.equalTo(contentView).offset(-55)
        }
        iconTimeSpent.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(5)
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
            make.width.height.equalTo(15)
        }
        timeSpentLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(5)
            make.leading.equalTo(iconTimeSpent.snp.trailing).offset(5)
            make.trailing.equalTo(contentView).offset(-55)
        }
        setUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    func setUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let backgroundColor: UIColor
        let titleLabelColor: UIColor
        let descriptionLabelColor: UIColor
        let iconTimeSpentTintColor: UIColor
        let addButtonTintColor: UIColor
        let timeSpentLabelColor: UIColor
        
        if isDarkMode {
            backgroundColor = UIColor(white: 0.1, alpha: 1) // Dark background
            titleLabelColor = UIColor(white: 0.9, alpha: 1) // Light text color
            descriptionLabelColor = UIColor(white: 0.7, alpha: 1) // Light gray text color
            iconTimeSpentTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Retain the same color for icon
            addButtonTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Retain the same color for button
            timeSpentLabelColor = UIColor(white: 0.9, alpha: 1) // Light text color
        } else {
            backgroundColor = UIColor.white // Light background
            titleLabelColor = UIColor.black // Dark text color
            descriptionLabelColor = UIColor.gray // Gray text color
            iconTimeSpentTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Retain the same color for icon
            addButtonTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Retain the same color for button
            timeSpentLabelColor = UIColor.black // Dark text color
        }
        
        // Apply colors to UI elements
        contentView.backgroundColor = backgroundColor
        titleLabel.textColor = titleLabelColor
        descriptionLabel.textColor = descriptionLabelColor
        iconTimeSpent.tintColor = iconTimeSpentTintColor
        addToPlanButton.tintColor = addButtonTintColor
        timeSpentLabel.textColor = timeSpentLabelColor
    }
    func configure(with recipe: PersonalRecipe, at indexPath: IndexPath) {
        self.itemPer = recipe
        self.indexPath = indexPath
        titleLabel.text = recipe.perTitle
        descriptionLabel.text = recipe.perDescrip
        timeSpentLabel.text = recipe.perTimeSpent
        
        if let imageData = recipe.perImage {
            let imageSize = CGSize(width: 60, height: 60) // Thumbnail size
            if let thumbnail = ImageUtils.generateThumbnail(id: recipe.perRecipeID ?? "", imageData: imageData, size: imageSize) {
                iconImageView.image = thumbnail
            }
        }
    }
    func configureFav(with recipe: FavoriteRecipe, at indexPath: IndexPath) {
        self.itemFav = recipe
        self.indexPath = indexPath
        titleLabel.text = recipe.favTitle
        descriptionLabel.text = recipe.favDescrip
        timeSpentLabel.text = recipe.favTimeSpent
        
        if let imageData = recipe.favImage {
            let imageSize = CGSize(width: 60, height: 60) // Thumbnail size
            if let thumbnail = ImageUtils.generateThumbnail(id: recipe.favRecipeID ?? "", imageData: imageData, size: imageSize) {
                iconImageView.image = thumbnail
            }
        }
    }
    
    @objc private func addToPlanButtonAction() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapAddToPlanButton(at: indexPath)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
