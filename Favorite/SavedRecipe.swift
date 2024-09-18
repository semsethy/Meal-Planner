import UIKit

@available(iOS 13.0, *)
class SavedRecipe: UIViewController, UISearchResultsUpdating, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties
    let collectionsLabel = UILabel()
    let collectionView: UICollectionView

    // MARK: - Initializers
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyColorTheme() // Apply color theme when the view loads
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        applyColorTheme()
    }
    private func setupUI() {
        setupCollectionsLabel()
        setupCollectionView()
    }
    
    private func setupCollectionsLabel() {
        collectionsLabel.text = "Collections"
        collectionsLabel.textAlignment = .center
        collectionsLabel.font = UIFont.boldSystemFont(ofSize: 25)
        view.addSubview(collectionsLabel)
        
        collectionsLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalTo(view).inset(20)
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SavedRecipeCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(collectionsLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalTo(view)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Implement search results update
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! SavedRecipeCollectionViewCell
        if indexPath.row == 0 {
            cell.titleLabel.text = "All Personal Recipes"
            cell.iconImageView.image = UIImage(systemName: "fork.knife")
        } else {
            cell.titleLabel.text = "All Favorite Recipes"
            cell.iconImageView.image = UIImage(systemName: "heart")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewController = ShowPersonalRecipeView()
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            let viewController = ShowFavRecipeView()
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    // MARK: - CollectionView DelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: 80)
    }

    // MARK: - Apply Color Theme
    private func applyColorTheme() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"

        // Define colors based on dark mode preference
        let backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor.white
        let textColor = isDarkMode ? UIColor.white : UIColor.black

        // Apply colors
        view.backgroundColor = backgroundColor
        collectionsLabel.textColor = textColor

        collectionView.backgroundColor = backgroundColor
        collectionView.indicatorStyle = isDarkMode ? .white : .default // Scroll indicator color

        // Customize UINavigationBar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: textColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        appearance.shadowColor = isDarkMode ? UIColor.clear : UIColor.clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = textColor
    }



}
