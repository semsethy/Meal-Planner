import UIKit

protocol CreateIngredientDelegate: AnyObject {
    func didAddIngredient(ingredient: [String])
}

class CreateIngredient: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    let textField = UITextField()

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveIngredientButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveIngredientButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: "customCell")
        return table
    }()
    
    var delegate: CreateIngredientDelegate?
    private var groceryItems: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textField)
        view.addSubview(addButton)
        view.addSubview(tableView)
        view.addSubview(saveIngredientButton)
        
        textField.delegate = self
        textField.layer.cornerRadius = 15
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray
        ]
        let attributedPlaceholder = NSAttributedString(string: "Enter Ingredients", attributes: placeholderAttributes)
        textField.attributedPlaceholder = attributedPlaceholder
        
        setupConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
        applyColorTheme()
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .userInterfaceStyleChanged, object: nil)
    }
    
    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(view).offset(20)
            make.leading.equalTo(view).offset(20)
            make.height.equalTo(40)
        }
        addButton.snp.makeConstraints { make in
            make.top.equalTo(view).offset(20)
            make.leading.equalTo(textField.snp.trailing).offset(10)
            make.trailing.equalTo(view).offset(-20)
            make.height.equalTo(40)
            make.width.equalTo(50)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(250)
        }
        saveIngredientButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalTo(view)
        }
    }
    
    @objc private func handleUserInterfaceStyleChange() {
        applyColorTheme()
        tableView.reloadData()
    }
    
    private func applyColorTheme() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 0.95, alpha: 1)
        
        textField.backgroundColor = isDarkMode ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.9, alpha: 1)
        textField.textColor = isDarkMode ? UIColor.white : UIColor.black
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter Ingredients",
            attributes: [NSAttributedString.Key.foregroundColor: isDarkMode ? UIColor.lightGray : UIColor.gray]
        )
        
        addButton.backgroundColor = isDarkMode ? UIColor(red: 0.2, green: 0.5, blue: 0.4, alpha: 1) : UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        addButton.tintColor = .white
        
        saveIngredientButton.backgroundColor = addButton.backgroundColor
        saveIngredientButton.tintColor = .white
        
        tableView.backgroundColor = textField.backgroundColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        dismiss(animated: true)
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
        cell.customLabel.text = groceryItems[indexPath.row]
        cell.applyColorTheme()
        
        return cell
    }
    
    @objc func saveIngredientButtonAction() {
        if groceryItems.isEmpty {
            let alert = UIAlertController(title: "Incorrect", message: "Ingredient is empty", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel)
            alert.addAction(okay)
            present(alert, animated: true)
        } else {
            let ingredient = groceryItems
            delegate?.didAddIngredient(ingredient: ingredient)
            dismiss(animated: true)
        }
    }
    
    @objc func addButtonAction() {
        if let text = textField.text, !text.isEmpty {
            groceryItems.append(text)
            textField.text = ""
            tableView.reloadData()
        }
    }
}


class CustomTableViewCell: UITableViewCell {
    let customLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        applyColorTheme() // Apply theme when the cell is initialized
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(customLabel)
        NSLayoutConstraint.activate([
            customLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            customLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyColorTheme()
    }

    func applyColorTheme() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        contentView.backgroundColor = isDarkMode ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.9, alpha: 1)
        customLabel.textColor = isDarkMode ? UIColor.white : UIColor.black
        print("Applying theme - Dark mode: \(isDarkMode)")
    }
}
