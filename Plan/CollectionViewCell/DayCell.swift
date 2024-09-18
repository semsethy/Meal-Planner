import UIKit

protocol DayCellDelegate: AnyObject {
    func didTapCreateNew(for section: Int)
    func didTapAddPersonal(for section: Int)
    func didTapFavorite(for section: Int)
    func didDeleteRecipe(at indexPath: IndexPath)
    func didSetMealTimeRecipe(at indexPath: IndexPath)
    func didSelectRecipe(_ recipe: Recipes)
}

import UIKit

@available(iOS 13.0, *)
class DayCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource, InnerTableViewCellDelegate {

    // UI Components
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var innerTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        return button
    }()
    
    var innerTableViewHeightConstraint: NSLayoutConstraint!
    var items: [Recipes] = [] {
        didSet {
            innerTableView.reloadData()
            innerTableViewHeightConstraint.constant = CGFloat(items.count * 80)
            layoutIfNeeded()
        }
    }
    
    var sectionIndex: Int?
    weak var delegate: DayCellDelegate?
    var presentAlert: ((UIAlertController) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        innerTableView.delegate = self
        innerTableView.dataSource = self
        innerTableView.register(InnerTableViewCell.self, forCellReuseIdentifier: "innerCell")

        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(innerTableView)
        contentView.addSubview(addButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(15)
            make.leading.equalTo(addButton.snp.trailing).offset(10)
            make.trailing.greaterThanOrEqualTo(contentView).offset(-15)
        }
        addButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(15)
            make.width.height.equalTo(30)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView).offset(55)
            make.trailing.equalTo(contentView).offset(-15)
        }
        innerTableView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView)
        }
        innerTableViewHeightConstraint = innerTableView.heightAnchor.constraint(equalToConstant: 0)
        innerTableViewHeightConstraint.isActive = true
        addButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        applyColorTheme() // Apply the color theme on initialization
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        applyColorTheme()
    }

    @objc func buttonAction() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Personal Recipes", style: .default, handler: { _ in
            if let section = self.sectionIndex {
                self.delegate?.didTapAddPersonal(for: section)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Favorite", style: .default, handler: { _ in
            if let section = self.sectionIndex {
                self.delegate?.didTapFavorite(for: section)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Create New", style: .default, handler: { _ in
            if let section = self.sectionIndex {
                self.delegate?.didTapCreateNew(for: section)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentAlert?(alertController)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "innerCell", for: indexPath) as? InnerTableViewCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.configure(with: item, at: indexPath)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = findViewController() else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRecipe = items[indexPath.row]
        let viewRecipeVC = ViewRecipe()
        viewRecipeVC.recipeTitleLabel.text = selectedRecipe.title
        viewRecipeVC.recipeDesciptionLabel.text = "Description: \(selectedRecipe.descrip ?? "")"
        viewRecipeVC.recipeTimeSpentLabel.text = selectedRecipe.timeSpent
        if let imageData = selectedRecipe.image {
            if let thumbnail = ImageUtils.generateThumbnail(id: selectedRecipe.recipeID!, imageData: imageData) {
                viewRecipeVC.recipeImageView.image = thumbnail
            }
        }

        if let ingredientsSet = selectedRecipe.ingredients as? Set<Ingredients> {
            viewRecipeVC.ingredients = Array(ingredientsSet)
        } else {
            viewRecipeVC.ingredients = []
        }
        viewRecipeVC.hidesBottomBarWhenPushed = true
        viewController.navigationController?.pushViewController(viewRecipeVC, animated: true)
    }
    
    private func findViewController() -> UIViewController? {
        var viewController: UIViewController? = nil
        var nextResponder = self.next
        while nextResponder != nil {
            if let vc = nextResponder as? UIViewController {
                viewController = vc
                break
            }
            nextResponder = nextResponder?.next
        }
        return viewController
    }
    
    func didTapDeleteButton(at indexPath: IndexPath) {
        guard let sectionIndex = sectionIndex else { return }
        delegate?.didDeleteRecipe(at: IndexPath(row: indexPath.row, section: sectionIndex))
    }
    
    func didTapSetMealTime(at indexPath: IndexPath) {
        guard let sectionIndex = sectionIndex else { return }
        delegate?.didSetMealTimeRecipe(at: IndexPath(row: indexPath.row, section: sectionIndex))
    }
    
    // Function to apply color theme
    private func applyColorTheme() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let lightPrimaryColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let lightSecondaryColor = UIColor.black
        let lightBackgroundColor = UIColor(white: 1, alpha: 1)
        
        let darkPrimaryColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let darkSecondaryColor = UIColor.white
        let darkBackgroundColor = UIColor(white: 0.1, alpha: 1)
        
        // Apply colors based on the theme
        let primaryColor = isDarkMode ? darkPrimaryColor : lightPrimaryColor
        let secondaryColor = isDarkMode ? darkSecondaryColor : lightSecondaryColor
        let backgroundColor = isDarkMode ? darkBackgroundColor : lightBackgroundColor
        
        contentView.backgroundColor = backgroundColor
        titleLabel.textColor = secondaryColor
        descriptionLabel.textColor = secondaryColor
        addButton.tintColor = primaryColor
        innerTableView.backgroundColor = backgroundColor
    }
}

@available(iOS 13.0, *)
extension DayCell: MealTimePickerDelegate {
    func didSelectMealTime(for recipe: Recipes) {
        if let indexPath = items.firstIndex(where: { $0.recipeID == recipe.recipeID }) {
            let cell = innerTableView.cellForRow(at: IndexPath(row: indexPath, section: 0)) as? InnerTableViewCell
            cell?.configure(with: recipe, at: IndexPath(row: indexPath, section: 0))
        }
    }
}
