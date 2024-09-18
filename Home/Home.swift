import UIKit
import CoreData
import ImageSlideshow
import SnapKit
import SkeletonView
import FirebaseFirestore
import FirebaseStorage

class AllRecipes {
    var title: String?
    var description: String?
    var timeSpent: String?
    var recipeID: String?
    var ingredients: [String]?
    var imageURL: String?
    var imageData: Data?
    
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
@available(iOS 13.0, *)
class Home: UIViewController, UISearchBarDelegate {
    
    let scrollView = UIScrollView()
    let topView = UIView()
    let bottomView = UIView()
    private let searchController = UISearchController(searchResultsController: nil)
    let specialLabel = UILabel()
    let seeAllButtonSpecial = UIButton(type: .system)
    let seeAllButtonRecommend = UIButton(type: .system)
    let slideshow = ImageSlideshow()
    let recomLabel = UILabel()
    let AsiaLabel = UILabel()
    let seeAllButtonAsia = UIButton(type: .system)
    let seeAllButtonEuro = UIButton(type: .system)
    let EuropeanLabel = UILabel()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var allRecipe: [AllRecipes] = []
    private var selectedButton: UIButton?
    static var hasShownSkeletonView = false
    
    
    private let RecommendedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isSkeletonable = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private let AsiaCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isSkeletonable = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private let ItalianCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isSkeletonable = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    var perRecipe:[Recipes] = []
    var favRecipe:[FavoriteRecipe] = []
    var PersoRecipe:[PersonalRecipe] = []
    private var recommendRecipes: [recommandRecipes] = []
    private var specialRecipes: [SpecialRecipes] = []
    private let specialrecipeCache = SpecialRecipeCache()
    private let recipeCache = RecipeCache()
    private var asiaRecipes: [AsiaRecipes] = []
    private let asiarecipeCache = AsiaRecipeCache()
    private var europeRecipes: [EuropeanRecipes] = []
    private let europerecipeCache = EuropeRecipeCache()
    let titleLabel = UILabel()
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        button.addTarget(self, action: #selector(notificationAction), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(bottomView)
        view.addSubview(topView)
        UISearchBar.appearance().backgroundImage = UIImage()
        titleLabel.text = "Foodie"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        topView.addSubview(titleLabel)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationButton)
        
        bottomView.addSubview(specialLabel)
        bottomView.addSubview(seeAllButtonSpecial)
        bottomView.addSubview(seeAllButtonRecommend)
        bottomView.addSubview(slideshow)
        bottomView.addSubview(recomLabel)
        bottomView.addSubview(RecommendedCollectionView)
        bottomView.addSubview(AsiaLabel)
        bottomView.addSubview(seeAllButtonAsia)
        bottomView.addSubview(AsiaCollectionView)
        bottomView.addSubview(EuropeanLabel)
        bottomView.addSubview(seeAllButtonEuro)
        bottomView.addSubview(ItalianCollectionView)
        
        specialLabel.text = "#SpecialForYou"
        specialLabel.font = .boldSystemFont(ofSize: 20)
        
