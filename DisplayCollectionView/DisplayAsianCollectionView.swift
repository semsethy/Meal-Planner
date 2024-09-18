
import UIKit
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

class AsiaRecipes {
    var title: String?
    var description: String?
    var timeSpent: String?
    var recipeID: String?
    var ingredients: [String]?
    var imageURL: String?
    var imageData: Data?
    
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
class AsiaRecipeCache {
    private let cacheKey = "cachedRecipes"
    // Save cache to UserDefaults
    func saveToDisk(recipes: [AsiaRecipes]) {
        let recipesToEncode = recipes.map { recipe -> [String: Any?] in
            return [
                "asiaTitle": recipe.title,
                "asiaDescrip": recipe.description,
                "asiaTimeSpent": recipe.timeSpent,
                "asiaIngredient": recipe.ingredients,
                "asiaImageURL": recipe.imageURL,
                "asiaRecipeID": recipe.recipeID
            ]
        }
        if let encoded = try? JSONSerialization.data(withJSONObject: recipesToEncode, options: []) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    // Load cache from UserDefaults
    func loadFromDisk() -> [AsiaRecipes]? {
        if let savedData = UserDefaults.standard.data(forKey: cacheKey) {
            if let recipesArray = try? JSONSerialization.jsonObject(with: savedData, options: []) as? [[String: Any]] {
                return recipesArray.compactMap { dict -> AsiaRecipes? in
                    guard let title = dict["asiaTitle"] as? String,
                          let description = dict["asiaDescrip"] as? String,
                          let timeSpent = dict["asiaTimeSpent"] as? String,
                          let recipeID = dict["asiaRecipeID"] as? String else {
                        return nil
                    }
                    return AsiaRecipes(
                        title: title,
                        description: description,
                        timeSpent: timeSpent,
                        ingredients: dict["asiaIngredient"] as? [String],
                        imageURL: dict["asiaImageURL"] as? String,
                        recipeID: recipeID
                    )
                }
            }
        }
        return nil
    }
    // Add to in-memory cache
    func addToMemoryCache(recipe: AsiaRecipes) {
        if let recipeID = recipe.recipeID {
            inMemoryCache[recipeID] = recipe
        }
    }
    // Get from in-memory cache
    func getFromMemoryCache(recipeID: String) -> AsiaRecipes? {
        return inMemoryCache[recipeID]
    }
    // Remove from in-memory cache
    func removeFromMemoryCache(recipeID: String) {
        inMemoryCache.removeValue(forKey: recipeID)
    }
    // In-memory cache
    private var inMemoryCache: [String: AsiaRecipes] = [:]
}

@available(iOS 13.0, *)
class DisplayAsianCollectionView: UIViewController,NVActivityIndicatorViewable {
    let CollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let CancelButton = UIButton(type: .system)
    private var asiaRecipes: [AsiaRecipes] = []
    private let recipeCache = AsiaRecipeCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(CollectionView)
        
        navigationItem.title = "Asia Food"
        CollectionView.translatesAutoresizingMaskIntoConstraints = false
        CollectionView.register(DisplayCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
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
        db.collection("asiaRecipes").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents from Firestore: \(error)")
                return
            }
            
            guard let self = self else { return }
            
            self.asiaRecipes.removeAll()
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
                    self.asiaRecipes.append(recipe)
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.CollectionView.reloadData()
                self.recipeCache.saveToDisk(recipes: self.asiaRecipes)
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
    private func recipeFromDictionary(data: [String: Any]) -> AsiaRecipes? {
        guard let title = data["asiaTitle"] as? String,
              let description = data["asiaDescrip"] as? String,
              let recipeID = data["asiaRecipeID"] as? String,
              let timeSpent = data["asiaTimeSpent"] as? String else {
            print("Missing required fields in data")
            return nil
        }
        
        let recipe = AsiaRecipes(
            title: title,
            description: description,
            timeSpent: timeSpent,
            ingredients: data["asiaIngredient"] as? [String],
            imageURL: data["asiaImageURL"] as? String,
            recipeID: recipeID
        )
        
//        if let imageDataString = data["asiaImage"] as? String,
//           let imageData = Data(base64Encoded: imageDataString) {
//            recipe.imageData = imageData
//        }
        
        return recipe
    }
    func loadCachedRecipes() {
        if let cachedRecipes = recipeCache.loadFromDisk() {
            self.asiaRecipes = cachedRecipes
            self.CollectionView.reloadData()
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

@available(iOS 13.0, *)
extension DisplayAsianCollectionView: UICollectionViewDelegateFlowLayout {
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
extension DisplayAsianCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return asiaRecipes.count
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DisplayCollectionViewCell
//        cell.backgroundColor = .red
        let item = asiaRecipes[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = asiaRecipes[indexPath.row]
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
