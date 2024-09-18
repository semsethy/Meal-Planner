import UIKit
import SnapKit
import FirebaseFirestore
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

struct AllRecipe {
    var title: String?
    var description: String?
    var timeSpent: String?
    var recipeID: String?
    var ingredients: [String]?
    var imageURL: String?
    var imageData: Data?
    // Optional image data for local usage
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
class AllRecipeCache {
    private let cacheKey = "cachedRecipes"
    // Save cache to UserDefaults
    func saveToDisk(recipes: [AllRecipe]) {
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
    func loadFromDisk() -> [AllRecipe]? {
        if let savedData = UserDefaults.standard.data(forKey: cacheKey) {
            if let recipesArray = try? JSONSerialization.jsonObject(with: savedData, options: []) as? [[String: Any]] {
                return recipesArray.compactMap { dict -> AllRecipe? in
                    guard let title = dict["europeTitle"] as? String,
                          let description = dict["europeDescrip"] as? String,
                          let timeSpent = dict["europeTimeSpent"] as? String,
                          let recipeID = dict["europeRecipeID"] as? String else {
                        return nil
                    }
                    return AllRecipe(
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
    func addToMemoryCache(recipe: AllRecipe) {
        if let recipeID = recipe.recipeID {
            inMemoryCache[recipeID] = recipe
        }
    }
    // Get from in-memory cache
    func getFromMemoryCache(recipeID: String) -> AllRecipe? {
        return inMemoryCache[recipeID]
    }
    // Remove from in-memory cache
    func removeFromMemoryCache(recipeID: String) {
        inMemoryCache.removeValue(forKey: recipeID)
    }
    // In-memory cache
    private var inMemoryCache: [String: AllRecipe] = [:]
}
class SearchViewController: UIViewController,NVActivityIndicatorViewable {

    // UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrowshape.turn.up.backward.fill"), for: .normal)
        
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Foodie"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        return titleLabel
    }()
    
    private var allRecipes: [AllRecipe] = []
    private var filteredRecipes: [AllRecipe] = []
    private let recipeCache = AllRecipeCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        setupSubviews()
        setupConstraints()
        configureCollectionView()
        
        // Load cached recipes first
        if let cachedRecipes = recipeCache.loadFromDisk() {
            allRecipes = cachedRecipes
            filteredRecipes = cachedRecipes
            collectionView.reloadData()
        }
        
        // Add tap gesture recognizer to dismiss the keyboard when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        collectionView.endEditing(true)
        collectionView.isUserInteractionEnabled = true
        
        setUIColor()
        fetchAllRecipesFromFirestore()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
        
    }
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    func startAnimatingIndicator() {
        let size = CGSize(width: 30.0, height: 30.0)
        startAnimating(size, message: "Loading", type: .ballRotateChase, color: .white, textColor: .white)
    }

    func stopAnimatingIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    private func setupSubviews() {
        view.addSubview(searchBar)
        view.addSubview(cancelButton)
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-1)
            make.leading.equalTo(view).offset(10)
            make.height.width.equalTo(40)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-9)
            make.leading.equalTo(cancelButton.snp.trailing).offset(10)
            make.trailing.equalTo(view).inset(12)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(5)
            make.leading.trailing.bottom.equalTo(view)
        }
    }
    func setUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let backgroundColor: UIColor
        let buttonTintColor: UIColor
        let collectionViewBackgroundColor: UIColor
        let titleLabelTextColor: UIColor
        let searchBarTintColor: UIColor
        let textFieldBackgroundColor: UIColor
        let textFieldTextColor: UIColor
        let placeholderTextColor: UIColor
        let navigationBarBackgroundColor: UIColor
        let navigationBarShadowColor: UIColor
        
        if isDarkMode {
            backgroundColor = UIColor(white: 0.1, alpha: 1)
            buttonTintColor = UIColor.white
            collectionViewBackgroundColor = UIColor(white: 0.1, alpha: 1)
            titleLabelTextColor = UIColor.white
            searchBarTintColor = UIColor.lightGray
            textFieldBackgroundColor = UIColor.darkGray
            textFieldTextColor = UIColor.white
            placeholderTextColor = UIColor(white: 0.8, alpha: 1)
            navigationBarBackgroundColor = UIColor(white: 0.1, alpha: 1)
            navigationBarShadowColor = UIColor.black
        } else {
            backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
            buttonTintColor = .white
            collectionViewBackgroundColor = .white
            titleLabelTextColor = .white
            searchBarTintColor = UIColor(white: 0.5, alpha: 1)
            textFieldBackgroundColor = UIColor.white
            textFieldTextColor = UIColor.black
            placeholderTextColor = UIColor(white: 0.5, alpha: 1)
            navigationBarBackgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
            navigationBarShadowColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        }
        // Apply colors
        view.backgroundColor = backgroundColor
        cancelButton.tintColor = buttonTintColor
        collectionView.backgroundColor = collectionViewBackgroundColor
        titleLabel.textColor = titleLabelTextColor
        searchBar.tintColor = searchBarTintColor
        
        let textField = searchBar.searchTextField
        textField.backgroundColor = textFieldBackgroundColor
        textField.textColor = textFieldTextColor
        
        let placeholderText = "Search Recipe..."
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderTextColor
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navigationBarBackgroundColor
        appearance.titleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor.black]
        appearance.shadowColor = isDarkMode ? UIColor.clear : UIColor.clear
        appearance.shadowColor = navigationBarShadowColor
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = isDarkMode ? UIColor.white : UIColor.black
    }

