//
//  ViewRecipe.swift
//  Meal Preparing
//
//  Created by JoshipTy on 5/8/24.
//

import UIKit
import CoreData
import SnapKit

@available(iOS 13.0, *)
class FavViewRecipe: UIViewController {
    lazy var recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var recipeTitleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Ratatouille"
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    lazy var recipeDesciptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .justified
        label.text = "Description:  "
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var iconTimeSpentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "alarm.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    lazy var recipeTimeSpentLabel: UILabel = {
        let label = UILabel()
        label.text = "nil"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var recipeIngredientLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingredient:"
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    lazy var IngredientTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        return tableView
    }()
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        
        return scroll
    }()
    lazy var MainView: UIView = {
        let view = UIView()
        return view
    }()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var ingredient: FavoriteIngredient?
    var ingredients = [FavoriteIngredient]()
    var recipeP: FavoriteRecipe?
    var recipeID: String? = nil
    var ingredientTableViewHeightConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        setUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    func setUIColor(){
        
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Define colors for light and dark modes
        let backgroundColor: UIColor
        let textColor: UIColor
        let tintColor: UIColor
        
        if isDarkMode {
            // Dark mode colors
            backgroundColor = UIColor(white: 0.1, alpha: 1) // Dark background
            textColor = .white
            tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Accent color
        } else {
            // Light mode colors
            backgroundColor = UIColor.white
            textColor = .black
            tintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) // Accent color
        }
        
        // Apply colors to UI elements
        recipeImageView.tintColor = tintColor
        recipeTitleLabel.textColor = textColor

        scrollView.backgroundColor = backgroundColor
        view.backgroundColor = backgroundColor
        recipeDesciptionLabel.textColor = textColor
        iconTimeSpentImageView.tintColor = tintColor
        recipeTimeSpentLabel.textColor = textColor
        recipeIngredientLabel.textColor = textColor
        IngredientTableView.backgroundColor = backgroundColor
        MainView.backgroundColor = backgroundColor
        
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
    func setUpUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(MainView)
        MainView.addSubview(recipeImageView)
        MainView.addSubview(recipeTitleLabel)
        MainView.addSubview(recipeDesciptionLabel)
        MainView.addSubview(recipeIngredientLabel)
        MainView.addSubview(recipeTimeSpentLabel)
        MainView.addSubview(iconTimeSpentImageView)
        MainView.addSubview(IngredientTableView)
        
        IngredientTableView.delegate = self
        IngredientTableView.dataSource = self
        IngredientTableView.register(FavViewRecipeCell.self, forCellReuseIdentifier: "cell")
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        MainView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        recipeImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(MainView)
            make.height.equalTo(400)
        }
        recipeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(recipeImageView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(MainView).offset(20)
        }
        recipeDesciptionLabel.snp.makeConstraints { make in
            make.top.equalTo(recipeTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(MainView).inset(25)
        }
        iconTimeSpentImageView.snp.makeConstraints { make in
            make.top.equalTo(recipeDesciptionLabel.snp.bottom).offset(20)
            make.leading.equalTo(MainView).offset(20)
            make.width.height.equalTo(20)
        }
        recipeTimeSpentLabel.snp.makeConstraints { make in
            make.top.equalTo(recipeDesciptionLabel.snp.bottom).offset(20)
            make.leading.equalTo(iconTimeSpentImageView.snp.trailing).offset(5)
            make.trailing.equalTo(MainView).offset(-20)
        }
        recipeIngredientLabel.snp.makeConstraints { make in
            make.top.equalTo(iconTimeSpentImageView.snp.bottom).offset(10)
            make.leading.trailing.equalTo(MainView).inset(20)
        }
        IngredientTableView.snp.makeConstraints { make in
            make.top.equalTo(recipeIngredientLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(MainView)
            make.bottom.equalTo(MainView) // Ensure MainView extends to the bottom
            ingredientTableViewHeightConstraint = make.height.equalTo(0).constraint
        }

        IngredientTableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        updateTableViewHeight()
    }
    override func viewDidLayoutSubviews() {
        updateTableViewHeight()
    }
    func updateTableViewHeight() {
        // Calculate the content height of the IngredientTableView
        let contentHeight = IngredientTableView.contentSize.height
        
        // Update the height constraint for the IngredientTableView
        ingredientTableViewHeightConstraint?.update(offset: contentHeight)
        
        // Force layout of the MainView and its subviews
        MainView.layoutIfNeeded()
        
        // Calculate and set the scroll view content size
        let totalContentHeight = MainView.frame.height + contentHeight
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: totalContentHeight)
        
        // Debugging prints to verify layout
        print("ScrollView content size: \(scrollView.contentSize)")
        print("MainView frame height: \(MainView.frame.height)")
        print("IngredientTableView content height: \(contentHeight)")
    }
    
}
@available(iOS 13.0, *)
extension FavViewRecipe: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavViewRecipeCell
        let ingredient = ingredients[indexPath.item]
        cell.titleLabel.text = ingredient.favIngredients
        
        cell.selectionStyle = .none
        return cell
    }
}
