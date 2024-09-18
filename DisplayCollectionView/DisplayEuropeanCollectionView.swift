
import UIKit
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

class EuropeanRecipes {
    var title: String?
    var description: String?
    var timeSpent: String?
    var recipeID: String?
    var ingredients: [String]?
    var imageURL: String?
    var imageData: Data? // Handle separately, not part of Codable
    
    // Initialize with optional parameters
    init(title: String? = nil, description: String? = nil, timeSpent: String? = nil, ingredients: [String]? = nil, imageURL: String? = nil, imageData: Data? = nil, recipeID: String? = nil) {
        self.title = title
        self.description = description
        self.timeSpent = timeSpent
        self.ingredients = ingredients
        self.imageURL = imageURL
        self.imageData = imageData
        self.recipeID = recipeID
    }
}
class EuropeRecipeCache {
    private let cacheKey = "cachedRecipes"
    // Save cache to UserDefaults
    func saveToDisk(recipes: [EuropeanRecipes]) {
        let recipesToEncode = recipes.map { recipe -> [String: Any?] in
            return [
                "europeTitle": recipe.title,
                "europeDescrip": recipe.description,
                "europeTimeSpent": recipe.timeSpent,
                "europeIngredient": recipe.ingredients,
                "europeImageURL": recipe.imageURL,
                "europeRecipeID": recipe.recipeID
            ]
        }
        if let encoded = try? JSONSerialization.data(withJSONObject: recipesToEncode, options: []) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    // Load cache from UserDefaults
    func loadFromDisk() -> [EuropeanRecipes]? {
        if let savedData = UserDefaults.standard.data(forKey: cacheKey) {
            if let recipesArray = try? JSONSerialization.jsonObject(with: savedData, options: []) as? [[String: Any]] {
                return recipesArray.compactMap { dict -> EuropeanRecipes? in
                    guard let title = dict["europeTitle"] as? String,
                          let description = dict["europeDescrip"] as? String,
                          let timeSpent = dict["europeTimeSpent"] as? String,
                          let recipeID = dict["europeRecipeID"] as? String else {
                        return nil
                    }
                    return EuropeanRecipes(
                        title: title,
                        description: description,
                        timeSpent: timeSpent,
                        ingredients: dict["europeIngredient"] as? [String],
                        imageURL: dict["europeImageURL"] as? String,
                        recipeID: recipeID
                    )
                }
            }
        }
        return nil
    }
    // Add to in-memory cache
    func addToMemoryCache(recipe: EuropeanRecipes) {
        if let recipeID = recipe.recipeID {
            inMemoryCache[recipeID] = recipe
        }
    }
    
    // Get from in-memory cache
    func getFromMemoryCache(recipeID: String) -> EuropeanRecipes? {
        return inMemoryCache[recipeID]
    }
    
    // Remove from in-memory cache
    func removeFromMemoryCache(recipeID: String) {
        inMemoryCache.removeValue(forKey: recipeID)
    }
    
    // In-memory cache
    private var inMemoryCache: [String: EuropeanRecipes] = [:]
}

@available(iOS 13.0, *)
class DisplayEuropeanCollectionView: UIViewController,NVActivityIndicatorViewable {
    let CollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let CancelButton = UIButton(type: .system)
    private var europeRecipes: [EuropeanRecipes] = []
    private let recipeCache = EuropeRecipeCache()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(CollectionView)
        
        navigationItem.title = "European Food"
        CollectionView.translatesAutoresizingMaskIntoConstraints = false
        CollectionView.register(EuropeanDisplayCell.self, forCellWithReuseIdentifier: "cell")
        
        CollectionView.keyboardDismissMode = .onDrag
        CollectionView.delegate = self
        CollectionView.dataSource = self
        CollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        fetchRecipesFromFirestore()
        let size = CGSize(width: 30.0, height: 30.0)
        startAnimating(size, message: "Loading", type: .ballRotateChase, color: .white, textColor: .white)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            // Stop animating after a delay
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        seUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
        
    }
    @objc private func handleUserInterfaceStyleChange() {
        seUIColor()
    }
    func seUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let backgroundColor: UIColor
        let collectionViewBackgroundColor: UIColor
        