    override func viewWillAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
        setUIColor()
    }
    override func viewWillDisappear(_ animated: Bool) {
        fetchAllRecipesFromFirestore()
    }
    private func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SaerchCollectionCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
    }
    
    private func fetchAllRecipesFromFirestore() {
        startAnimatingIndicator()
        
        let db = Firestore.firestore()
        let collections = [
            ("recommendRecipes", "recommend"),
            ("asiaRecipes", "asia"),
            ("europeRecipes", "europe"),
            ("specialRecipes", "special")
        ]
        
        let dispatchGroup = DispatchGroup()
        var fetchedRecipes: [AllRecipe] = []
        
        // Loop through each collection and fetch data
        for (collectionName, type) in collections {
            dispatchGroup.enter()
            db.collection(collectionName).getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents from Firestore: \(error)")
                    dispatchGroup.leave()
                    return
                }
                
                guard let self = self else {
                    dispatchGroup.leave()
                    return
                }
                
                // Process each document in the snapshot
                let recipesDicts = querySnapshot?.documents.map { $0.data() } ?? []
                for recipeDict in recipesDicts {
                    if var recipe = self.recipeFromDictionary(data: recipeDict, type: type) {
                        // Load image data if needed
                        if let imageURL = recipe.imageURL {
                            dispatchGroup.enter()
                            self.loadImageData(from: imageURL) { data in
                                recipe.imageData = data
                                fetchedRecipes.append(recipe)
                                dispatchGroup.leave()
                            }
                        } else {
                            fetchedRecipes.append(recipe)
                        }
                    }
                }
                
                dispatchGroup.leave()
            }
        }
        // Notify when all collections are processed
        dispatchGroup.notify(queue: .main) {
            // Update UI with fetched recipes
            self.allRecipes = fetchedRecipes
            self.filteredRecipes = fetchedRecipes
            self.collectionView.reloadData()
            self.recipeCache.saveToDisk(recipes: fetchedRecipes)
            self.stopAnimatingIndicator()
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
    func loadCachedRecipes() {
        if let cachedRecipes = recipeCache.loadFromDisk() {
            self.filteredRecipes = cachedRecipes
            self.collectionView.reloadData()
        }
    }
    func recipeFromDictionary(data: [String: Any], type: String) -> AllRecipe? {
        var title: String?
        var description: String?
        var timeSpent: String?
        var recipeID: String?
        var ingredients: [String]?
        var imageURL: String?
        
        switch type {
        case "recommend":
            title = data["recommendTitle"] as? String
            description = data["recommendDescrip"] as? String
            timeSpent = data["recommendTimeSpent"] as? String
            recipeID = data["recommendRecipeID"] as? String
            ingredients = data["recommendIngredient"] as? [String]
            imageURL = data["recommendImageURL"] as? String
        case "asia":
            title = data["asiaTitle"] as? String
            description = data["asiaDescrip"] as? String
            timeSpent = data["asiaTimeSpent"] as? String
            recipeID = data["asiaRecipeID"] as? String
            ingredients = data["asiaIngredient"] as? [String]
            imageURL = data["asiaImageURL"] as? String
        case "europe":
            title = data["europeTitle"] as? String
            description = data["europeDescrip"] as? String
            timeSpent = data["europeTimeSpent"] as? String
            recipeID = data["europeRecipeID"] as? String
            ingredients = data["europeIngredient"] as? [String]
            imageURL = data["europeImageURL"] as? String
        case "special":
            title = data["specialTitle"] as? String
            description = data["specialDescrip"] as? String
            timeSpent = data["specialTimeSpent"] as? String
            recipeID = data["specialRecipeID"] as? String
            ingredients = data["specialIngredient"] as? [String]
            imageURL = data["specialImageURL"] as? String
        default:
            return nil
        }
        
        guard let finalTitle = title, let finalDescription = description, let finalTimeSpent = timeSpent, let finalRecipeID = recipeID else {
            print("Missing required fields in data")
            return nil
        }
        
        return AllRecipe(
            title: finalTitle,
            description: finalDescription,
            timeSpent: finalTimeSpent,
            ingredients: ingredients,
            imageURL: imageURL,
            recipeID: finalRecipeID
        )
    }

    private func fetchImageData(from url: URL, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to load image data: \(String(describing: error))")
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }
    
    private func filterRecipes(for query: String) {
        if query.isEmpty {
            filteredRecipes = allRecipes
        } else {
            filteredRecipes = allRecipes.filter { recipe in
                recipe.title!.lowercased().contains(query.lowercased())
            }
        }
        collectionView.reloadData()
    }
    
    @objc private func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
  
}

