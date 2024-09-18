import UIKit
import Alamofire
import FirebaseAuth
import NVActivityIndicatorViewExtended
import CoreData
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView

extension Recipes {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["day"] = day
        dict["descrip"] = descrip
        dict["selectedDate"] = selectedDate.flatMap { Timestamp(date: $0) }
        dict["recipeID"] = recipeID
        dict["remindMe"] = remindMe
        dict["timeSpent"] = timeSpent
        dict["title"] = title
        dict["mealTime"] = mealTime.flatMap { Timestamp(date: $0) }
        dict["ingredients"] = (ingredients as? Set<Ingredients>)?.map { $0.ingredients ?? "" }
        // Convert image data to base64 string for Firebase storage
        if let imageData = image {
            dict["image"] = imageData.base64EncodedString()
        }
        if let imageURL = imageURL {
            dict["imageURL"] = imageURL
        }
        return dict
    }
    func update(from dictionary: [String: Any], context: NSManagedObjectContext) {
        self.day = dictionary["day"] as? String
        self.descrip = dictionary["descrip"] as? String
        self.selectedDate = (dictionary["selectedDate"] as? Timestamp)?.dateValue()
        self.recipeID = dictionary["recipeID"] as? String
        if let remindMeValue = dictionary["remindMe"] as? Bool {
            self.remindMe = remindMeValue
        }
        self.timeSpent = dictionary["timeSpent"] as? String
        self.title = dictionary["title"] as? String
        self.mealTime = (dictionary["mealTime"] as? Timestamp)?.dateValue()
        if let ingredientsArray = dictionary["ingredients"] as? [String] {
            let ingredientsSet = Set(ingredientsArray.map { ingredientName in
                let fetchRequest: NSFetchRequest<Ingredients> = Ingredients.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "ingredients == %@", ingredientName)
                if let existingIngredient = try? context.fetch(fetchRequest).first {
                    return existingIngredient
                } else {
                    let newIngredient = Ingredients(context: context)
                    newIngredient.ingredients = ingredientName
                    return newIngredient
                }
            })
            self.ingredients = ingredientsSet as NSSet
        }
        // Handle image data (base64 encoded string to Data)
        if let imageBase64 = dictionary["image"] as? String,
           let imageData = Data(base64Encoded: imageBase64) {
            self.image = imageData
        }
        self.imageURL = dictionary["imageURL"] as? String
    }
}
//extension UIColor {
//    static func themeBackgroundColor(isDarkMode: Bool) -> UIColor {
//        return isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 0.95, alpha: 1)
//    }
//    
//    static func themeButtonColor(isDarkMode: Bool) -> UIColor {
//        return isDarkMode ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.9, alpha: 1)
//    }
//    
//    static func themeTextColor(isDarkMode: Bool) -> UIColor {
//        return isDarkMode ? UIColor.white : UIColor.black
//    }
//}

@available(iOS 13.0, *)
class Plan: UIViewController, UITableViewDelegate, UITableViewDataSource,NVActivityIndicatorViewable {
    
    let outerTableView = UITableView(frame: .zero, style: .grouped)
    let dayTitles = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var innerTableData = [[Recipes]]()
    var selectedSection: Int?
    
    private lazy var clearScheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
//        button.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.tintColor = .red
        button.addTarget(self, action: #selector(clearScheduleButtonAction), for: .touchUpInside)
        return button
    }()
    
    let previousWeekButton = UIButton()
    let nextWeekButton = UIButton()
    let weekLabel = UILabel()
    var selectedStartDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Meal Planner"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: clearScheduleButton)
        clearScheduleButton.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
        setupWeekNavigation()
        setupTableView()
        fetchRecipesForCurrentWeek()
        
