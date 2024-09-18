import UIKit

protocol RecipeCellDelegate: AnyObject {
    func didTapDeleteRecipe(at indexPath: IndexPath)
    func didTapDeleteIngredientButton(at indexPath: IndexPath, inSection section: Int)
}

@available(iOS 13.0, *)
class RecipeCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var ingredientsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Ingredient:"
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var deleteRecipeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(deleteRecipeAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var innerTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    weak var delegate: RecipeCellDelegate?
    var index: IndexPath?
    var innerTableViewHeightConstraint: NSLayoutConstraint!
    var ingredients: [ShoppingListIngredient] = [] {
        didSet {
            innerTableView.reloadData()
            innerTableViewHeightConstraint.constant = CGFloat(ingredients.count * 44)
            layoutIfNeeded()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        innerTableView.delegate = self
        innerTableView.dataSource = self
        innerTableView.register(IngredientsCell.self, forCellReuseIdentifier: "innerCell")
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ingredientsLabel)
        contentView.addSubview(innerTableView)
        contentView.addSubview(deleteRecipeButton)
        
        // Layout setup
        setupConstraints()
        
        // Apply initial color theme
        applyColorTheme()
        
        // Observe theme changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    
    private func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(15)
            make.height.width.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
            make.trailing.equalTo(deleteRecipeButton.snp.leading).offset(-15)
        }
        
        ingredientsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
            make.trailing.equalTo(contentView).offset(-15)
        }
        
        deleteRecipeButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.trailing.equalTo(contentView).offset(-15)
            make.width.height.equalTo(30)
        }
        
        innerTableView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(10)
            make.bottom.leading.trailing.equalTo(contentView)
        }
        
        innerTableViewHeightConstraint = innerTableView.heightAnchor.constraint(equalToConstant: 0)
        innerTableViewHeightConstraint.isActive = true
    }
    
    @objc private func handleUserInterfaceStyleChange() {
        applyColorTheme()
    }
    
    private func applyColorTheme() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let primaryColor = isDarkMode ? UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1) : UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let secondaryColor = isDarkMode ? UIColor.white : UIColor.black
        let backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        
        contentView.backgroundColor = backgroundColor
        titleLabel.textColor = secondaryColor
        ingredientsLabel.textColor = secondaryColor
        deleteRecipeButton.tintColor = primaryColor
        innerTableView.backgroundColor = backgroundColor
        
        // Update image view tint color
//        iconImageView.tintColor = isDarkMode ? .lightGray : .gray
    }

    func configure(with recipe: ShoppingListRecipe, at index: IndexPath) {
        self.index = index
        titleLabel.text = recipe.shopTitle
        ingredientsLabel.text = "Ingredients:"
        
        if recipe.shopRecipeID != nil {
            if let imageData = recipe.shopImage {
                if let thumbnail = ImageUtils.generateThumbnail(id: recipe.shopRecipeID!, imageData: imageData) {
                    iconImageView.contentMode = .scaleAspectFill
                    iconImageView.image = thumbnail
                }
            }
        } else {
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
            iconImageView.image = UIImage(systemName: "fork.knife") // Default placeholder image
        }
        
        if let recipeIngredients = recipe.shopIngredient?.allObjects as? [ShoppingListIngredient] {
            ingredients = recipeIngredients
        }
    }
    
    @objc func deleteRecipeAction(){
        guard index != nil else { return }
        delegate?.didTapDeleteRecipe(at: index!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "innerCell", for: indexPath) as? IngredientsCell else {
            return UITableViewCell()
        }
        let ingredient = ingredients[indexPath.row]
        cell.configure(with: ingredient, at: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
