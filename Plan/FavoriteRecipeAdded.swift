//
//  FavoriteRecipeAdded.swift
//  Meal Preparing
//
//  Created by JoshipTy on 8/8/24.
//

import UIKit
import CoreData

protocol AddFavoriteRecipeToPlanDelegate: AnyObject {
    func saveFavoriteRecipe(recipe: Recipes)
}
@available(iOS 13.0, *)
class FavoriteRecipeAdded: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        button.tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    private lazy var personalLabel: UILabel = {
        let label = UILabel()
        label.text = "All Favorite Recipes"
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = .black
        return label
    }()
    private lazy var privateLabel: UILabel = {
        let label = UILabel()
        label.text = "Recipes Collected"
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = UIColor(white: 0.5, alpha: 1)
        return label
    }()
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(systemName: "fork.knife"))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        let label = UILabel()
        label.text = "No Recipe"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        view.addSubview(label)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(label.snp.top).offset(-10)
            make.width.height.equalTo(80)
        }
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        return view
    }()
    
    weak var delegate: AddFavoriteRecipeToPlanDelegate?
    var dayTitles: [String] = []
    var selectedSection: Int?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [FavoriteRecipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PersonalRecipeAddedCell.self, forCellReuseIdentifier: "CollectionCell")
        fetchRecipes()
    }

    private func setupUI() {
        view.addSubview(cancelButton)
        view.addSubview(tableView)
        view.addSubview(personalLabel)
        view.addSubview(privateLabel)
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(privateLabel.snp.bottom).offset(20)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        emptyStateView.isHidden = true
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view).offset(50)
            make.leading.equalTo(view).offset(20)
            make.height.width.equalTo(50)
        }
        
        personalLabel.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view).inset(20)
        }
        
        privateLabel.snp.makeConstraints { make in
            make.top.equalTo(personalLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view).inset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(privateLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(view)
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
        let tableViewBackgroundColor: UIColor
        let personalLabelTextColor: UIColor
        let privateLabelTextColor: UIColor
        let emptyStateViewBackgroundColor: UIColor
        let emptyStateImageViewTintColor: UIColor
        let emptyStateLabelTextColor: UIColor
        
        if isDarkMode {
            tableViewBackgroundColor = UIColor(white: 0.1, alpha: 1) // Dark background
            personalLabelTextColor = UIColor(white: 1, alpha: 1) // Light text color
            privateLabelTextColor = UIColor(white: 0.9, alpha: 1) // Light gray text color button
            emptyStateViewBackgroundColor = UIColor(white: 0.1, alpha: 1) // Darker background for empty state
            emptyStateImageViewTintColor = UIColor(white: 0.7, alpha: 1) // Light gray tint for image view
            emptyStateLabelTextColor = UIColor(white: 0.7, alpha: 1) // Light gray text for label
        } else {
            tableViewBackgroundColor = UIColor.white // Light background
            personalLabelTextColor = UIColor.black // Dark text color
            privateLabelTextColor = UIColor(white: 0.5, alpha: 1) // Gray text color
            emptyStateViewBackgroundColor = UIColor(white: 1, alpha: 1) // Light background for empty state
            emptyStateImageViewTintColor = UIColor.gray // Gray tint for image view
            emptyStateLabelTextColor = UIColor.gray // Gray text for label bar
        }
        // Apply colors to UI elements
        view.backgroundColor = emptyStateViewBackgroundColor
        tableView.backgroundColor = tableViewBackgroundColor
        personalLabel.textColor = personalLabelTextColor
        privateLabel.textColor = privateLabelTextColor
        emptyStateView.backgroundColor = emptyStateViewBackgroundColor
        cancelButton.tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        
        if let imageView = emptyStateView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            imageView.tintColor = emptyStateImageViewTintColor
        }
        if let label = emptyStateView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.textColor = emptyStateLabelTextColor
        }
    }
    func updateEmptyStateVisibility() {
        emptyStateView.isHidden = !items.isEmpty
        tableView.isHidden = items.isEmpty
    }
    private func fetchRecipes() {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        do {
            items = try context.fetch(fetchRequest)
            updateEmptyStateVisibility()
            tableView.reloadData()
        } catch {
            print("Failed to fetch recipes: \(error)")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! PersonalRecipeAddedCell
        let item = items[indexPath.row]
        cell.configureFav(with: item, at: indexPath)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    @objc private func cancelButtonAction() {
        dismiss(animated: true)
    }
}
@available(iOS 13.0, *)
extension FavoriteRecipeAdded: PersonalRecipeAddedCellDelegate {
    func didTapAddToPlanButton(at indexPath: IndexPath) {
        guard selectedSection != nil else { return }

        let itemP = items[indexPath.row]
        
        // Create a new recipe object
        let recipe = Recipes(context: context)
        recipe.recipeID = UUID().uuidString // Generate a new unique ID
        recipe.title = itemP.favTitle
        recipe.descrip = itemP.favDescrip
        recipe.timeSpent = itemP.favTimeSpent
        recipe.image = itemP.favImage // Save image as Data
        
        // Map favorite ingredients to shopping list ingredients
        if let ingredients = itemP.favoIngredient as? Set<FavoriteIngredient> {
            let shoppingListIngredients = ingredients.map { ingredient -> Ingredients in
                let shoppingListIngredient = Ingredients(context: self.context)
                shoppingListIngredient.ingredients = ingredient.favIngredients
                shoppingListIngredient.isChecked = false
                return shoppingListIngredient
            }
            let ingredientsSet = NSSet(array: shoppingListIngredients)
            recipe.ingredients = ingredientsSet
        }

        // Save the context
        do {
            try context.save()
            delegate?.saveFavoriteRecipe(recipe: recipe)
            dismiss(animated: true)
        } catch {
            print("Failed to save recipe: \(error)")
        }
    }


}
