//
//  SearchCollectionCell.swift
//  Meal Preparing
//
//  Created by JoshipTy on 22/8/24.
//

import UIKit
import CoreData

@available(iOS 13.0, *)
class SaerchCollectionCell: UICollectionViewCell {
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 17)
        
        label.isSkeletonable = true
        return label
    }()
    private lazy var imageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 5
        image.isSkeletonable = true
        return image
    }()
    private lazy var timeSpentLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13)
        
        label.isSkeletonable = true
        return label
    }()
    private lazy var timeSpentImage: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(systemName: "alarm.fill")
        
        image.isSkeletonable = true
        return image
    }()
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .clear

        button.addTarget(self, action: #selector(favoriteButtonAction), for: .touchUpInside)
        return button
    }()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var Item: AllRecipe?
    var RecipeID: String? = nil
    var Ingredient: [String] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(timeSpentLabel)
        contentView.addSubview(timeSpentImage)
        contentView.addSubview(favoriteButton)
        
        setupConstraints()
        setUIColor()
    }
    func setUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let contentViewBackgroundColor: UIColor
        let titleLabelTextColor: UIColor
        let timeSpentLabelTextColor: UIColor
        let timeSpentImageTintColor: UIColor
        let favoriteButtonHeartColor: UIColor
        
        if isDarkMode {
            contentViewBackgroundColor = UIColor(white: 0.1, alpha: 1)
            titleLabelTextColor = .white
            timeSpentLabelTextColor = .white
            timeSpentImageTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Adjust color for visibility
            favoriteButtonHeartColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Adjust color for visibility
        } else {
            contentViewBackgroundColor = UIColor(white: 1.0, alpha: 1) // Light mode
            titleLabelTextColor = .black
            timeSpentLabelTextColor = .black
            timeSpentImageTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
            favoriteButtonHeartColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        }
        
        // Apply colors
        contentView.backgroundColor = contentViewBackgroundColor
        titleLabel.textColor = titleLabelTextColor
        timeSpentLabel.textColor = timeSpentLabelTextColor
        timeSpentImage.tintColor = timeSpentImageTintColor
        
        favoriteButton.setImage(
            UIImage(systemName: "heart")?.withTintColor(favoriteButtonHeartColor, renderingMode: .alwaysOriginal),
            for: .normal
        )
        favoriteButton.setImage(
            UIImage(systemName: "heart.fill")?.withTintColor(favoriteButtonHeartColor, renderingMode: .alwaysOriginal),
            for: .selected
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.centerX.equalTo(contentView)
            make.width.equalTo(contentView)
            make.height.equalTo(imageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.bottom.equalTo(timeSpentImage.snp.top).offset(-6)
        }
        
        timeSpentImage.snp.makeConstraints { make in
            make.leading.equalTo(contentView)
            make.width.height.equalTo(14)
            make.bottom.equalTo(contentView)
        }
        
        timeSpentLabel.snp.makeConstraints { make in
            make.leading.equalTo(timeSpentImage.snp.trailing).offset(5)
            make.trailing.equalTo(contentView).inset(25)
            make.bottom.equalTo(contentView)
        }
        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.width.height.equalTo(20)
        }
    }
    func configure(with recipe: AllRecipe) {
        self.Item = recipe
        titleLabel.text = recipe.title
        timeSpentLabel.text = recipe.timeSpent
        RecipeID = recipe.recipeID
        Ingredient = recipe.ingredients!
        
        if let imageData = recipe.imageData {
            if let thumbnail = ImageUtils.generateThumbnail(id: recipe.recipeID!, imageData: imageData) {
                self.imageView.image = thumbnail
            }
        } else if let imageURLString = recipe.imageURL,
                  let imageURL = URL(string: imageURLString) {
            // Load image from URL asynchronously
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
        checkIfRecipeIsFavorited()
    }
    func checkIfRecipeIsFavorited() {
        guard let recipeID = RecipeID else { return }
        
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "favRecipeID == %@", recipeID)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let _ = result.first {
                favoriteButton.isSelected = true
            } else {
                favoriteButton.isSelected = false
            }
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
    }
    @objc func favoriteButtonAction(){
        guard let recipeID = RecipeID else {
            print("Recipe ID is nil. Cannot save to or remove from favorites.")
            return
        }
        
        if favoriteButton.isSelected {
            // Remove from Core Data
            let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "favRecipeID == %@", recipeID)
            
            do {
                let result = try context.fetch(fetchRequest)
                if let favoriteRecipe = result.first {
                    context.delete(favoriteRecipe)
                    try context.save()
                    
                    // Remove from Firebase Firestore
                    ShowFavRecipeView.shared.removeRecipeFromFirestore(recipeID: recipeID) { [weak self] success in
                        if success {
                            DispatchQueue.main.async {
                                self?.favoriteButton.isSelected = false
                            }
                        } else {
                            print("Failed to remove recipe from Firestore")
                        }
                    }
                }
            } catch {
                print("Failed to remove favorite: \(error.localizedDescription)")
            }
        } else {
            // Add to Core Data
            let favoriteRecipe = FavoriteRecipe(context: context)
            favoriteRecipe.favRecipeID = recipeID
            favoriteRecipe.favTitle = Item?.title
            favoriteRecipe.favDescrip = Item?.description
            favoriteRecipe.favTimeSpent = Item?.timeSpent
            favoriteRecipe.favImage = Item?.imageData
            
            // Create FavoriteIngredient objects and set relationship
            var favoriteIngredientsSet = Set<FavoriteIngredient>()
            for ingredients in Ingredient {
                let favoriteIngredient = FavoriteIngredient(context: context)
                favoriteIngredient.favIngredients = ingredients
                favoriteIngredient.favIsChecked = false
                favoriteIngredient.favoRecipe = favoriteRecipe
                favoriteIngredientsSet.insert(favoriteIngredient)
            }
            favoriteRecipe.favoIngredient = favoriteIngredientsSet as NSSet
            
            // Save to Core Data
            do {
                try context.save()
                // Save to Firebase
                ShowFavRecipeView.shared.saveRecipeWithImageToFirebase(recipe: favoriteRecipe)
                DispatchQueue.main.async {
                    self.favoriteButton.isSelected = true
                }
            } catch {
                print("Failed to save data: \(error.localizedDescription)")
            }
        }
    }
}
