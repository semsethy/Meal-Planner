import UIKit
import FirebaseAuth
import CoreData
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

@available(iOS 13.0, *)
extension PersonalRecipe {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["perDescrip"] = perDescrip
        dict["perRecipeID"] = perRecipeID
        dict["perTimeSpent"] = perTimeSpent
        dict["perTitle"] = perTitle
        dict["perIngredient"] = (perIngredient as? Set<PersonalIngredient>)?.map { $0.perIngredient ?? "" }
        // Convert image data to base64 string for Firebase storage
        if let imageData = perImage {
            dict["perImage"] = imageData.base64EncodedString()
        }
        if let imageURL = perImageURL {
            dict["perImageURL"] = imageURL
        }
        return dict
    }
}

@available(iOS 13.0, *)
class ShowPersonalRecipeView: UIViewController, UITableViewDataSource, UITableViewDelegate,NVActivityIndicatorViewable {
    static let shared = ShowPersonalRecipeView()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private lazy var PersonalLabel: UILabel = {
        let label = UILabel()
        label.text = "All Personal Recipes"
        label.font = .boldSystemFont(ofSize: 23)
        
        return label
    }()
    
    private lazy var privateLabel: UILabel = {
        let label = UILabel()
        label.text = "Private recipes you've added"
        label.font = .boldSystemFont(ofSize: 15)
        
        return label
    }()
    
