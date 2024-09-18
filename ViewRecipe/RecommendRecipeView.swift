import UIKit
import CoreData
import FirebaseStorage
import FirebaseFirestore
import SnapKit

@available(iOS 13.0, *)
class RecommendRecipeView: UIViewController {
    lazy var recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var recipeTitleLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .clear

        button.addTarget(self, action: #selector(favoriteButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var recipeDesciptionLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .justified
        label.text = "Description:  "
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var iconTimeSpentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "alarm.fill")
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    lazy var recipeTimeSpentLabel: UILabel = {
        let label = UILabel()
        
        label.text = "nil"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var recipeIngredientLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingredient:"
        
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var IngredientTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    lazy var MainView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    var ingredientTableViewHeightConstraint: Constraint?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var recipeID: String? = nil
    var ingredient: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Food Detail"
        setUpUI()
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
        let textColor: UIColor
        let tintColor: UIColor
        
        if isDarkMode {
            // Dark mode colors
            backgroundColor = UIColor(white: 0.1, alpha: 1) // Dark background
            textColor = .white
            tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Accent color
        } else {
            // Light mode colors
            backgroundColor = UIColor.white
            textColor = .black
            tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Accent color
        }
        
        // Apply colors to UI elements
        recipeImageView.tintColor = tintColor
        recipeTitleLabel.textColor = textColor
        favoriteButton.setImage(
            UIImage(systemName: "heart")?.withTintColor(tintColor, renderingMode: .alwaysOriginal),
            for: .normal
        )
        favoriteButton.setImage(
            UIImage(systemName: "heart.fill")?.withTintColor(tintColor, renderingMode: .alwaysOriginal),
            for: .selected
        )
        scrollView.backgroundColor = backgroundColor
        view.backgroundColor = backgroundColor
        recipeDesciptionLabel.textColor = textColor
        iconTimeSpentImageView.tintColor = tintColor
        recipeTimeSpentLabel.textColor = textColor
        recipeIngredientLabel.textColor = textColor
        IngredientTableView.backgroundColor = backgroundColor
        MainView.backgroundColor = backgroundColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor.black]
        appearance.shadowColor = isDarkMode ? UIColor.clear : UIColor.clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = isDarkMode ? UIColor.white : UIColor.black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfRecipeIsFavorited()
    }
    
    func setUpUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(MainView)
        MainView.addSubview(recipeImageView)
        MainView.addSubview(recipeTitleLabel)
        MainView.addSubview(recipeDesciptionLabel)
        MainView.addSubview(recipeIngredientLabel)
        MainView.addSubview(recipeTimeSpentLabel)
        MainView.addSubview(iconTimeSpentImageView)
        MainView.addSubview(IngredientTableView)
        MainView.addSubview(favoriteButton)

        IngredientTableView.delegate = self
        IngredientTableView.dataSource = self
        IngredientTableView.register(RecommendRecipeViewCell.self, forCellReuseIdentifier: "cell")

        // Initial layout setup
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        MainView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        recipeImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(MainView)
            make.height.equalTo(400)
        }
        recipeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(recipeImageView.snp.bottom).offset(20)
            make.leading.equalTo(MainView).offset(20)
        }
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(recipeImageView.snp.bottom).offset(15)
            make.trailing.equalTo(MainView).offset(-20)
            make.leading.greaterThanOrEqualTo(recipeTitleLabel.snp.trailing).offset(20)
            make.width.height.equalTo(40)
        }
        recipeDesciptionLabel.snp.makeConstraints { make in
            make.top.equalTo(recipeTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(MainView).inset(25)
        }
        iconTimeSpentImageView.snp.makeConstraints { make in
            make.top.equalTo(recipeDesciptionLabel.snp.bottom).offset(20)
            make.leading.equalTo(MainView).offset(20)
            make.width.height.equalTo(20)
        }
        recipeTimeSpentLabel.snp.makeConstraints { make in
            make.top.equalTo(recipeDesciptionLabel.snp.bottom).offset(20)
            make.leading.equalTo(iconTimeSpentImageView.snp.trailing).offset(5)
            make.trailing.equalTo(MainView).offset(-20)
        }
        recipeIngredientLabel.snp.makeConstraints { make in
            make.top.equalTo(iconTimeSpentImageView.snp.bottom).offset(10)
            make.leading.trailing.equalTo(MainView).inset(20)
        }
        IngredientTableView.snp.makeConstraints { make in
            make.top.equalTo(recipeIngredientLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(MainView)
            ingredientTableViewHeightConstraint = make.height.equalTo(0).constraint
        }
        // Make sure MainView extends to the bottom of IngredientTableView
        MainView.snp.makeConstraints { make in
            make.bottom.equalTo(IngredientTableView.snp.bottom).offset(20)
        }

        IngredientTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTableViewHeight()
    }
    
    override func viewDidLayoutSubviews() {
        updateTableViewHeight()
    }
    
    func updateTableViewHeight() {
        // Calculate the content height of the IngredientTableView
        let contentHeight = IngredientTableView.contentSize.height
        
        // Update the height constraint for the IngredientTableView
        ingredientTableViewHeightConstraint?.update(offset: contentHeight)
        
        // Force layout of the MainView and its subviews
        MainView.layoutIfNeeded()
        
        // Calculate and set the scroll view content size
        let totalContentHeight = MainView.frame.height + contentHeight
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: totalContentHeight)
        
        // Debugging prints to verify layout
        print("ScrollView content size: \(scrollView.contentSize)")
        print("MainView frame height: \(MainView.frame.height)")
        print("IngredientTableView content height: \(contentHeight)")
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


    @objc func favoriteButtonAction() {
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
            favoriteRecipe.favTitle = recipeTitleLabel.text
            favoriteRecipe.favDescrip = recipeDesciptionLabel.text
            favoriteRecipe.favTimeSpent = recipeTimeSpentLabel.text
            favoriteRecipe.favImage = recipeImageView.image?.jpegData(compressionQuality: 1)
            
            var favoriteIngredientsSet = Set<FavoriteIngredient>()
            for ingredient in self.ingredient {
                let favoriteIngredient = FavoriteIngredient(context: context)
                favoriteIngredient.favIngredients = ingredient
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

@available(iOS 13.0, *)
extension RecommendRecipeView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredient.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecommendRecipeViewCell
        let ingredient = ingredient[indexPath.item]
        cell.titleLabel.text = ingredient
        cell.selectionStyle = .none
        return cell
    }
}
