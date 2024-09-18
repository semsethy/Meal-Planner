import UIKit
import CoreData
import MobileCoreServices
extension Notification.Name {
    static let didAddRecipeToShoppingList = Notification.Name("didAddRecipeToShoppingList")
}

@available(iOS 13.0, *)
class ShoppingList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private lazy var createIngredient: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        if #available(iOS 16.0, *) {
            button.addTarget(self, action: #selector(didTapCreateIngredient), for: .touchUpInside)
        }
//        button.tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        return button
    }()
    private lazy var optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        button.addTarget(self, action: #selector(optionAction), for: .touchUpInside)
//        button.tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        return button
    }()
    private lazy var addLabel: UILabel = {
        let label = UILabel()
        label.text = "Add To Shopping List"
//        label.textColor = .black
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        
        let imageView = UIImageView(image: UIImage(systemName: "cart.fill.badge.questionmark"))
//        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Shopping List is empty"
//        label.textColor = .gray
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
//            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let outerTableView = UITableView(frame: .zero, style: .grouped)
    var recipesSection: [ShoppingListRecipe] = []
    var recipeShop: ShoppingListRecipe?
    var selected: Int?
    var ingredients = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .white
        navigationItem.title = "Shopping List"
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecipeAddedNotification), name: .didAddRecipeToShoppingList, object: nil)
                
        outerTableView.delegate = self
        outerTableView.dataSource = self
        outerTableView.register(RecipeCell.self, forCellReuseIdentifier: "recipeCell")
        outerTableView.rowHeight = UITableView.automaticDimension
        outerTableView.estimatedRowHeight = 100
        outerTableView.separatorStyle = .none
