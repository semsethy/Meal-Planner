//
//  CollectionCell.swift
//  Meal Preparing
//
//  Created by JoshipTy on 31/7/24.
//

import UIKit
import CoreData
import FirebaseStorage

protocol TableViewCellDelegate: AnyObject {
    func didTapDeleteButton(at indexPath: IndexPath)
}
@available(iOS 13.0, *)
class TableViewCell: UITableViewCell {
    
    weak var delegate: TableViewCellDelegate?
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
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(deleteButton)
        contentView.addSubview(iconTimeSpent)
        contentView.addSubview(timeSpentLabel)
        
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(25)
            make.height.width.equalTo(60)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
        }
        deleteButton.snp.makeConstraints { make in
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
        let deleteButtonTintColor: UIColor
        let timeSpentLabelColor: UIColor
        
        if isDarkMode {
            backgroundColor = UIColor(white: 0.1, alpha: 1) // Dark background
            titleLabelColor = UIColor(white: 0.9, alpha: 1) // Light text color
            descriptionLabelColor = UIColor(white: 0.7, alpha: 1) // Light gray text color
            iconTimeSpentTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Retain the same color for icon
            deleteButtonTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Retain the same color for button
            timeSpentLabelColor = UIColor(white: 0.9, alpha: 1) // Light text color
        } else {
            backgroundColor = UIColor.white // Light background
            titleLabelColor = UIColor.black // Dark text color
            descriptionLabelColor = UIColor.gray // Gray text color
            iconTimeSpentTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Retain the same color for icon
            deleteButtonTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Retain the same color for button
            timeSpentLabelColor = UIColor.black // Dark text color
        }
        
        // Apply colors to UI elements
        contentView.backgroundColor = backgroundColor
        titleLabel.textColor = titleLabelColor
        descriptionLabel.textColor = descriptionLabelColor
        iconTimeSpent.tintColor = iconTimeSpentTintColor
        deleteButton.tintColor = deleteButtonTintColor
        timeSpentLabel.textColor = timeSpentLabelColor
    }

    func configureFav(with recipe: FavoriteRecipe, at indexPath: IndexPath) {
        self.itemFav = recipe
        self.indexPath = indexPath
        titleLabel.text = recipe.favTitle
        descriptionLabel.text = recipe.favDescrip
        timeSpentLabel.text = recipe.favTimeSpent
        if let imageData = recipe.favImage {
            if let thumbnail = ImageUtils.generateThumbnail(id: recipe.favRecipeID!, imageData: imageData) {
                iconImageView.image = thumbnail
            }
        }
    }
    func loadImage(from imageURL: String, index: IndexPath) {
        let storage = Storage.storage().reference(forURL: imageURL)
        storage.getData(maxSize: 10 * 1024 * 1024) { [weak self] data, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            if index != self?.indexPath {
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.iconImageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self?.iconImageView.image = UIImage(systemName: "heart")
                }
            }
        }
    }
    func configure(with recipe: PersonalRecipe, at indexPath: IndexPath) {
        self.itemPer = recipe
        self.indexPath = indexPath
        titleLabel.text = recipe.perTitle
        descriptionLabel.text = recipe.perDescrip
        timeSpentLabel.text = recipe.perTimeSpent
        if let imageData = recipe.perImage {
            if let thumbnail = ImageUtils.generateThumbnail(id: recipe.perRecipeID!, imageData: imageData) {
                iconImageView.image = thumbnail
            }
        }
        if let imageURL = recipe.perImageURL {
            loadImage(from: imageURL, index: indexPath)
        } else {
            iconImageView.image = UIImage(systemName: "trash")
        }
    }
    
    @objc func deleteButtonAction() {
        guard indexPath != nil else { return }
        delegate?.didTapDeleteButton(at: indexPath!)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
