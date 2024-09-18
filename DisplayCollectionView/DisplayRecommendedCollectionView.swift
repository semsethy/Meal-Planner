import UIKit
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

// Define your `recommandRecipes` model
class recommandRecipes {
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

// RecipeCache class
class RecipeCache {
    private let cacheKey = "cachedRecipes"
    // Save cache to UserDefaults
    func saveToDisk(recipes: [recommandRecipes]) {
        let recipesToEncode = recipes.map { recipe -> [String: Any?] in
            return [
                "title": recipe.title,
                "description": recipe.description,
                "timeSpent": recipe.timeSpent,
                "ingredients": recipe.ingredients,
                "imageURL": recipe.imageURL,
                "recipeID": recipe.recipeID
            ]
        }
        if let encoded = try? JSONSerialization.data(withJSONObject: recipesToEncode, options: []) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    // Load cache from UserDefaults
    func loadFromDisk() -> [recommandRecipes]? {
        if let savedData = UserDefaults.standard.data(forKey: cacheKey) {
            if let recipesArray = try? JSONSerialization.jsonObject(with: savedData, options: []) as? [[String: Any]] {
                return recipesArray.compactMap { dict -> recommandRecipes? in
                    guard let title = dict["title"] as? String,
                          let description = dict["description"] as? String,
                          let timeSpent = dict["timeSpent"] as? String,
                          let recipeID = dict["recipeID"] as? String else {
                        return nil
                    }
                    return recommandRecipes(
                        title: title,
                        description: description,
                        timeSpent: timeSpent,
                        ingredients: dict["ingredients"] as? [String],
                        imageURL: dict["imageURL"] as? String,
                        recipeID: recipeID
                    )
                }
            }
        }
        return nil
    }
    // Add to in-memory cache
    func addToMemoryCache(recipe: recommandRecipes) {
        if let recipeID = recipe.recipeID {
            inMemoryCache[recipeID] = recipe
        }
    }
    // Get from in-memory cache
    func getFromMemoryCache(recipeID: String) -> recommandRecipes? {
        return inMemoryCache[recipeID]
    }
    // Remove from in-memory cache
    func removeFromMemoryCache(recipeID: String) {
        inMemoryCache.removeValue(forKey: recipeID)
    }
    // In-memory cache
    private var inMemoryCache: [String: recommandRecipes] = [:]
}

@available(iOS 13.0, *)
class DisplayRecommendedCollectionView: UIViewController,NVActivityIndicatorViewable {
    static let shared = DisplayRecommendedCollectionView()
    let CollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let CancelButton = UIButton(type: .system)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var recipe:[Recipes] = []
    
    private var recommendRecipes: [recommandRecipes] = []
    private let recipeCache = RecipeCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(CollectionView)
        
//        navigationController?.navigationBar.backgroundColor = .white
        navigationItem.title = "Recommended For You"
        CollectionView.translatesAutoresizingMaskIntoConstraints = false
        CollectionView.register(SeeAllRecommendCell.self, forCellWithReuseIdentifier: "cell")
        
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
    func startAnimatingIndicator() {
        let size = CGSize(width: 30.0, height: 30.0)
        startAnimating(size, message: "Loading", type: .ballRotateChase, color: .white, textColor: .white)
    }

    func stopAnimatingIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
    override func viewWillDisappear(_ animated: Bool) {
        fetchRecipesFromFirestore()
    }
    func fetchRecipesFromFirestore() {
        startAnimatingIndicator()
        let db = Firestore.firestore()
        db.collection("recommendRecipes").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents from Firestore: \(error)")
                return
            }
            
            guard let self = self else { return }
            
            self.recommendRecipes.removeAll()
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
                    self.recommendRecipes.append(recipe)
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.CollectionView.reloadData()
                self.recipeCache.saveToDisk(recipes: self.recommendRecipes)
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

    func recipeFromDictionary(data: [String: Any]) -> recommandRecipes? {
        guard let title = data["recommendTitle"] as? String,
              let description = data["recommendDescrip"] as? String,
              let timeSpent = data["recommendTimeSpent"] as? String,
              let recipeID = data["recommendRecipeID"] as? String else {
            print("Missing required fields in data")
            return nil
        }
        
        let recipe = recommandRecipes(
            title: title,
            description: description,
            timeSpent: timeSpent,
            ingredients: data["recommendIngredient"] as? [String],
            imageURL: data["recommendImageURL"] as? String,
            recipeID: recipeID
        )
        
        return recipe
    }

    func loadCachedRecipes() {
        if let cachedRecipes = recipeCache.loadFromDisk() {
            self.recommendRecipes = cachedRecipes
            self.CollectionView.reloadData()
        }
    }
    @objc func CancelButtonAction(){
        view.endEditing(true)
    }
    
}

@available(iOS 13.0, *)
extension DisplayRecommendedCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let size = width - 10
        let height = size * 0.6
        return CGSize(width: width - 40, height: height - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}

@available(iOS 13.0, *)
extension DisplayRecommendedCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SeeAllRecommendCell
        let item = recommendRecipes[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = recommendRecipes[indexPath.row]
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