        if isDarkMode {
            backgroundColor = UIColor(white: 0.1, alpha: 1) // Dark background
            collectionViewBackgroundColor = UIColor(white: 0.1, alpha: 1) // Slightly lighter dark background
        } else {
            backgroundColor = UIColor.white // Light background
            collectionViewBackgroundColor = UIColor.white // Standard light background
        }
        
        // Apply colors to UI elements
        view.backgroundColor = backgroundColor
        CollectionView.backgroundColor = collectionViewBackgroundColor
        
        // Configure UINavigationBar appearance
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
    func startAnimatingIndicator() {
        let size = CGSize(width: 30.0, height: 30.0)
        startAnimating(size, message: "Loading", type: .ballRotateChase, color: .white, textColor: .white)
    }

    func stopAnimatingIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    @objc func CancelButtonAction(){
        view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        fetchRecipesFromFirestore()
    }
    private func fetchRecipesFromFirestore() {
        startAnimatingIndicator()
        let db = Firestore.firestore()
        db.collection("europeRecipes").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents from Firestore: \(error)")
                return
            }
            guard let self = self else { return }
            self.europeRecipes.removeAll()
            let recipesDicts = querySnapshot?.documents.map { $0.data() } ?? []
            let dispatchGroup = DispatchGroup()
            for recipeDict in recipesDicts {
                if let recipe = self.recipeFromDictionary(data: recipeDict) {
                    
                    // Check if imageURL exists, and load image data
                    if let imageURL = recipe.imageURL {
                        dispatchGroup.enter()
                        self.loadImageData(from: imageURL) { data in
                            recipe.imageData = data
                            dispatchGroup.leave()
                        }
                    }
                    // Add to cache
                    self.recipeCache.addToMemoryCache(recipe: recipe)
                    self.europeRecipes.append(recipe)
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.CollectionView.reloadData()
                self.recipeCache.saveToDisk(recipes: self.europeRecipes)
                self.stopAnimatingIndicator()
            }
        }
    }
    func loadImageData(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                completion(nil)
                return
            }
            
            completion(data)
        }.resume()
    }
    private func recipeFromDictionary(data: [String: Any]) -> EuropeanRecipes? {
        guard let title = data["europeTitle"] as? String,
              let description = data["europeDescrip"] as? String,
              let recipeID = data["europeRecipeID"] as? String,
              let timeSpent = data["europeTimeSpent"] as? String else {
            print("Missing required fields in data")
            return nil
        }
        let recipe = EuropeanRecipes(
            title: title,
            description: description,
            timeSpent: timeSpent,
            ingredients: data["europeIngredient"] as? [String],
            imageURL: data["europeImageURL"] as? String,
            recipeID: recipeID
        )
        if let imageDataString = data["europeImage"] as? String,
           let imageData = Data(base64Encoded: imageDataString) {
            recipe.imageData = imageData
        }
        return recipe
    }
    func loadCachedRecipes() {
        if let cachedRecipes = recipeCache.loadFromDisk() {
            self.europeRecipes = cachedRecipes
            self.CollectionView.reloadData()
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        // Implement search filtering logic here
    }
}

@available(iOS 13.0, *)
extension DisplayEuropeanCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let size = width / 3 - 15
        let height = size * 1.35
        return CGSize(width: size, height: height - 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

@available(iOS 13.0, *)
extension DisplayEuropeanCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return europeRecipes.count
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EuropeanDisplayCell
//        cell.backgroundColor = .red
        let item = europeRecipes[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = europeRecipes[indexPath.row]
        let viewRecipeVC = RecommendRecipeView()
        
        viewRecipeVC.recipeTitleLabel.text = selectedRecipe.title
        viewRecipeVC.recipeDesciptionLabel.text = selectedRecipe.description
        viewRecipeVC.recipeTimeSpentLabel.text = selectedRecipe.timeSpent
        
        if let imageData = selectedRecipe.imageData {
            if let thumbnail = ImageUtils.generateThumbnail(id: selectedRecipe.recipeID!, imageData: imageData) {
                viewRecipeVC.recipeImageView.image = thumbnail
            }
        }
        viewRecipeVC.recipeID = selectedRecipe.recipeID
        viewRecipeVC.ingredient = selectedRecipe.ingredients ?? []
        navigationController?.pushViewController(viewRecipeVC, animated: true)
    }
}