//        outerTableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        view.addSubview(outerTableView)
        view.addSubview(createIngredient)
        view.addSubview(addLabel)
        view.addSubview(optionButton)
        
        createIngredient.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.width.equalTo(30)
        }
        addLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(25)
            make.trailing.equalTo(optionButton.snp.leading).offset(-20)
            make.leading.equalTo(createIngredient.snp.trailing).offset(5)
        }
        optionButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.width.equalTo(30)
        }
        outerTableView.snp.makeConstraints { make in
            make.top.equalTo(addLabel.snp.bottom).offset(20)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(addLabel.snp.bottom).offset(20)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        emptyStateView.isHidden = true
        
        fetchRecipes()
        applyColorTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        applyColorTheme()
    }
    private func applyColorTheme() {
        // Check for dark mode preference
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let lightPrimaryColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let lightPrimaryColor1 = UIColor(white: 1, alpha: 1)
        let lightSecondaryColor = UIColor.black
        let lightBackgroundColor = UIColor(white: 0.95, alpha: 1)
        let lightBackgroundColor1 = UIColor(white: 1, alpha: 1)
        
        let darkPrimaryColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1) // Example dark primary color
        let darkSecondaryColor = UIColor.white
        let darkBackgroundColor = UIColor(white: 0.15, alpha: 1) // Example dark background color
        let darkBackgroundColor1 = UIColor(white: 0.2, alpha: 1)
        
        // Apply colors based on the theme
        let primaryColor = isDarkMode ? darkPrimaryColor : lightPrimaryColor
        let secondaryColor = isDarkMode ? darkSecondaryColor : lightSecondaryColor
        let backgroundColor = isDarkMode ? darkBackgroundColor1 : lightBackgroundColor1
        let backgroundColor1 = isDarkMode ? darkBackgroundColor : lightBackgroundColor
        
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : lightBackgroundColor1
        createIngredient.tintColor = primaryColor
        optionButton.tintColor = primaryColor
        addLabel.textColor = secondaryColor
        outerTableView.backgroundColor = backgroundColor1
        outerTableView.separatorStyle = .none // or set a color for separator if needed
        
        emptyStateView.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : lightBackgroundColor1
        if let imageView = emptyStateView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            imageView.tintColor = isDarkMode ? .lightGray : .gray
        }
        if let label = emptyStateView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.textColor = isDarkMode ? .lightGray : .gray
        }
        
        // Update the navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : lightPrimaryColor1
        appearance.titleTextAttributes = [.foregroundColor: secondaryColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: secondaryColor]
        appearance.shadowColor = isDarkMode ? .clear : lightPrimaryColor1
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = secondaryColor
    }

    @objc func optionAction() {
        // Create the initial action sheet
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        // Add "Clear List" action
        actionSheet.addAction(UIAlertAction(
            title: "Clear List",
            style: .destructive,
            handler: { [weak self] _ in
                guard let self = self else { return }
                // Create and present the confirmation alert
                let confirmAlert = UIAlertController(
                    title: "Clear List",
                    message: "Are you sure you want to clear all the Ingredients?",
                    preferredStyle: .alert
                )
                // Add cancel action to the confirmation alert
                let cancelAction = UIAlertAction(
                    title: "Cancel",
                    style: .cancel
                )
                confirmAlert.addAction(cancelAction)
                // Add clear action to the confirmation alert
                let clearAction = UIAlertAction(
                    title: "Clear",
                    style: .destructive
                ) { _ in
                    self.clearIngredients()
                }
                confirmAlert.addAction(clearAction)
                self.present(confirmAlert, animated: true, completion: nil)
            }
        ))
        // Add "Share" action
        actionSheet.addAction(UIAlertAction(
            title: "Share",
            style: .default,
            handler: { [weak self] _ in
                guard let self = self else { return }
                self.shareShoppingList()
            }
        ))
        // Add "Cancel" action
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }

    // Function to clear ingredients from Core Data
    private func clearIngredients() {
        let fetchRequest: NSFetchRequest<ShoppingListRecipe> = ShoppingListRecipe.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            try context.save()
            fetchRecipes() // Refresh the list after clearing
        } catch {
            print("Failed to clear ingredients: \(error.localizedDescription)")
        }
    }

    private func shareShoppingList() {
        // Define the fetch request for ShoppingListRecipe
        let fetchRequest: NSFetchRequest<ShoppingListRecipe> = ShoppingListRecipe.fetchRequest()
        
        do {
            // Fetch the recipes from Core Data
            let recipes = try context.fetch(fetchRequest)
            
            // Add header to the share content
            var shareContent = "Here is my Foodie Shopping List:\n"
            
            // Loop through the fetched recipes
            for recipe in recipes {
                // Extract the recipe title
                let recipeTitle = recipe.shopTitle ?? "No Title"
                
                // Extract and format the ingredients
                var ingredientsList: String = ""
                if let ingredientsSet = recipe.shopIngredient as? Set<ShoppingListIngredient> {
                    // Convert NSSet to an array
                    let ingredientsArray = Array(ingredientsSet)
                    
                    for ingredient in ingredientsArray {
                        let ingredientName = ingredient.shopIngredients ?? "Unknown Ingredient"
                        ingredientsList += "\n- \(ingredientName)"
                    }
                }
                // Format the recipe entry
                let recipeEntry = """
                Recipe: \(recipeTitle)
                Ingredients:\(ingredientsList)
                """
                // Append to the share content
                shareContent += recipeEntry + "\n\n"
            }
            
            // Check if there is content to share
            if shareContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Present an alert if there are no recipes to share
                let alert = UIAlertController(
                    title: "No Recipes to Share",
                    message: "There are no recipes to share at the moment.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(
                    title: "OK",
                    style: .default
                ))
                present(alert, animated: true, completion: nil)
            } else {
                // Create and present the activity view controller
                let activityViewController = UIActivityViewController(
                    activityItems: [shareContent],
                    applicationActivities: nil
                )
                
                // iPad specific configuration for popover presentation
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.barButtonItem = navigationItem.rightBarButtonItem // Adjust as necessary
                    popoverController.permittedArrowDirections = .any
                }
                
                // Present the activity view controller
                present(activityViewController, animated: true, completion: nil)
            }
        } catch {
            // Handle any errors during the fetch operation
            print("Failed to fetch recipes for sharing: \(error.localizedDescription)")
        }
    }
    @objc func handleRecipeAddedNotification() {
        fetchRecipes()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .didAddRecipeToShoppingList, object: nil)
    }
    @available(iOS 16.0, *)
    @objc func didTapCreateIngredient() {
        let formSheetVC = CreateIngredient()
        formSheetVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 150)
        formSheetVC.delegate = self
        if let sheet = formSheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(resolver: { _ in 350 })
            sheet.detents = [customDetent] // Use the custom detent
            sheet.prefersGrabberVisible = true // Shows a grabber handle on the sheet
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        else {
            formSheetVC.modalPresentationStyle = .pageSheet
        }
        present(formSheetVC, animated: true, completion: nil)
    }
    func fetchRecipes() {
        let fetchRequest: NSFetchRequest<ShoppingListRecipe> = ShoppingListRecipe.fetchRequest()
        recipesSection = try! context.fetch(fetchRequest)
        outerTableView.reloadData()
        updateClearButtonVisibility()
        updateEmptyStateVisibility()
    }
    func updateEmptyStateVisibility() {
        emptyStateView.isHidden = !recipesSection.isEmpty
        outerTableView.isHidden = recipesSection.isEmpty
    }
    func updateClearButtonVisibility() {
        optionButton.isHidden = recipesSection.isEmpty
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return recipesSection.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as? RecipeCell else {
            return UITableViewCell()
        }
        let recipe = recipesSection[indexPath.section]
//        cell.ingredients = recipe.ingredients?.allObjects as? [Ingredients] ?? []
        cell.configure(with: recipe, at: indexPath)
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
@available(iOS 13.0, *)
extension ShoppingList: RecipeCellDelegate {
    
    func didTapDeleteRecipe(at indexPath: IndexPath) {
        let recipeIndex = indexPath.section
        let recipeToDelete = recipesSection[recipeIndex]
//        outerTableView.deleteSections(recipeIndex, with: .fade)
        context.delete(recipeToDelete)
        
        do {
            try context.save()
            fetchRecipes()
        } catch {
            print("Failed to delete recipe: \(error)")
        }
    }
    func didTapDeleteIngredientButton(at indexPath: IndexPath, inSection section: Int) {
        let recipe = recipesSection[section]
        if let ingredients = recipe.shopIngredient?.allObjects as? [ShoppingListIngredient] {
            let ingredientToDelete = ingredients[indexPath.row]
            context.delete(ingredientToDelete)
            recipe.removeFromShopIngredient(ingredientToDelete)
            do {
                try context.save()
                fetchRecipes()
            } catch {
                print("Failed to delete ingredient: \(error)")
            }
        }
    }
}
@available(iOS 13.0, *)
extension ShoppingList: CreateIngredientDelegate{
    func didAddIngredient(ingredient: [String]) {
        // Check if there is a current recipe or create a new one if it doesn't exist
        recipeShop = ShoppingListRecipe(context: context)
        recipeShop?.shopTitle = "Not a recipe"
        recipeShop?.shopImage = UIImage(systemName: "fork.knife")?.pngData() // Use a default image
        recipeShop?.shopDescrip = nil // No description
        recipeShop?.shopTimeSpent = nil // No time spent

        // Create a new ShoppingListIngredient object
        for item in ingredient {
            let newIngredient = ShoppingListIngredient(context: context)
            newIngredient.shopIngredients = item
            newIngredient.shopRecipe = recipeShop
            recipeShop?.addToShopIngredient(newIngredient)
        }
        do {
            // Save the context to persist the new ingredient and recipe
            try context.save()
            
            // Fetch the updated recipes and reload the table view
            fetchRecipes()
        } catch {
            print("Failed to save the new ingredient: \(error)")
        }
    }
}
