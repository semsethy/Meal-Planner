import UIKit
import CoreData
import SnapKit
import SkeletonView

@available(iOS 13.0, *)
class RecommendedCollectionViewCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.numberOfLines = 2
        label.isSkeletonable = true
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 15
        image.isSkeletonable = true
        return image
    }()
    
    private lazy var timeSpentImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "alarm.fill")
        image.tintColor = .white
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 8
        image.isSkeletonable = true
        return image
    }()
    
    private lazy var timeSpentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.isSkeletonable = true
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .clear
        button.setImage(UIImage(systemName: "heart")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .selected)
        button.addTarget(self, action: #selector(favoriteButtonAction), for: .touchUpInside)
        button.isSkeletonable = true
        return button
    }()
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 7
        view.isSkeletonable = true
        return view
    }()
    
    private lazy var gradientOverlayView: GradientOverlayView = {
        let gradientView = GradientOverlayView()
        return gradientView
    }()
    
    var itemPer: Recipes?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var item: recommandRecipes?
    var recipeID: String? = nil
    var ingredient: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.isSkeletonable = true
        contentView.addSubview(mainView)
        mainView.addSubview(imageView)
        mainView.addSubview(gradientOverlayView)
        mainView.addSubview(titleLabel)
        mainView.addSubview(timeSpentImage)
        mainView.addSubview(timeSpentLabel)
        mainView.addSubview(favoriteButton)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadiusToBottomEdges(radius: 15)
    }
    
    private func applyCornerRadiusToBottomEdges(radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    private func setupConstraints() {
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        favoriteButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(mainView).inset(5)
            make.width.height.equalTo(40)
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(mainView)
        }
        gradientOverlayView.snp.makeConstraints { make in
            make.edges.equalTo(mainView)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(mainView).offset(15)
            make.trailing.equalTo(mainView).inset(15)
            make.bottom.equalTo(timeSpentImage.snp.top).offset(-10)
        }
        timeSpentImage.snp.makeConstraints { make in
            make.bottom.equalTo(mainView).offset(-15)
            make.leading.equalTo(mainView).offset(15)
            make.width.height.equalTo(15)
        }
        timeSpentLabel.snp.makeConstraints { make in
            make.leading.equalTo(timeSpentImage.snp.trailing).offset(5)
            make.bottom.equalTo(mainView).offset(-15)
        }
    }
    
    func configure(with recipe: recommandRecipes) {
        item = recipe
        recipeID = recipe.recipeID
        ingredient = recipe.ingredients!
        titleLabel.text = recipe.title
        timeSpentLabel.text = recipe.timeSpent
        
        if let imageData = recipe.imageData {
            if let thumbnail = ImageUtils.generateThumbnail(id: recipe.recipeID!, imageData: imageData) {
                self.imageView.image = thumbnail
            }
        }
        else if let imageURL = recipe.imageURL {
            loadImageFromURL(imageURL)
        }
        checkIfRecipeIsFavorited()
    }
    private func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    self?.layoutIfNeeded()  // Ensure layout is updated
                }
            }
        }.resume()
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
    @objc private func favoriteButtonAction() {
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