    private lazy var createRecipeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Your Own Recipe", for: .normal)
        button.setImage(UIImage(systemName: "bag.fill.badge.plus"), for: .normal)
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(createRecipeButtonAction), for: .touchUpInside)
        return button
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

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var item: PersonalRecipe?
    var items: [PersonalRecipe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "CollectionCell")
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(createRecipeButton.snp.bottom).offset(20)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        emptyStateView.isHidden = true
        fetchRecipes()
        let size = CGSize(width: 30.0, height: 30.0)
        startAnimating(size, message: "Loading", type: .ballRotateChase, color: .white, textColor: .white)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Stop animating after a delay
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
        let buttonTintColor: UIColor
        let buttonTitleColor: UIColor
        let emptyStateViewBackgroundColor: UIColor
        let emptyStateImageViewTintColor: UIColor
        let emptyStateLabelTextColor: UIColor
        let navigationBarAppearanceBackgroundColor: UIColor
        let navigationBarBorderColor: UIColor
        
        if isDarkMode {
            tableViewBackgroundColor = UIColor(white: 0.1, alpha: 1) // Dark background
            personalLabelTextColor = UIColor(white: 1, alpha: 1) // Light text color
            privateLabelTextColor = UIColor(white: 0.9, alpha: 1) // Light gray text color
            buttonTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Button color remains the same
            buttonTitleColor = UIColor(white: 1, alpha: 1) // Light text for button
            emptyStateViewBackgroundColor = UIColor(white: 0.1, alpha: 1) // Darker background for empty state
            emptyStateImageViewTintColor = UIColor(white: 0.7, alpha: 1) // Light gray tint for image view
            emptyStateLabelTextColor = UIColor(white: 0.7, alpha: 1) // Light gray text for label
            navigationBarAppearanceBackgroundColor = UIColor(white: 0.1, alpha: 1) // Dark navigation bar
            navigationBarBorderColor = UIColor.white // White border for navigation bar
        } else {
            tableViewBackgroundColor = UIColor.white // Light background
            personalLabelTextColor = UIColor.black // Dark text color
            privateLabelTextColor = UIColor(white: 0.5, alpha: 1) // Gray text color
            buttonTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Button color remains the same
            buttonTitleColor = UIColor.black // Dark text for button
            emptyStateViewBackgroundColor = UIColor(white: 1, alpha: 1) // Light background for empty state
            emptyStateImageViewTintColor = UIColor.gray // Gray tint for image view
            emptyStateLabelTextColor = UIColor.gray // Gray text for label
            navigationBarAppearanceBackgroundColor = UIColor.white // Light navigation bar
            navigationBarBorderColor = UIColor.clear // No border for navigation bar
        }
        
        // Apply colors to UI elements
        view.backgroundColor = emptyStateViewBackgroundColor
        tableView.backgroundColor = tableViewBackgroundColor
        PersonalLabel.textColor = personalLabelTextColor
        privateLabel.textColor = privateLabelTextColor
        createRecipeButton.tintColor = buttonTintColor
        createRecipeButton.setTitleColor(buttonTitleColor, for: .normal)
        emptyStateView.backgroundColor = emptyStateViewBackgroundColor
        
        if let imageView = emptyStateView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            imageView.tintColor = emptyStateImageViewTintColor
        }
        
        if let label = emptyStateView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.textColor = emptyStateLabelTextColor
        }
        
        // Configure UINavigationBar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navigationBarAppearanceBackgroundColor
        appearance.shadowColor = isDarkMode ? UIColor.clear : UIColor.clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.layer.borderColor = navigationBarBorderColor.cgColor
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    func updateEmptyStateVisibility() {
        emptyStateView.isHidden = !items.isEmpty
        tableView.isHidden = items.isEmpty
    }
    func startAnimatingIndicator() {
        let size = CGSize(width: 30.0, height: 30.0)
        startAnimating(size, message: "Loading", type: .ballRotateChase, color: .white, textColor: .white)
    }

    func stopAnimatingIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }

    
    @objc func createRecipeButtonAction() {
        let view = CreatePersonalRecipe()
        view.delegatePer = self
        view.modalPresentationStyle = .fullScreen
        present(view, animated: true)
    }
    
    func setupUI() {
        view.addSubview(tableView)
        view.addSubview(PersonalLabel)
        view.addSubview(privateLabel)
        view.addSubview(createRecipeButton)
        
        PersonalLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalTo(view).inset(20)
        }
        
        privateLabel.snp.makeConstraints { make in
            make.top.equalTo(PersonalLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view).inset(20)
        }
        
        createRecipeButton.snp.makeConstraints { make in
            make.top.equalTo(privateLabel.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
            make.height.equalTo(40)
            make.width.equalTo(210)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(createRecipeButton.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(view)
        }
    }
    
    func fetchRecipes() {
        startAnimatingIndicator()
        fetchRecipesFromFirestore { [weak self] in
            guard let self = self else { return }
            
            // Fetch recipes from Core Data
            let fetchRequest: NSFetchRequest<PersonalRecipe> = PersonalRecipe.fetchRequest()
            do {
                let fetchedRecipes = try self.context.fetch(fetchRequest)
                
                // Update the table view with the fetched recipes
                self.items = fetchedRecipes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateEmptyStateVisibility()
                    self.stopAnimatingIndicator()
                }
            } catch {
                print("Failed to fetch recipes from Core Data: \(error)")
            }
        }
    }

    
    func saveRecipeToFirestore(recipeDict: [String: Any], recipeID: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("perRecipes").document(recipeID).setData(recipeDict) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }

    
    func uploadImageToFirebaseStorage(imageData: Data, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageName = UUID().uuidString
        let imageRef = storageRef.child("perImage/\(imageName).jpg")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(nil)
                    return
                }
                
                completion(url?.absoluteString)
            }
        }
    }

    
    func saveRecipeWithImageToFirebase(recipe: PersonalRecipe) {
        if let imageData = recipe.perImage {
            // Upload image to Firebase Storage
            uploadImageToFirebaseStorage(imageData: imageData) { [weak self] imageURL in
                guard let self = self else { return }
                
                var recipeDict = recipe.toDictionary()
                if let imageURL = imageURL {
                    recipeDict["perImageURL"] = imageURL
                }
                
                // Save recipe to Firestore
                self.saveRecipeToFirestore(recipeDict: recipeDict, recipeID: recipe.perRecipeID ?? UUID().uuidString)
            }
        } else {
            // No image, save recipe directly to Firestore
            let recipeDict = recipe.toDictionary()
            saveRecipeToFirestore(recipeDict: recipeDict, recipeID: recipe.perRecipeID ?? UUID().uuidString)
        }
    }

    
    func fetchRecipesFromFirestore(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            completion()
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("perRecipes").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents from Firestore: \(error)")
                completion()
                return
            }
            guard let self = self else { return }
            
            let recipesDicts = querySnapshot?.documents.map { $0.data() } ?? []
            
            for recipeDict in recipesDicts {
                print("Fetched recipe data: \(recipeDict)") // Debugging statement
                if let recipe = self.recipeFromDictionary(data: recipeDict) {
                    self.saveRecipeToCoreData(recipe: recipe)
                }
            }
            completion()
        }
    }
    func saveRecipeToCoreData(recipe: PersonalRecipe) {
        do {
            try context.save()
            print("Core Data context saved successfully.")
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func recipeFromDictionary(data: [String: Any]) -> PersonalRecipe? {
        let fetchRequest: NSFetchRequest<PersonalRecipe> = PersonalRecipe.fetchRequest()

        guard let perRecipeID = data["perRecipeID"] as? String else {
            print("Missing perRecipeID in data")
            return nil
        }
        fetchRequest.predicate = NSPredicate(format: "perRecipeID == %@", perRecipeID)
        do {
            let results = try context.fetch(fetchRequest)
            let recipe: PersonalRecipe
            if let existingRecipe = results.first {
                recipe = existingRecipe
            } else {
                recipe = PersonalRecipe(context: self.context)
                recipe.perRecipeID = perRecipeID
            }
            recipe.perDescrip = data["perDescrip"] as? String
            recipe.perTitle = data["perTitle"] as? String
            recipe.perTimeSpent = data["perTimeSpent"] as? String

            if let ingredients = data["perIngredient"] as? [String] {
                recipe.perIngredient = Set(ingredients.map { ingredient in
                    let personalIngredient = PersonalIngredient(context: self.context)
                    personalIngredient.perIngredient = ingredient
                    return personalIngredient
                }) as NSSet
            }
            if let imageDataString = data["perImage"] as? String,
               let imageData = Data(base64Encoded: imageDataString) {
                recipe.perImage = imageData
            }

            recipe.perImageURL = data["perImageURL"] as? String

            return recipe
        } catch {
            print("Failed to fetch or create recipe from Core Data: \(error.localizedDescription)")
            return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! TableViewCell
        
        let item = items[indexPath.row]
        cell.configure(with: item, at: indexPath)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRecipe = items[indexPath.row]
        let viewRecipeVC = PerViewRecipe()
        viewRecipeVC.recipeID = selectedRecipe.perRecipeID
        viewRecipeVC.recipeTitleLabel.text = selectedRecipe.perTitle
        viewRecipeVC.recipeDesciptionLabel.text = "Description: \(selectedRecipe.perDescrip ?? "")"
        viewRecipeVC.recipeTimeSpentLabel.text = selectedRecipe.perTimeSpent

        if let imageData = selectedRecipe.perImage {
            if let thumbnail = ImageUtils.generateThumbnail(id: selectedRecipe.perRecipeID!, imageData: imageData) {
                viewRecipeVC.recipeImageView.image = thumbnail
            }
        }
        viewRecipeVC.ingredients = (selectedRecipe.perIngredient?.allObjects as? [PersonalIngredient]) ?? []
        navigationController?.pushViewController(viewRecipeVC, animated: true)
    }
}

@available(iOS 13.0, *)
extension ShowPersonalRecipeView: TableViewCellDelegate {
    func didTapDeleteButton(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete the Recipe?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            
            // Get the recipe to delete
            let recipeIndex = indexPath.row
            let recipeToDelete = self.items[recipeIndex]
            
            // First, delete the image from Firebase Storage if it exists
            if let imageURL = recipeToDelete.perImageURL {
                self.deleteImageFromFirebaseStorage(imageURL: imageURL) { [weak self] success in
                    if success {
                        // After deleting the image, delete the recipe from Firestore
                        self?.deleteRecipeFromFirestore(recipeID: recipeToDelete.perRecipeID ?? UUID().uuidString) { [weak self] success in
                            if success {
                                // Remove from Core Data if Firestore deletion was successful
                                self?.context.delete(recipeToDelete)
                                
                                do {
                                    try self?.context.save()
                                    // Update the UI
                                    self?.fetchRecipes()
                                } catch {
                                    print("Failed to delete recipe from Core Data: \(error)")
                                }
                            } else {
                                print("Failed to delete recipe from Firestore")
                            }
                        }
                    } else {
                        print("Failed to delete image from Firebase Storage")
                    }
                }
            } else {
                // No image URL, directly delete the recipe from Firestore
                self.deleteRecipeFromFirestore(recipeID: recipeToDelete.perRecipeID ?? UUID().uuidString) { [weak self] success in
                    if success {
                        // Remove from Core Data if Firestore deletion was successful
                        self?.context.delete(recipeToDelete)
                        
                        do {
                            try self?.context.save()
                            // Update the UI
                            self?.fetchRecipes()
                        } catch {
                            print("Failed to delete recipe from Core Data: \(error)")
                        }
                    } else {
                        print("Failed to delete recipe from Firestore")
                    }
                }
            }
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true)
    }
    
    func deleteImageFromFirebaseStorage(imageURL: String, completion: @escaping (Bool) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: imageURL)
        
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image from Firebase Storage: \(error)")
                completion(false)
            } else {
                print("Image successfully deleted from Firebase Storage!")
                completion(true)
            }
        }
    }
    
    func deleteRecipeFromFirestore(recipeID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("perRecipes").document(recipeID).delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
                completion(false)
            } else {
                print("Document successfully deleted!")
                completion(true)
            }
        }
    }
}

@available(iOS 13.0, *)
extension ShowPersonalRecipeView: saveRecipeToPerDelegate {
    func savePer(recipe: PersonalRecipe) {
        item = recipe
        saveRecipeWithImageToFirebase(recipe: recipe) // Save to Firebase including image if applicable
        fetchRecipes()
    }
}