        seeAllButtonSpecial.setTitle("See All", for: .normal)
        seeAllButtonSpecial.titleLabel?.font = .systemFont(ofSize: 13)
        seeAllButtonSpecial.addTarget(self, action: #selector(seeAllButtonActionSpecialAction), for: .touchUpInside)
        
        seeAllButtonRecommend.setTitle("See All", for: .normal)
        seeAllButtonRecommend.titleLabel?.font = .systemFont(ofSize: 13)
        seeAllButtonRecommend.addTarget(self, action: #selector(seeAllButtonRecommendAction), for: .touchUpInside)
        
        seeAllButtonAsia.setTitle("See All", for: .normal)
        seeAllButtonAsia.titleLabel?.font = .systemFont(ofSize: 13)
        seeAllButtonAsia.addTarget(self, action: #selector(seeAllButtonAsiaAction), for: .touchUpInside)
        
        seeAllButtonEuro.setTitle("See All", for: .normal)
        seeAllButtonEuro.titleLabel?.font = .systemFont(ofSize: 13)
        seeAllButtonEuro.addTarget(self, action: #selector(seeAllButtonEuroAction), for: .touchUpInside)
        
        recomLabel.text = "Recommended For You"
        recomLabel.font = .boldSystemFont(ofSize: 20)
        
        AsiaLabel.text = "Asian Food"
        AsiaLabel.font = .boldSystemFont(ofSize: 20)
        
        EuropeanLabel.text = "European Food"
        EuropeanLabel.font = .boldSystemFont(ofSize: 20)
        
        setupSearchController()
        setupConstraints()
        collectionViewSetUp()
        setupSlideshow()
        
        fetchSpecialRecipesFromFirestore()
        fetchRecommendRecipesFromFirestore()
        fetchAsiaRecipesFromFirestore()
        fetchEuropeRecipesFromFirestore()
        setupColors()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc func notificationAction(){
        let view = NotificationHistoryViewController()
        
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    @objc private func handleUserInterfaceStyleChange() {
        setupColors()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColors()
    }
    func setupColors() {
        // Determine if dark mode is enabled
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light mode
        let lightPrimaryColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let lightSecondaryColor = UIColor.white
        let lightLabelTextColor = UIColor.black
        let lightButtonTextColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let lightTextFieldBackgroundColor = UIColor(white: 1, alpha: 1)
        let lightTextFieldTextColor = UIColor.black
        
        // Define colors for dark mode
        let darkSecondaryColor = UIColor(white: 0.1, alpha: 1)
        let darkLabelTextColor = UIColor.white
        let darkButtonTextColor = UIColor.lightGray
        let darkTextFieldBackgroundColor = UIColor(white: 0.3, alpha: 1)
        let darkTextFieldTextColor = UIColor.white
        
        // Set colors based on current mode
        let primaryColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : lightPrimaryColor
        let primaryColor1 = isDarkMode ? UIColor(white: 0.1, alpha: 1) : lightPrimaryColor
        let secondaryColor = isDarkMode ? darkSecondaryColor : lightSecondaryColor
        let labelTextColor = isDarkMode ? darkLabelTextColor : lightLabelTextColor
        let buttonTextColor = isDarkMode ? darkButtonTextColor : lightButtonTextColor
        let textFieldBackgroundColor = isDarkMode ? darkTextFieldBackgroundColor : lightTextFieldBackgroundColor
        let textFieldTextColor = isDarkMode ? darkTextFieldTextColor : lightTextFieldTextColor

        // Set colors for labels
        specialLabel.textColor = labelTextColor
        recomLabel.textColor = labelTextColor
        AsiaLabel.textColor = labelTextColor
        EuropeanLabel.textColor = labelTextColor
        titleLabel.textColor = .white
        
        // Set colors for buttons
        seeAllButtonSpecial.tintColor = buttonTextColor
        seeAllButtonRecommend.tintColor = buttonTextColor
        seeAllButtonAsia.tintColor = buttonTextColor
        seeAllButtonEuro.tintColor = buttonTextColor
        
        // Set background colors
        view.backgroundColor = secondaryColor
        topView.backgroundColor = primaryColor
        bottomView.backgroundColor = secondaryColor
        RecommendedCollectionView.backgroundColor = secondaryColor
        AsiaCollectionView.backgroundColor = secondaryColor
        ItalianCollectionView.backgroundColor = secondaryColor
        
        // Configure collection views
        RecommendedCollectionView.isSkeletonable = true
        AsiaCollectionView.isSkeletonable = true
        ItalianCollectionView.isSkeletonable = true
        
        // Configure search bar
        searchController.searchBar.tintColor = UIColor.blue
        let textField = searchController.searchBar.searchTextField
        textField.backgroundColor = textFieldBackgroundColor
        textField.textColor = textFieldTextColor
        let placeholderText = "Search Recipe..."
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isDarkMode ? UIColor(white: 0.8, alpha: 1) : UIColor(white: 0.5, alpha: 1)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        searchController.searchBar.tintColor = UIColor.white
        
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = primaryColor1
        appearance.shadowColor = primaryColor1
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.resignFirstResponder()
        fetchSpecialRecipesFromFirestore()
        fetchRecommendRecipesFromFirestore()
        fetchAsiaRecipesFromFirestore()
        fetchEuropeRecipesFromFirestore()
    }
    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.modalTransitionStyle = .crossDissolve
        searchVC.modalPresentationStyle = .fullScreen
        present(searchVC, animated: true)
    }
    func fetchSpecialRecipesFromFirestore() {
        let db = Firestore.firestore()
        db.collection("specialRecipes").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents from Firestore: \(error)")
                return
            }
            guard let self = self else { return }
            self.specialRecipes.removeAll()
            let recipesDicts = querySnapshot?.documents.map { $0.data() } ?? []
            let dispatchGroup = DispatchGroup()
            for recipeDict in recipesDicts {
                if let recipe = self.specialRecipeFromDictionary(data: recipeDict) {
                    // Check if imageURL exists, and load image data
                    if let imageURL = recipe.imageURL {
                        dispatchGroup.enter()
                        self.loadImageData(from: imageURL) { data in
                            recipe.imageData = data
                            dispatchGroup.leave()
                        }
                    }
                    // Add to cache
                    self.specialrecipeCache.addToMemoryCache(recipe: recipe)
                    self.specialRecipes.append(recipe)
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.specialrecipeCache.saveToDisk(recipes: self.specialRecipes)
                self.setupSlideshow()
            }
        }
    }
    func fetchRecommendRecipesFromFirestore() {
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
                self.RecommendedCollectionView.reloadData()
                self.recipeCache.saveToDisk(recipes: self.recommendRecipes)
                self.setupSlideshow()
            }
        }
    }
    func fetchAsiaRecipesFromFirestore() {
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
                if let recipe = self.asiaRecipeFromDictionary(data: recipeDict) {
                    // Check if imageURL exists, and load image data
                    if let imageURL = recipe.imageURL {
                        dispatchGroup.enter()
                        self.loadImageData(from: imageURL) { data in
                            recipe.imageData = data
                            dispatchGroup.leave()
                        }
                    }
                    // Add to cache
                    self.asiarecipeCache.addToMemoryCache(recipe: recipe)
                    self.asiaRecipes.append(recipe)
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.AsiaCollectionView.reloadData()
                self.asiarecipeCache.saveToDisk(recipes: self.asiaRecipes)
            }
        }
    }
    func fetchEuropeRecipesFromFirestore() {
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
                if let recipe = self.europeRecipeFromDictionary(data: recipeDict) {
                    // Check if imageURL exists, and load image data
                    if let imageURL = recipe.imageURL {
                        dispatchGroup.enter()
                        self.loadImageData(from: imageURL) { data in
                            recipe.imageData = data
                            dispatchGroup.leave()
                        }
                    }
                    // Add to cache
                    self.europerecipeCache.addToMemoryCache(recipe: recipe)
                    self.europeRecipes.append(recipe)
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.ItalianCollectionView.reloadData()
                self.europerecipeCache.saveToDisk(recipes: self.europeRecipes)
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
    func specialRecipeFromDictionary(data: [String: Any]) -> SpecialRecipes? {
        guard let title = data["specialTitle"] as? String,
              let description = data["specialDescrip"] as? String,
              let timeSpent = data["specialTimeSpent"] as? String,
              let recipeID = data["specialRecipeID"] as? String else {
            print("Missing required fields in data")
            return nil
        }
        
        let recipe = SpecialRecipes(
            title: title,
            description: description,
            timeSpent: timeSpent,
            ingredients: data["specialIngredient"] as? [String],
            imageURL: data["specialImageURL"] as? String,
            recipeID: recipeID
        )
        
        return recipe
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
    func asiaRecipeFromDictionary(data: [String: Any]) -> AsiaRecipes? {
        guard let title = data["asiaTitle"] as? String,
              let description = data["asiaDescrip"] as? String,
              let timeSpent = data["asiaTimeSpent"] as? String,
              let recipeID = data["asiaRecipeID"] as? String else {
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
        
        return recipe
    }
    func europeRecipeFromDictionary(data: [String: Any]) -> EuropeanRecipes? {
        guard let title = data["europeTitle"] as? String,
              let description = data["europeDescrip"] as? String,
              let timeSpent = data["europeTimeSpent"] as? String,
              let recipeID = data["europeRecipeID"] as? String else {
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
        
        return recipe
    }
    func loadCachedRecipes() {
        if let cachedRecipes = recipeCache.loadFromDisk() {
            self.recommendRecipes = cachedRecipes
            self.RecommendedCollectionView.reloadData()
        }
    }
    func asiaLoadCachedRecipes() {
        if let cachedRecipes = asiarecipeCache.loadFromDisk() {
            self.asiaRecipes = cachedRecipes
            self.AsiaCollectionView.reloadData()
        }
    }
    func europeLoadCachedRecipes() {
        if let cachedRecipes = europerecipeCache.loadFromDisk() {
            self.europeRecipes = cachedRecipes
            self.ItalianCollectionView.reloadData()
        }
    }

    private func setupConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(150)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        bottomView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        specialLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomView).offset(20)
            make.leading.equalTo(bottomView).offset(10)
            make.trailing.lessThanOrEqualTo(bottomView).offset(-20)
        }
        
        seeAllButtonSpecial.snp.makeConstraints { make in
            make.top.equalTo(specialLabel)
            make.trailing.equalTo(bottomView).offset(-10)
            make.bottom.equalTo(specialLabel)
        }
        
        slideshow.snp.makeConstraints { make in
            make.top.equalTo(specialLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(bottomView).inset(10)
            make.height.equalTo(230)
        }
        
        recomLabel.snp.makeConstraints { make in
            make.top.equalTo(slideshow.snp.bottom).offset(20)
            make.leading.equalTo(bottomView).offset(10)
            make.trailing.lessThanOrEqualTo(bottomView).offset(-20)
        }
        
        seeAllButtonRecommend.snp.makeConstraints { make in
            make.top.equalTo(recomLabel)
            make.trailing.equalTo(bottomView).offset(-10)
            make.bottom.equalTo(recomLabel)
        }
        
        RecommendedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(recomLabel.snp.bottom).offset(10)
            make.leading.equalTo(bottomView)
            make.trailing.equalTo(bottomView)
            make.height.equalTo(230)
        }
        
        AsiaLabel.snp.makeConstraints { make in
            make.top.equalTo(RecommendedCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(bottomView).offset(10)
            make.trailing.lessThanOrEqualTo(bottomView).offset(-10)
        }
        seeAllButtonAsia.snp.makeConstraints { make in
            make.top.equalTo(AsiaLabel)
            make.trailing.equalTo(bottomView).offset(-10)
            make.bottom.equalTo(AsiaLabel)
        }
        AsiaCollectionView.snp.makeConstraints { make in
            make.top.equalTo(AsiaLabel.snp.bottom).offset(10)
            make.leading.equalTo(bottomView)
            make.trailing.equalTo(bottomView)
            make.height.equalTo(210)
        }
        EuropeanLabel.snp.makeConstraints { make in
            make.top.equalTo(AsiaCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(bottomView).offset(10)
            make.trailing.lessThanOrEqualTo(bottomView).offset(-10)
        }
        seeAllButtonEuro.snp.makeConstraints { make in
            make.top.equalTo(EuropeanLabel)
            make.trailing.equalTo(bottomView).offset(-10)
            make.bottom.equalTo(EuropeanLabel)
        }
        ItalianCollectionView.snp.makeConstraints { make in
            make.top.equalTo(EuropeanLabel.snp.bottom).offset(10)
            make.leading.equalTo(bottomView)
            make.trailing.equalTo(bottomView)
            make.height.equalTo(210)
            make.bottom.equalTo(bottomView).offset(-20)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        if !Home.hasShownSkeletonView {
            // Set the collection views to be skeletonable
            self.RecommendedCollectionView.isSkeletonable = true
            self.AsiaCollectionView.isSkeletonable = true
            self.ItalianCollectionView.isSkeletonable = true

            // Define the skeleton gradient based on dark mode
            let skeletonBaseColor: UIColor = isDarkMode ? UIColor(white: 0.3, alpha: 1) : UIColor(white: 0.9, alpha: 1)
            let skeletonGradient = SkeletonGradient(baseColor: skeletonBaseColor)
            
            // Show the skeleton view with animation
            RecommendedCollectionView.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: nil, transition: .crossDissolve(0.25))
            AsiaCollectionView.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: nil, transition: .crossDissolve(0.25))
            ItalianCollectionView.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: nil, transition: .crossDissolve(0.25))

            // After a delay, hide the skeleton view and reload data
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.RecommendedCollectionView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self.ItalianCollectionView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self.AsiaCollectionView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                
                // Set the flag to true to indicate the skeleton view has been shown
                Home.hasShownSkeletonView = true
            }
        }
    }

    @objc func seeAllButtonAsiaAction() {
        let view = DisplayAsianCollectionView()
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    
    @objc func seeAllButtonEuroAction() {
        let view = DisplayEuropeanCollectionView()
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    @objc func seeAllButtonActionSpecialAction() {
        let view = DisplaySpecialCollectionView()
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    
    
    @objc func seeAllButtonRecommendAction() {
        let view = DisplayRecommendedCollectionView()
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }

    private func setupSlideshow() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"

        let imageInputs = specialRecipes.compactMap { recipe -> ImageSource? in
            guard let imageData = recipe.imageData, let image = UIImage(data: imageData) else {
                print("Invalid image data for recipe: \(recipe.title ?? "")")
                return nil
            }
            return ImageSource(image: image)
        }

        slideshow.slideshowInterval = 3.0
        slideshow.setImageInputs(imageInputs)
        slideshow.contentScaleMode = .scaleAspectFill
        slideshow.circular = true
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
        slideshow.pageIndicator = UIPageControl()
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self
        slideshow.layer.cornerRadius = 20

        // Configure skeleton view for dark mode
        if !Home.hasShownSkeletonView {
            slideshow.isSkeletonable = true

            let skeletonBaseColor: UIColor = isDarkMode ? UIColor(white: 0.3, alpha: 1) : UIColor(white: 0.9, alpha: 1)
            let skeletonGradient = SkeletonGradient(baseColor: skeletonBaseColor)

            slideshow.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: nil, transition: .crossDissolve(0.25))

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Adjust the delay as needed
                self.slideshow.stopSkeletonAnimation()
                self.slideshow.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            }
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSlideshow))
        slideshow.addGestureRecognizer(gestureRecognizer)
    }