        let size = CGSize(width: 30.0, height: 30.0)
        startAnimating(size, message: "Loading", type: .ballRotateChase, color: .white, textColor: .white)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Stop animating after a delay
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
//        applyColorTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    func startAnimatingIndicator() {
        let size = CGSize(width: 30.0, height: 30.0)
        startAnimating(size, message: "Loading", type: .ballRotateChase, color: .white, textColor: .white)
    }

    func stopAnimatingIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    func setupWeekNavigation() {
        previousWeekButton.setTitle("<", for: .normal)
        previousWeekButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        previousWeekButton.setTitleColor(UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1), for: .normal)
        previousWeekButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
        nextWeekButton.setTitle(">", for: .normal)
        nextWeekButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextWeekButton.setTitleColor(UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1), for: .normal)
        nextWeekButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
        weekLabel.textAlignment = .center
        weekLabel.textColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        weekLabel.font = .boldSystemFont(ofSize: 16)
        if #available(iOS 15.0, *) {
            weekLabel.backgroundColor = UIColor(white: 0.9, alpha: 1)
        }
        
        previousWeekButton.addTarget(self, action: #selector(goToPreviousWeek), for: .touchUpInside)
        nextWeekButton.addTarget(self, action: #selector(goToNextWeek), for: .touchUpInside)
        
        let weekNavigationStack = UIStackView(arrangedSubviews: [previousWeekButton, weekLabel, nextWeekButton])
        weekNavigationStack.axis = .horizontal
        weekNavigationStack.distribution = .fillEqually
        weekNavigationStack.layer.cornerRadius = 20
        weekNavigationStack.clipsToBounds = true
        
        view.addSubview(weekNavigationStack)
        weekNavigationStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        updateWeekLabel()
    }
    @objc private func handleUserInterfaceStyleChange() {
        applyColorTheme()
    }
    override func viewWillAppear(_ animated: Bool) {
        applyColorTheme()
        outerTableView.reloadData()
    }
    func applyColorTheme() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Background color
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        
        // Buttons
        previousWeekButton.setTitleColor(isDarkMode ? UIColor.white : UIColor.black, for: .normal)
        previousWeekButton.backgroundColor = isDarkMode ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.95, alpha: 1)
        nextWeekButton.setTitleColor(isDarkMode ? UIColor.white : UIColor.black, for: .normal)
        nextWeekButton.backgroundColor = previousWeekButton.backgroundColor // Match nextWeekButton color to previousWeekButton
        
        // Labels
        weekLabel.textColor = isDarkMode ? UIColor.white : UIColor.black
        weekLabel.backgroundColor = isDarkMode ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.95, alpha: 1)
        
        // Table View
        outerTableView.backgroundColor = isDarkMode ? UIColor(white: 0.15, alpha: 1) : UIColor(white: 0.95, alpha: 1)
        
        // Clear Schedule Button
        clearScheduleButton.tintColor = isDarkMode ? UIColor.red : UIColor.red
        
        // Navigation Bar Appearance
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

    func syncRecipeToFirestore(recipe: Recipes) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        let recipeDict = recipe.toDictionary()
        
        db.collection("users").document(userID).collection("recipes").document(recipe.recipeID!).setData(recipeDict) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
    }
    
    func saveRecipeToFirestore(recipeDict: [String: Any], recipeID: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("recipes").document(recipeID).setData(recipeDict) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
    }

    func uploadImageToFirebaseStorage(imageData: Data, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageName = UUID().uuidString
        let imageRef = storageRef.child("images/\(imageName).jpg")
        
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
                
                // Return the download URL
                completion(url?.absoluteString)
            }
        }
    }
    func saveRecipeWithImageToFirebase(recipe: Recipes) {
        if let imageData = recipe.image {
            // Upload image and save recipe with image URL
            uploadImageToFirebaseStorage(imageData: imageData) { [weak self] imageURL in
                guard let self = self else { return }
                
                var recipeDict = recipe.toDictionary()
                if let imageURL = imageURL {
                    recipeDict["imageURL"] = imageURL
                }
                
                // Save updated recipe with image URL
                self.saveRecipeToFirestore(recipeDict: recipeDict, recipeID: recipe.recipeID ?? UUID().uuidString)
            }
        } else {
            // No image to upload, save the recipe directly
            let recipeDict = recipe.toDictionary()
            saveRecipeToFirestore(recipeDict: recipeDict, recipeID: recipe.recipeID ?? UUID().uuidString)
        }
    }

    func fetchRecipesFromFirestore(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("recipes").getDocuments { [weak self] (querySnapshot, error) in
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
    func saveRecipeToCoreData(recipe: Recipes) {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    func recipeFromDictionary(data: [String: Any]) -> Recipes? {
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
        
        if let recipeID = data["recipeID"] as? String {
            fetchRequest.predicate = NSPredicate(format: "recipeID == %@", recipeID)
            do {
                let results = try context.fetch(fetchRequest)
                if let recipe = results.first {
                    recipe.update(from: data, context: context)
                    return recipe
                }
            } catch {
                print("Failed to fetch recipe from Core Data: \(error)")
            }
        }
        // Create a new recipe if it doesn't exist
        let newRecipe = Recipes(context: context)
        newRecipe.update(from: data, context: context)
        return newRecipe
    }
    func loadImage(from imageURL: String, into imageView: UIImageView) {
        let storage = Storage.storage().reference(forURL: imageURL)
        storage.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
    func setupTableView() {
        outerTableView.delegate = self
        outerTableView.dataSource = self
        outerTableView.register(DayCell.self, forCellReuseIdentifier: "dayCell")
        outerTableView.rowHeight = UITableView.automaticDimension
        outerTableView.estimatedRowHeight = 100
        outerTableView.separatorStyle = .none
        outerTableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.addSubview(outerTableView)
        outerTableView.snp.makeConstraints { make in
            make.top.equalTo(weekLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(view)
        }
    }
    @objc func clearScheduleButtonAction() {
        let alert = UIAlertController(title: "Clear Schedule", message: "Are you sure you want to clear the schedule?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let clear = UIAlertAction(title: "Clear", style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            self.startAnimatingIndicator()
            
            let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
            do {
                let recipes = try self.context.fetch(fetchRequest)
                // Collect recipe IDs and image URLs
                let recipesToDelete = recipes.map { (recipe: Recipes) -> (id: String, imageURL: String?) in
                    return (id: recipe.recipeID ?? "", imageURL: recipe.imageURL)
                }
                
                // Delete Core Data entries
                for recipe in recipes {
                    self.context.delete(recipe)
                }
                try self.context.save()
                
                // Attempt to delete from Firestore if internet is available
                if NetworkReachabilityManager()?.isReachable == true {
                    let group = DispatchGroup()
                    var deletionSuccess = true
                    
                    for recipe in recipesToDelete {
                        group.enter()
                        self.deleteRecipeFromFirestore(recipeID: recipe.id, imageURL: recipe.imageURL) { success in
                            if !success {
                                deletionSuccess = false
                            }
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        if deletionSuccess {
                            print("All recipes and associated images successfully deleted from Firestore!")
                        } else {
                            print("Some recipes or images failed to delete from Firestore.")
                        }
                        // Refresh the table view
                        self.fetchRecipesForCurrentWeek()
                        self.stopAnimatingIndicator()
                    }
                } else {
                    // No internet, only local deletion completed
                    print("No internet connection. Recipes cleared locally.")
                    self.fetchRecipesForCurrentWeek()
                    self.stopAnimatingIndicator()
                }
                
            } catch {
                print("Failed to fetch recipes for deletion: \(error)")
                self.stopAnimatingIndicator()
            }
        }
        alert.addAction(cancel)
        alert.addAction(clear)
        present(alert, animated: true)
    }

    @objc func goToPreviousWeek() {
        selectedStartDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedStartDate)!
        updateWeekLabel()
        fetchRecipesForCurrentWeek()
    }
    @objc func goToNextWeek() {
        selectedStartDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedStartDate)!
        updateWeekLabel()
        fetchRecipesForCurrentWeek()
    }
    
    func updateWeekLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: selectedStartDate)!
        weekLabel.text = "\(formatter.string(from: selectedStartDate)) – \(formatter.string(from: endDate))"
    }
    
    func fetchRecipesForCurrentWeek() {
        startAnimatingIndicator()
        let calendar = Calendar.current
        var currentWeekRecipes = [[Recipes]](repeating: [], count: 7)
        
        let startOfWeek = calendar.startOfDay(for: selectedStartDate)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        print("Fetching recipes from Firebase Firestore...")
        
        // Fetch recipes from Firestore
        fetchRecipesFromFirestore { [weak self] in
            guard let self = self else { return }
            
            // Fetch recipes from Core Data
            let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
            do {
                let fetchedRecipes = try self.context.fetch(fetchRequest)
                for recipe in fetchedRecipes {
                    if let recipeDate = recipe.selectedDate {
                        let startOfRecipeDate = calendar.startOfDay(for: recipeDate)

                        if startOfRecipeDate >= startOfWeek && startOfRecipeDate <= endOfWeek {
                            let dayIndex = calendar.dateComponents([.day], from: startOfWeek, to: startOfRecipeDate).day!
                            
                            if dayIndex >= 0 && dayIndex < 7 {
                                currentWeekRecipes[dayIndex].append(recipe)
                                print("Recipe for date \(startOfRecipeDate) is assigned to dayIndex \(dayIndex) within the current week.")
                            }
                        }
                    }
                }
                // Update the table view with the fetched recipes
                self.innerTableData = currentWeekRecipes
                DispatchQueue.main.async {
                    self.outerTableView.reloadData()
                    self.stopAnimatingIndicator()
                }
            } catch {
                print("Failed to fetch recipes from Core Data: \(error)")
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dayIndex = indexPath.section
        let calendar = Calendar.current
        let dateForDay = calendar.date(byAdding: .day, value: dayIndex, to: selectedStartDate)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as? DayCell else {
            return UITableViewCell()
        }
        
        
        guard dayIndex >= 0 && dayIndex < innerTableData.count else {
            cell.titleLabel.text = formatter.string(from: dateForDay)
            cell.items = []
            return cell
        }

        let items = innerTableData[dayIndex]
        
        cell.sectionIndex = dayIndex
        cell.titleLabel.text = formatter.string(from: dateForDay)
        cell.items = items
        cell.descriptionLabel.text = items.isEmpty ? "Nothing Scheduled" : ""
        cell.delegate = self
        cell.selectionStyle = .none
        cell.presentAlert = { [weak self] alert in
            self?.present(alert, animated: true, completion: nil)
        }
        
        cell.innerTableViewHeightConstraint.constant = CGFloat(items.count * 80)
        cell.innerTableView.reloadData()
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

@available(iOS 13.0, *)
extension Plan: DayCellDelegate {
    func didSetMealTimeRecipe(at indexPath: IndexPath) {
        let view = MealTimePickerViewController()
        let dayIndex = indexPath.section
        let recipeIndex = indexPath.row
        let recipe = innerTableData[dayIndex][recipeIndex]
        view.selectedDate = recipe.selectedDate
        view.recipe = recipe
        view.indexPath = indexPath
        view.initialTime = recipe.mealTime
        view.initialRemindMe = recipe.remindMe
        view.delegate = self
        view.hidesBottomBarWhenPushed = true
        
        let navigationController = UINavigationController(rootViewController: view)
        present(navigationController, animated: true, completion: nil)
    }
    
    func didDeleteRecipe(at indexPath: IndexPath) {
        let dayIndex = indexPath.section
        let recipeIndex = indexPath.row
        let recipeToDelete = innerTableData[dayIndex][recipeIndex]
        
        // Delete recipe from Firestore
        if let recipeID = recipeToDelete.recipeID {
            deleteRecipeFromFirestore(recipeID: recipeID, imageURL: recipeToDelete.imageURL) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    // Delete recipe from Core Data
                    self.deleteRecipeFromCoreData(recipe: recipeToDelete)
                    
                    // Update the table view
                    if let dayCell = self.outerTableView.cellForRow(at: IndexPath(row: 0, section: dayIndex)) as? DayCell {
                        dayCell.items = self.innerTableData[dayIndex]
                    }
                    self.fetchRecipesForCurrentWeek()
                    self.outerTableView.reloadSections(IndexSet(integer: dayIndex), with: .automatic)
                }
            }
        }
    }
    func deleteRecipeFromFirestore(recipeID: String, imageURL: String?, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        let recipeRef = db.collection("users").document(userID).collection("recipes").document(recipeID)
        
        // Delete the recipe document
        recipeRef.delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
                completion(false)
                return
            }
            // If there is an imageURL, delete the image from Firebase Storage
            if let imageURL = imageURL {
                let storageRef = Storage.storage().reference(forURL: imageURL)
                storageRef.delete { error in
                    if let error = error {
                        print("Error deleting image: \(error)")
                        completion(false)
                    } else {
                        print("Image successfully deleted!")
                        completion(true)
                    }
                }
            } else {
                // No imageURL to delete
                print("No image associated with this recipe.")
                completion(true)
            }
        }
    }

    func deleteRecipeFromCoreData(recipe: Recipes) {
        context.delete(recipe)
        do {
            try context.save()
        } catch {
            print("Failed to delete recipe from Core Data: \(error)")
        }
    }

    func didSelectRecipe(_ recipe: Recipes) {
        let viewRecipeVC = ViewRecipe()
        viewRecipeVC.recipe = recipe
        
        viewRecipeVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewRecipeVC, animated: true)
        fetchRecipesForCurrentWeek()
    }
    
    func didTapFavorite(for section: Int) {
        let view = FavoriteRecipeAdded()
        selectedSection = section
        view.selectedSection = section
        view.delegate = self
        view.modalPresentationStyle = .fullScreen
        present(view, animated: true)
    }
    
    func didTapCreateNew(for section: Int) {
        let view = CreateRecipeViewController()
        selectedSection = section
        view.selectedSection = section
        view.delegate = self
        view.modalPresentationStyle = .fullScreen
        present(view, animated: true)
    }
    
    func didTapAddPersonal(for section: Int) {
        let view = PersonalRecipeAdded()
        selectedSection = section
        view.selectedSection = section
        view.delegate = self
        view.modalPresentationStyle = .fullScreen
        present(view, animated: true)
    }
}

