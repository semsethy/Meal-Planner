//
//  KhmerCollectionViewCell.swift
//  Meal Preparing
//
//  Created by JoshipTy on 29/7/24.
//

import UIKit
import SkeletonView
import CoreData

@available(iOS 13.0, *)
class KhmerCollectionViewCell: UICollectionViewCell {
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
        button.isSkeletonable = true
        return button
    }()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var item: AsiaRecipes?
    var recipeID: String? = nil
    var ingredient: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(timeSpentLabel)
        contentView.addSubview(timeSpentImage)
        contentView.addSubview(favoriteButton)
        setUIColor()
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.centerX.equalTo(contentView)
            make.width.equalTo(contentView)
            make.height.equalTo(160)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.bottom.equalTo(timeSpentImage.snp.top).offset(-7)
        }
        
        timeSpentImage.snp.makeConstraints { make in
            make.leading.equalTo(contentView)
            make.width.height.equalTo(14)
            make.bottom.equalTo(contentView).inset(7)
        }
        
        timeSpentLabel.snp.makeConstraints { make in
            make.leading.equalTo(timeSpentImage.snp.trailing).offset(5)
            make.trailing.equalTo(contentView).inset(25)
            make.bottom.equalTo(contentView).inset(7)
        }
        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView).inset(7)
            make.width.height.equalTo(20)
        }
    }
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    func setUIColor(){
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        let textColorLight = UIColor.black
        let textColorDark = UIColor.white
        
        let tintColorLight = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let tintColorDark = UIColor(white: 1, alpha: 1)
        
        titleLabel.textColor = isDarkMode ? textColorDark : textColorLight
        timeSpentLabel.textColor = isDarkMode ? textColorDark : textColorLight
        timeSpentImage.tintColor = isDarkMode ? tintColorDark : tintColorLight
        favoriteButton.setImage(UIImage(systemName: "heart")?.withTintColor(isDarkMode ? tintColorDark : tintColorLight, renderingMode: .alwaysOriginal), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(isDarkMode ? tintColorDark : tintColorLight, renderingMode: .alwaysOriginal), for: .selected)
    }
    func configure(with recipe: AsiaRecipes) {
        titleLabel.text = recipe.title
        timeSpentLabel.text = recipe.timeSpent
        item = recipe
        recipeID = recipe.recipeID
        ingredient = recipe.ingredients!
        
        if let imageData = recipe.imageData {
            if let thumbnail = ImageUtils.generateThumbnail(id: recipe.recipeID!, imageData: imageData) {
                imageView.image = thumbnail
            }
        }
        checkIfRecipeIsFavorited()
    }
    func checkIfRecipeIsFavorited() {
        guard let recipeID = recipeID else { return }
        
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
        guard let recipeID = recipeID else {
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
            favoriteRecipe.favTitle = item?.title
            favoriteRecipe.favDescrip = item?.description
            favoriteRecipe.favTimeSpent = item?.timeSpent
            favoriteRecipe.favImage = item?.imageData
            
            // Create FavoriteIngredient objects and set relationship
            var favoriteIngredientsSet = Set<FavoriteIngredient>()
            for ingredients in ingredient {
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