    @objc private func didTapSlideshow() {
        let pageIndex = slideshow.currentPage
        guard pageIndex < specialRecipes.count else {
            print("Invalid pageIndex: \(pageIndex)")
            return
        }
        
        let selectedRecipe = specialRecipes[pageIndex]
        let recipeDetailVC = RecommendRecipeView()
        recipeDetailVC.recipeID = selectedRecipe.recipeID
        recipeDetailVC.recipeTitleLabel.text = selectedRecipe.title
        recipeDetailVC.recipeDesciptionLabel.text = "Direction: \n\n\(selectedRecipe.description ?? "")"
        recipeDetailVC.recipeTimeSpentLabel.text = selectedRecipe.timeSpent
        
        if let imageData = selectedRecipe.imageData {
            if let thumbnail = ImageUtils.generateThumbnail(id: selectedRecipe.recipeID!, imageData: imageData) {
                recipeDetailVC.recipeImageView.image = thumbnail
            }
        }
        
        recipeDetailVC.hidesBottomBarWhenPushed = true
        recipeDetailVC.ingredient = selectedRecipe.ingredients ?? []
        navigationController?.pushViewController(recipeDetailVC, animated: true)
    }
    func collectionViewSetUp() {
        RecommendedCollectionView.register(RecommendedCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        RecommendedCollectionView.keyboardDismissMode = .onDrag
        RecommendedCollectionView.delegate = self
        RecommendedCollectionView.dataSource = self
        RecommendedCollectionView.isSkeletonable = true
        
        AsiaCollectionView.register(KhmerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        AsiaCollectionView.keyboardDismissMode = .onDrag
        AsiaCollectionView.delegate = self
        AsiaCollectionView.dataSource = self
        
        ItalianCollectionView.register(ItalianCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        ItalianCollectionView.keyboardDismissMode = .onDrag
        ItalianCollectionView.delegate = self
        ItalianCollectionView.dataSource = self
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        RecommendedCollectionView.collectionViewLayout.invalidateLayout()
        AsiaCollectionView.collectionViewLayout.invalidateLayout()
        ItalianCollectionView.collectionViewLayout.invalidateLayout()
    }
}

@available(iOS 13.0, *)
extension Home: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.RecommendedCollectionView {
            return recommendRecipes.count
        } else if collectionView == self.AsiaCollectionView {
            return asiaRecipes.count // Number of items in the third collection view
        } else if collectionView == self.ItalianCollectionView {
            return europeRecipes.count // Number of items in the third collection view
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.RecommendedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecommendedCollectionViewCell
            let item = recommendRecipes[indexPath.row]
            cell.configure(with: item)
            cell.isSkeletonable = true
            
            return cell
        } else if collectionView == self.AsiaCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! KhmerCollectionViewCell
            let item = asiaRecipes[indexPath.row]
            cell.configure(with: item)
            cell.isSkeletonable = true
            return cell
        } else if collectionView == self.ItalianCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItalianCollectionViewCell
            let item = europeRecipes[indexPath.row]
            cell.configure(with: item)
            cell.isSkeletonable = true
            return cell
            
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.RecommendedCollectionView {
            let selectedRecipe = recommendRecipes[indexPath.row]
            let viewRecipeVC = RecommendRecipeView()
            
            viewRecipeVC.recipeTitleLabel.text = selectedRecipe.title
            viewRecipeVC.recipeDesciptionLabel.text = "Direction: \n\n\(selectedRecipe.description ?? "")"
            viewRecipeVC.recipeTimeSpentLabel.text = selectedRecipe.timeSpent
            
            if let imageData = selectedRecipe.imageData {
                if let thumbnail = ImageUtils.generateThumbnail(id: selectedRecipe.recipeID!, imageData: imageData) {
                    viewRecipeVC.recipeImageView.image = thumbnail
                }
            }
            viewRecipeVC.recipeID = selectedRecipe.recipeID
            viewRecipeVC.ingredient = selectedRecipe.ingredients ?? []
            viewRecipeVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewRecipeVC, animated: true)
        } else if collectionView == self.AsiaCollectionView {
            let selectedRecipe = asiaRecipes[indexPath.row]
            let viewRecipeVC = RecommendRecipeView()

            viewRecipeVC.recipeTitleLabel.text = selectedRecipe.title
            viewRecipeVC.recipeDesciptionLabel.text = "Direction: \n\n\(selectedRecipe.description ?? "")"
            viewRecipeVC.recipeTimeSpentLabel.text = selectedRecipe.timeSpent

            if let imageData = selectedRecipe.imageData {
                if let thumbnail = ImageUtils.generateThumbnail(id: selectedRecipe.recipeID!, imageData: imageData) {
                    viewRecipeVC.recipeImageView.image = thumbnail
                }
            }
            viewRecipeVC.recipeID = selectedRecipe.recipeID
            viewRecipeVC.ingredient = selectedRecipe.ingredients ?? []
            viewRecipeVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewRecipeVC, animated: true)
        } else if collectionView == self.ItalianCollectionView {
            let selectedRecipe = europeRecipes[indexPath.row]
            let viewRecipeVC = RecommendRecipeView()

            viewRecipeVC.recipeTitleLabel.text = selectedRecipe.title
            viewRecipeVC.recipeDesciptionLabel.text = "Direction: \n\n\(selectedRecipe.description ?? "")"
            viewRecipeVC.recipeTimeSpentLabel.text = selectedRecipe.timeSpent

            if let imageData = selectedRecipe.imageData {
                if let thumbnail = ImageUtils.generateThumbnail(id: selectedRecipe.recipeID!, imageData: imageData) {
                    viewRecipeVC.recipeImageView.image = thumbnail
                }
            }
            viewRecipeVC.recipeID = selectedRecipe.recipeID
            viewRecipeVC.ingredient = selectedRecipe.ingredients ?? []
            viewRecipeVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewRecipeVC, animated: true)
        }
    }
}
@available(iOS 13.0, *)
extension Home: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didTapAt index: Int) {
        let detailVC = ImageSliceShowView()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
@available(iOS 13.0, *)
extension Home: UICollectionViewDelegateFlowLayout,SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "cell"
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if skeletonView == RecommendedCollectionView || skeletonView == AsiaCollectionView || skeletonView == ItalianCollectionView {
            return 10 // Placeholder value; adjust as needed
        }
        return 0
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.isSkeletonable = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.RecommendedCollectionView {
            return 2
        } else if collectionView == self.AsiaCollectionView {
            return 2
        } else if collectionView == self.ItalianCollectionView {
            return 2
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.RecommendedCollectionView {
            return 10
        } else if collectionView == self.AsiaCollectionView {
            return 10
        } else if collectionView == self.ItalianCollectionView {
            return 10
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.RecommendedCollectionView {
            let height = collectionView.frame.height
            let itemWidth = height * 0.8
            return CGSize(width: itemWidth, height: height)
        } else if collectionView == self.AsiaCollectionView {
            let height = collectionView.frame.height
            let itemWidth = height * 0.7
            return CGSize(width: itemWidth, height: height)
        } else if collectionView == self.ItalianCollectionView {
            let height = collectionView.frame.height
            let itemWidth = height * 0.7
            return CGSize(width: itemWidth, height: height)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.RecommendedCollectionView {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        } else if collectionView == self.AsiaCollectionView {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        } else if collectionView == self.ItalianCollectionView {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        }
        return .zero
    }
}