@available(iOS 13.0, *)
extension Plan: saveRecipeDelegate {
    func saveRecipe(recipe: Recipes) {
        guard let selectedSection = selectedSection else { return }
        let calendar = Calendar.current
        if let exactDateForDay = calendar.date(byAdding: .day, value: selectedSection, to: selectedStartDate) {
            recipe.selectedDate = exactDateForDay
        }
        try? context.save()
        saveRecipeWithImageToFirebase(recipe: recipe)
        fetchRecipesForCurrentWeek()
    }
}

@available(iOS 13.0, *)
extension Plan: AddPersonalRecipeToPlanDelegate {
    func savePersonalRecipe(recipe: Recipes) {
        guard let selectedSection = selectedSection else { return }
        let calendar = Calendar.current
        if let exactDateForDay = calendar.date(byAdding: .day, value: selectedSection, to: selectedStartDate) {
            recipe.selectedDate = exactDateForDay
        }
        try? context.save()
        saveRecipeWithImageToFirebase(recipe: recipe)
        fetchRecipesForCurrentWeek()
    }
}

@available(iOS 13.0, *)
extension Plan: AddFavoriteRecipeToPlanDelegate {
    func saveFavoriteRecipe(recipe: Recipes) {
        guard let selectedSection = selectedSection else { return }
        let calendar = Calendar.current
        if let exactDateForDay = calendar.date(byAdding: .day, value: selectedSection, to: selectedStartDate) {
            recipe.selectedDate = exactDateForDay
        }
        try? context.save()
        saveRecipeWithImageToFirebase(recipe: recipe)
        fetchRecipesForCurrentWeek()
    }
}

@available(iOS 13.0, *)
extension Plan: MealTimePickerDelegate {
    func didSelectMealTime(for updatedRecipe: Recipes) {
        guard let selectedMealTime = updatedRecipe.mealTime else { return }
        
        let calendar = Calendar.current
        
        if let recipeDate = updatedRecipe.selectedDate {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: recipeDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedMealTime)
            
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            
            if let updatedMealTime = calendar.date(from: dateComponents) {
                updatedRecipe.mealTime = updatedMealTime
            }
        }
        do {
            try context.save()
        } catch {
            print("Failed to save updated recipe: \(error)")
        }
        syncRecipeToFirestore(recipe: updatedRecipe)
        fetchRecipesForCurrentWeek()
    }
}
