import UIKit
import FirebaseStorage
import CoreData

protocol InnerTableViewCellDelegate: AnyObject {
    func didTapDeleteButton(at indexPath: IndexPath)
    func didTapSetMealTime(at indexPath: IndexPath)
}

@available(iOS 13.0, *)
class InnerTableViewCell: UITableViewCell {
    
    weak var delegate: InnerTableViewCellDelegate?
    var indexPath: IndexPath?
    var item: Recipes? // Single recipe item
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var iconTimeSpent: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "alarm.fill")
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var timeSpentLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var setMealTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.clipsToBounds = true
        
        return label
    }()
    
    private lazy var optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        
        if #available(iOS 16.0, *) {
            button.addTarget(self, action: #selector(optionAction), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
        }
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(optionButton)
        contentView.addSubview(iconTimeSpent)
        contentView.addSubview(timeSpentLabel)
        contentView.addSubview(setMealTimeLabel)
        setupConstraints()
        applyColorTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        applyColorTheme()
    }
    private func applyColorTheme() {
        // Fetch the user interface style from UserDefaults
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let backgroundColorLight = UIColor.white
        let backgroundColorDark = UIColor(white: 0.1, alpha: 1)
        
        let textColorLight = UIColor.black
        let textColorDark = UIColor.white
        
        let descriptionColorLight = UIColor.gray
        let descriptionColorDark = UIColor.lightGray
        
        let tintColorLight = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let tintColorDark = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)  // Adjust if needed
        
        // Apply colors based on the current interface style
        contentView.backgroundColor = isDarkMode ? backgroundColorDark : backgroundColorLight
        optionButton.tintColor = isDarkMode ? tintColorDark : tintColorLight
        setMealTimeLabel.textColor = isDarkMode ? textColorDark : UIColor.white
        timeSpentLabel.textColor = isDarkMode ? textColorDark : textColorLight
        descriptionLabel.textColor = isDarkMode ? descriptionColorDark : descriptionColorLight
        titleLabel.textColor = isDarkMode ? textColorDark : textColorLight
        iconTimeSpent.tintColor = isDarkMode ? tintColorDark : tintColorLight
    }

    private func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(25)
            make.height.width.equalTo(60)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
        }
        optionButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).offset(-20)
            make.width.height.equalTo(30)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
            make.trailing.equalTo(contentView).offset(-55)
        }
        iconTimeSpent.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(7)
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
            make.width.height.equalTo(15)
        }
        timeSpentLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(7)
            make.leading.equalTo(iconTimeSpent.snp.trailing).offset(5)
            make.width.equalTo(95)
        }
        setMealTimeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentView).inset(10)
            make.trailing.equalTo(contentView).offset(-55)
            make.leading.equalTo(timeSpentLabel.snp.trailing).offset(10)
            make.height.equalTo(18)
        }
    }
    
    func configure(with recipe: Recipes, at indexPath: IndexPath) {
        self.item = recipe
        self.indexPath = indexPath
        titleLabel.text = recipe.title
        descriptionLabel.text = recipe.descrip
        timeSpentLabel.text = recipe.timeSpent
        // Format mealTime to "hh:mm a" format
        if let mealTime = recipe.mealTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"  // 12-hour format with AM/PM
            let formattedMealTime = dateFormatter.string(from: mealTime)
            setMealTimeLabel.text = "Cooking at: \(formattedMealTime)"
            setMealTimeLabel.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
            setMealTimeLabel.isHidden = false // Ensure label is visible when mealTime is set
        } else {
            setMealTimeLabel.isHidden = true // Hide the label if no mealTime is set
        }

        if let imageData = recipe.image {
            if let thumbnail = ImageUtils.generateThumbnail(id: recipe.recipeID!, imageData: imageData) {
                iconImageView.image = thumbnail
            }
        }
        if let imageURL = recipe.imageURL {
            loadImage(from: imageURL, index: indexPath)
        }
    }
    
    func loadImage(from imageURL: String, index: IndexPath) {
        let storage = Storage.storage().reference(forURL: imageURL)
        storage.getData(maxSize: 10 * 1024 * 1024) { [weak self] data, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            if index != self?.indexPath {
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.iconImageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self?.iconImageView.image = UIImage(systemName: "heart")
                }
            }
        }
    }

    @available(iOS 16.0, *)
    @objc private func optionAction() {
        guard let viewController = findViewController() else { return }
        let isMealTimeSet = item?.mealTime != nil
        let formSheetVC = optionsActionViewAlert()
        formSheetVC.isMealTimeSet = isMealTimeSet
        formSheetVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 150)
        formSheetVC.delegate = self
        if let sheet = formSheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(resolver: { _ in 170 })
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
         else {
            formSheetVC.modalPresentationStyle = .pageSheet
        }
        viewController.present(formSheetVC, animated: true, completion: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        indexPath = nil
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func findViewController() -> UIViewController? {
        var viewController: UIViewController? = nil
        var nextResponder: UIResponder? = self.next
        while nextResponder != nil {
            if let vc = nextResponder as? UIViewController {
                viewController = vc
                break
            }
            nextResponder = nextResponder?.next
        }
        return viewController
    }
}

@available(iOS 13.0, *)
extension InnerTableViewCell: optionsActionViewAlertDelegate {
    
    func didSelectSetMealTime() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapSetMealTime(at: indexPath)
    }
    
    func didSelectAddToShopppingList() {
        guard let recipeP = item else {
            print("No recipe item found.")
            return
        }
        let fetchRequest: NSFetchRequest<ShoppingListRecipe> = ShoppingListRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "shopRecipeID == %@", recipeP.recipeID ?? "")
        if let existingRecipes = try? context.fetch(fetchRequest), let existingRecipe = existingRecipes.first {
            context.delete(existingRecipe)
            try? context.save()  // Save the context to commit the deletion
        }
        
        let recipe = ShoppingListRecipe(context: context)
        recipe.shopRecipeID = recipeP.recipeID
        recipe.shopTitle = recipeP.title
        recipe.shopDescrip = recipeP.descrip
        recipe.shopImage = recipeP.image
        recipe.shopTimeSpent = recipeP.timeSpent
        
        if let ingredients = recipeP.ingredients as? Set<Ingredients> {
            let shoppingListIngredients = ingredients.map { ingredient -> ShoppingListIngredient in
                let shoppingListIngredient = ShoppingListIngredient(context: context)
                shoppingListIngredient.shopIngredients = ingredient.ingredients
                shoppingListIngredient.shopIsChecked = false
                return shoppingListIngredient
            }
            recipe.shopIngredient = NSSet(array: shoppingListIngredients)
        }
        
        do {
            try context.save()
            NotificationCenter.default.post(name: .didAddRecipeToShoppingList, object: nil)
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func didSelectDelete() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapDeleteButton(at: indexPath)
    }
}
