//
//  Wishlish.swift
//  Meal Preparing
//
//  Created by JoshipTy on 28/7/24.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended
import FirebaseAuth

@available(iOS 13.0, *)
extension FavoriteRecipe {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["favDescrip"] = favDescrip
        dict["favRecipeID"] = favRecipeID
        dict["favTimeSpent"] = favTimeSpent
        dict["favTitle"] = favTitle
        dict["favoIngredient"] = (favoIngredient as? Set<FavoriteIngredient>)?.map { $0.favIngredients ?? "" }
        // Convert image data to base64 string for Firebase storage
        if let imageData = favImage {
            dict["favImage"] = imageData.base64EncodedString()
        }
        if let imageURL = favImageURL {
            dict["favImageURL"] = imageURL
        }
        return dict
    }
}

@available(iOS 13.0, *)
class ShowFavRecipeView: UIViewController, UITableViewDataSource, UITableViewDelegate,NVActivityIndicatorViewable {
    
    static let shared = ShowFavRecipeView()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
//        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        return tableView
    }()
    private lazy var AllRecipeSavedLabel: UILabel = {
       let label = UILabel()
        label.text = "All Favorite Recipes"
        label.font = .boldSystemFont(ofSize: 23)
        return label
    }()
    private lazy var recipeCollectedLabel: UILabel = {
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
//            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items:[FavoriteRecipe] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "CollectionCell")
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(recipeCollectedLabel.snp.bottom).offset(20)
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
    func setUIColor(){
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let tableViewBackgroundColor: UIColor
        let personalLabelTextColor: UIColor
        let privateLabelTextColor: UIColor
        let emptyStateViewBackgroundColor: UIColor
        let emptyStateImageViewTintColor: UIColor
        let emptyStateLabelTextColor: UIColor
        let navigationBarAppearanceBackgroundColor: UIColor
        let navigationBarBorderColor: UIColor
        
        if isDarkMode {
            tableViewBackgroundColor = UIColor(white: 0.1, alpha: 1) // Dark background
            personalLabelTextColor = UIColor(white: 1, alpha: 1) // Light text color
            privateLabelTextColor = UIColor(white: 0.9, alpha: 1) // Light gray text
            emptyStateViewBackgroundColor = UIColor(white: 0.1, alpha: 1) // Darker background for empty state
            emptyStateImageViewTintColor = UIColor(white: 0.7, alpha: 1) // Light gray tint for image view
            emptyStateLabelTextColor = UIColor(white: 0.7, alpha: 1) // Light gray text for label
            navigationBarAppearanceBackgroundColor = UIColor(white: 0.1, alpha: 1) // Dark navigation bar
            navigationBarBorderColor = UIColor.white // White border for navigation bar
        } else {
            tableViewBackgroundColor = UIColor.white // Light background
            personalLabelTextColor = UIColor.black // Dark text color
            privateLabelTextColor = UIColor(white: 0.5, alpha: 1) // Gray text color
            emptyStateViewBackgroundColor = UIColor(white: 1, alpha: 1) // Light background for empty state
            emptyStateImageViewTintColor = UIColor.gray // Gray tint for image view
            emptyStateLabelTextColor = UIColor.gray // Gray text for label
            navigationBarAppearanceBackgroundColor = UIColor.white // Light navigation bar
            navigationBarBorderColor = UIColor.clear // No border for navigation bar
        }
        
        // Apply colors to UI elements
        view.backgroundColor = emptyStateViewBackgroundColor
        tableView.backgroundColor = tableViewBackgroundColor
        AllRecipeSavedLabel.textColor = personalLabelTextColor
        recipeCollectedLabel.textColor = privateLabelTextColor
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
    func setupUI() {
        view.addSubview(tableView)
        view.addSubview(AllRecipeSavedLabel)
        view.addSubview(recipeCollectedLabel)
        
        AllRecipeSavedLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalTo(view).inset(20)
        }
        recipeCollectedLabel.snp.makeConstraints { make in
            make.top.equalTo(AllRecipeSavedLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view).inset(20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(recipeCollectedLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalTo(view)
        }
    }
    func saveRecipeToFirestore(recipeDict: [String: Any], recipeID: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("favRecipes").document(recipeID).setData(recipeDict) { error in
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
        let imageRef = storageRef.child("favImage/\(imageName).jpg")
        
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
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
        uploadTask.resume() // Ensure the upload task is resumed
    }
    
    func saveRecipeWithImageToFirebase(recipe: FavoriteRecipe) {
        if let imageData = recipe.favImage {
            uploadImageToFirebaseStorage(imageData: imageData) { [weak self] imageURL in
                guard let self = self else { return }
                
                var recipeDict = recipe.toDictionary()
                if let imageURL = imageURL {
                    recipeDict["favImageURL"] = imageURL
                }
                
                self.saveRecipeToFirestore(recipeDict: recipeDict, recipeID: recipe.favRecipeID ?? UUID().uuidString)
            }
        } else {
            let recipeDict = recipe.toDictionary()
            saveRecipeToFirestore(recipeDict: recipeDict, recipeID: recipe.favRecipeID ?? UUID().uuidString)
        }
    }
    func removeRecipeFromFirestore(recipeID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("favRecipes").document(recipeID).delete { error in
            if let error = error {
                print("Error removing document: \(error)")
                completion(false)
            } else {
                print("Document successfully removed!")
                completion(true)
            }
        }
    }
    
    func fetchRecipes() {
        startAnimatingIndicator()
        fetchRecipesFromFirestore { [weak self] in
            guard let self = self else { return }
            
            // Fetch recipes from Core Data
            let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
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
    
    func recipeFromDictionary(data: [String: Any]) -> FavoriteRecipe? {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()

        guard let perRecipeID = data["favRecipeID"] as? String else {
            print("Missing perRecipeID in data")
            return nil
        }

        fetchRequest.predicate = NSPredicate(format: "favRecipeID == %@", perRecipeID)

        do {
            let results = try context.fetch(fetchRequest)
            let recipe: FavoriteRecipe
            if let existingRecipe = results.first {
                recipe = existingRecipe
            } else {
                recipe = FavoriteRecipe(context: self.context)
                recipe.favRecipeID = perRecipeID
            }
            recipe.favDescrip = data["favDescrip"] as? String
            recipe.favTitle = data["favTitle"] as? String
            recipe.favTimeSpent = data["favTimeSpent"] as? String

            if let ingredients = data["favoIngredient"] as? [String] {
                recipe.favoIngredient = Set(ingredients.map { ingredient in
                    let personalIngredient = FavoriteIngredient(context: self.context)
                    personalIngredient.favIngredients = ingredient
                    return personalIngredient
                }) as NSSet
            }

            if let imageDataString = data["favImage"] as? String,
               let imageData = Data(base64Encoded: imageDataString) {
                recipe.favImage = imageData
            }

            recipe.favImageURL = data["favImageURL"] as? String

            return recipe
        } catch {
            print("Failed to fetch or create recipe from Core Data: \(error.localizedDescription)")
            return nil
        }
    }
    func saveRecipeToCoreData(recipe: FavoriteRecipe) {
        do {
            try context.save()
            print("Core Data context saved successfully.")
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    func fetchRecipesFromFirestore(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            completion()
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("favRecipes").getDocuments { [weak self] (querySnapshot, error) in
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! TableViewCell
        
        let item = items[indexPath.row]
        cell.configureFav(with: item, at: indexPath)
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
        let viewRecipeVC  = FavViewRecipe()
        viewRecipeVC.recipeID = selectedRecipe.favRecipeID
        viewRecipeVC.recipeTitleLabel.text = selectedRecipe.favTitle
        viewRecipeVC.recipeDesciptionLabel.text = "Description: \(selectedRecipe.favDescrip ?? "")"
        viewRecipeVC.recipeTimeSpentLabel.text = selectedRecipe.favTimeSpent
        
        if let imageData = selectedRecipe.favImage {
            if let thumbnail = ImageUtils.generateThumbnail(id: selectedRecipe.favRecipeID!, imageData: imageData) {
                viewRecipeVC.recipeImageView.image = thumbnail
            }
        }
        viewRecipeVC.ingredients = (selectedRecipe.favoIngredient?.allObjects as? [FavoriteIngredient]) ?? []
        navigationController?.pushViewController(viewRecipeVC, animated: true)
    }

}
@available(iOS 13.0, *)
extension ShowFavRecipeView: TableViewCellDelegate{
    func didTapDeleteButton(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete the Recipe?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            
            // Get the recipe to delete
            let recipeIndex = indexPath.row
            let recipeToDelete = self.items[recipeIndex]
            
            // First, delete the image from Firebase Storage if it exists
            if let imageURL = recipeToDelete.favImageURL {
                self.deleteImageFromFirebaseStorage(imageURL: imageURL) { [weak self] success in
                    if success {
                        // After deleting the image, delete the recipe from Firestore
                        self?.deleteRecipeFromFirestore(recipeID: recipeToDelete.favRecipeID ?? UUID().uuidString) { [weak self] success in
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
                self.deleteRecipeFromFirestore(recipeID: recipeToDelete.favRecipeID ?? UUID().uuidString) { [weak self] success in
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
        db.collection("users").document(userID).collection("favRecipes").document(recipeID).delete { error in
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