@available(iOS 13.0, *)
extension SearchViewController: UICollectionViewDelegateFlowLayout {
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
        return UIEdgeInsets(top: 10, left: 10, bottom: 5, right: 10)
    }
}

@available(iOS 13.0, *)
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SaerchCollectionCell
        let item = filteredRecipes[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = filteredRecipes[indexPath.row]
        let viewRecipeVC = RecommendRecipeView()
        
        // Pass the recipe details to the RecommendRecipeView
        viewRecipeVC.recipeTitleLabel.text = selectedRecipe.title
        viewRecipeVC.recipeDesciptionLabel.text = selectedRecipe.description
        viewRecipeVC.recipeTimeSpentLabel.text = selectedRecipe.timeSpent
        
        // If imageData is available, set it to the image view
        if let imageData = selectedRecipe.imageData {
            if let thumbnail = ImageUtils.generateThumbnail(id: selectedRecipe.recipeID!, imageData: imageData) {
                viewRecipeVC.recipeImageView.image = thumbnail
            }
        }
        // Pass additional recipe details if needed
        viewRecipeVC.recipeID = selectedRecipe.recipeID
        viewRecipeVC.ingredient = selectedRecipe.ingredients ?? []
        
        navigationController?.pushViewController(viewRecipeVC, animated: true)
    }
}

@available(iOS 13.0, *)
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterRecipes(for: searchText)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterRecipes(for: "")
        searchBar.resignFirstResponder()
    }
}
