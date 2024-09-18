//
//  ImageSliceShowView.swift
//  Meal Preparing
//
//  Created by JoshipTy on 21/8/24.
//

import UIKit
import CoreData
import SnapKit

class ImageSliceShowView: UIViewController {
    lazy var recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var recipeTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .clear
        button.setImage(UIImage(systemName: "heart")?.withTintColor(UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1), renderingMode: .alwaysOriginal), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill")?.withTintColor(UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1), renderingMode: .alwaysOriginal), for: .selected)
        button.addTarget(self, action: #selector(favoriteButtonAction), for: .touchUpInside)
        return button
    }()
    lazy var recipeDesciptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Description:  "
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var iconTimeSpentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "alarm.fill")
        imageView.tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    lazy var recipeTimeSpentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "nil"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var recipeIngredientLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingredient:"
        label.textColor = .black
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
        view.backgroundColor = .white
        return view
    }()
    var ingredientTableViewHeightConstraint: Constraint?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var recipeID: String? = nil
    var ingredient: [String] = [] 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarAppearance()
        checkIfRecipeIsFavorited()
    }
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        navigationItem.title = "Food Detail"
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    private func setupUI() {
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
            make.bottom.equalTo(IngredientTableView.snp.bottom) // Make sure MainView extends to the bottom of IngredientTableView
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
        // Reload data and update height constraint
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
extension ImageSliceShowView: UITableViewDelegate, UITableViewDataSource{
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
