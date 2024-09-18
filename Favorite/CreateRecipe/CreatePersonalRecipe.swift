
import UIKit
import CoreData
import Photos
import Firebase
import FirebaseStorage
import FirebaseAuth

protocol saveRecipeToPerDelegate{
    func savePer(recipe: PersonalRecipe)
}
@available(iOS 13.0, *)
class CreatePersonalRecipe: UIViewController, UITextFieldDelegate,UITextViewDelegate {
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Your Own Recipe"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 25)
        return label
    }()
    private lazy var segmentControl: UISegmentedControl = {
        let items = ["Overview", "Ingredients", "Directions"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return control
    }()
    private lazy var imageLabel: UILabel = {
        let label = UILabel()
        label.text = "Image:"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var addLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Title"
        
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 6
        return textField
    }()
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Recipe", for: .normal)
        button.layer.cornerRadius = 19
        button.addTarget(self, action: #selector(saveRecipe), for: .touchUpInside)
        return button
    }()
    private lazy var textViewLabel: UILabel = {
        let label = UILabel()
        label.text = "Description:"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 6
        return textView
    }()
    private lazy var placeholderLabel: UILabel = {
       let placeholderLabel = UILabel()
        placeholderLabel.text = "Instruction..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.sizeToFit()
        return placeholderLabel
    }()
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    private lazy var addIngredientsLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Ingredients"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.layer.cornerRadius = 10
        if #available(iOS 16.0, *) {
            button.addTarget(self, action: #selector(didTapCreateIngredient), for: .touchUpInside)
        }
        return button
    }()
    private lazy var addTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Total Time"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    private lazy var addTimeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.layer.cornerRadius = 10
        if #available(iOS 16.0, *) {
            button.addTarget(self, action: #selector(didTapAddTimeButton), for: .touchUpInside)
        }
        return button
    }()
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear", for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        button.addTarget(self, action: #selector(clearButtonAction), for: .touchUpInside)
        button.isHidden = true // Initially hidden
        return button
    }()
    
    var dayTitles: [String] = []
    var selectedSection: Int?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegatePer: saveRecipeToPerDelegate?
    var bottomConstraint = NSLayoutConstraint()
    private var textFieldKey: UITextField?
    private var groceryItems:[String] = []
    private var isKeyboardShown = false
    private let containerView = UIView()
    private let overviewView = UIView()
    private let ingredientsView = UIView()
    private let directionsView = UIView()
    private var selectedTime: String? {
        didSet {
            updateClearButtonVisibility()
        }
    }
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    let MainView: UIView = {
        let MainView = UIView()
        return MainView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapgesture: UITapGestureRecognizer = {
            let tapgesture = UITapGestureRecognizer()
            tapgesture.addTarget(self, action: #selector(tapgestureAction))
            return tapgesture
        }()
        textField.delegate = self
        MainView.addGestureRecognizer(tapgesture)
        textView.delegate = self
        placeholderLabel.isHidden = !textView.text.isEmpty
        placeholderLabel.frame.origin = CGPoint(x: 10, y: textView.font!.pointSize / 2)
        textView.addSubview(placeholderLabel)
        setupUI()
        showView(forSegment: 0)
        setupUITable()
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 14, *) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
            imageView.addGestureRecognizer(tapGesture)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        setUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    @objc func clearButtonAction(){
        selectedTime = nil
        addTimeLabel.text = "Add Total Time"
    }
    private func updateClearButtonVisibility() {
        clearButton.isHidden = (selectedTime == nil)
    }
    // MARK: - Setup UI
    @objc func tapgestureAction(){
        view.endEditing(true)
        isKeyboardShown = false
    }
    @available(iOS 16.0, *)
    @objc func didTapAddTimeButton(){
        let formSheetVC = FormSheetViewController()
        formSheetVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 150)
        formSheetVC.delegate = self
        if let sheet = formSheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(resolver: { _ in 280 })
            sheet.detents = [customDetent] // Use the custom detent
            sheet.prefersGrabberVisible = true // Shows a grabber handle on the sheet
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }else {
            formSheetVC.modalPresentationStyle = .pageSheet
        }
        present(formSheetVC, animated: true, completion: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    func setUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"

        // Define colors for light mode
        let backgroundColorLight = UIColor.white
        let textColorLight = UIColor.black
        let buttonColorLight = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let placeholderColorLight = UIColor.gray
        let textFieldBackgroundLight = UIColor(white: 0.9, alpha: 1)

        // Define colors for dark mode
        let textColorDark = UIColor.white
        let buttonColorDark = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        let placeholderColorDark = UIColor.lightGray
        let textFieldBackgroundDark = UIColor(white: 0.2, alpha: 1)

        // Apply colors based on the current mode
        let backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : backgroundColorLight
        let textColor = isDarkMode ? textColorDark : textColorLight
        let buttonColor = isDarkMode ? buttonColorDark : buttonColorLight
        let placeholderColor = isDarkMode ? placeholderColorDark : placeholderColorLight
        let textFieldBackgroundColor = isDarkMode ? textFieldBackgroundDark : textFieldBackgroundLight

        MainView.backgroundColor = backgroundColor
        overviewView.backgroundColor = backgroundColor
        ingredientsView.backgroundColor = backgroundColor
        directionsView.backgroundColor = backgroundColor
        addTimeButton.setTitleColor(textColor, for: .normal)
        addTimeButton.tintColor = buttonColor
        addTimeLabel.textColor = textColor
        clearButton.setTitleColor(textColor, for: .normal)
        clearButton.backgroundColor = buttonColor
        addButton.tintColor = buttonColor
        addButton.setTitleColor(textColor, for: .normal)
        addIngredientsLabel.textColor = textColor
        tableView.backgroundColor = backgroundColor
        placeholderLabel.textColor = placeholderColor
        textViewLabel.textColor = textColor
        saveButton.setTitleColor(textColor, for: .normal)
        saveButton.backgroundColor = buttonColor
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor // Change this to your desired color
        ]
        let attributedPlaceholder = NSAttributedString(string: "Title", attributes: placeholderAttributes)
        textField.attributedPlaceholder = attributedPlaceholder
        textField.textColor = textColor
        textField.backgroundColor = textFieldBackgroundColor
        imageView.tintColor = buttonColor
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = buttonColor.cgColor
        imageLabel.textColor = textColor
        titleLabel.textColor = textColor
        addLabel.textColor = textColor
        segmentControl.backgroundColor = backgroundColor
        segmentControl.setTitleTextAttributes([.foregroundColor: textColor], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: isDarkMode ? UIColor(white: 1, alpha: 1) : backgroundColorLight], for: .selected)
        segmentControl.selectedSegmentTintColor = buttonColor
        cancelButton.tintColor = buttonColor
        textView.backgroundColor = isDarkMode ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.9, alpha: 1)
        textView.textColor = isDarkMode ? textColorDark : textColorLight
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(MainView)
        MainView.addSubview(cancelButton)
        MainView.addSubview(titleLabel)
        MainView.addSubview(segmentControl)
        MainView.addSubview(containerView)
        MainView.addSubview(saveButton)
        overviewView.addSubview(imageLabel)
        overviewView.addSubview(imageView)
        overviewView.addSubview(addLabel)
        overviewView.addSubview(textField)
        directionsView.addSubview(textView)
        directionsView.addSubview(textViewLabel)
        directionsView.addSubview(addTimeLabel)
        directionsView.addSubview(addTimeButton)
        directionsView.addSubview(clearButton)
        containerView.addSubview(overviewView)
        containerView.addSubview(ingredientsView)
        containerView.addSubview(directionsView)
        overviewView.isHidden = false
        ingredientsView.isHidden = true
        directionsView.isHidden = true
        setupConstraints()
    }
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = NSLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            bottomConstraint
        ])
        MainView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.height.greaterThanOrEqualTo(scrollView)
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(MainView).offset(50)
            make.leading.equalTo(MainView).offset(20)
            make.height.width.equalTo(50)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(MainView).inset(20)
        }
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(MainView).inset(20)
        }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(20)
            make.leading.trailing.equalTo(MainView).inset(20)
            make.height.equalTo(400)
        }
        overviewView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        ingredientsView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        directionsView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        addLabel.snp.makeConstraints { make in
            make.top.equalTo(overviewView).offset(20)
            make.leading.trailing.equalTo(overviewView).inset(20)
        }
        textField.snp.makeConstraints { make in
            make.top.equalTo(addLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(overviewView).inset(20)
            make.height.equalTo(40)
        }
        imageLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(30)
            make.leading.trailing.equalTo(overviewView).inset(20)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(imageLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(overviewView).inset(45)
            make.height.equalTo(210)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(30)
            make.centerX.equalTo(MainView)
            make.height.equalTo(40)
            make.width.equalTo(150)
        }
        textViewLabel.snp.makeConstraints { make in
            make.top.equalTo(directionsView).offset(20)
            make.leading.trailing.equalTo(directionsView).inset(20)
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(textViewLabel.snp.bottom).offset(10)
            make.trailing.leading.equalTo(directionsView).inset(20)
            make.height.equalTo(150)
        }
        addTimeButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.leading.equalTo(directionsView).offset(20)
            make.height.width.equalTo(20)
        }
        addTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.leading.equalTo(addTimeButton.snp.trailing).offset(5)
            make.trailing.equalTo(directionsView).offset(-20)
        }
        clearButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.trailing.equalTo(directionsView).offset(-20)
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
    }
    @objc private func cancelButtonAction() {
        dismiss(animated: true)
    }
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        showView(forSegment: sender.selectedSegmentIndex)
    }
    @objc private func saveRecipe() {
        let title = textField.text ?? ""
        let description = textView.text ?? ""
        let ingredientsList = groceryItems
        let timeSpent = selectedTime ?? ""
        let image = imageView.image
        
        // Validation checks
        if title.isEmpty {
            showAlert(message: "Title cannot be empty")
            return
        }
        if timeSpent.isEmpty {
            showAlert(message: "Time spent cannot be empty")
            return
        }
        if description.isEmpty {
            showAlert(message: "Description cannot be empty")
            return
        }
        
        // Create PersonalRecipe object
        let personalRecipe = PersonalRecipe(context: context)
        personalRecipe.perRecipeID = UUID().uuidString
        personalRecipe.perTitle = title
        personalRecipe.perDescrip = description
        personalRecipe.perTimeSpent = timeSpent
        personalRecipe.perImage = image?.resizeImageWith(maxSize: 1280).jpegData(compressionQuality: 0.7)
        
        // Create PersonalIngredient objects and set relationship
        let personalIngredientsSet = NSSet(array: ingredientsList.map { ingredientString in
            let personalIngredient = PersonalIngredient(context: context)
            personalIngredient.perIngredient = ingredientString
            personalIngredient.perIsChecked = false
            personalIngredient.perRecipe = personalRecipe
            return personalIngredient
        })
        personalRecipe.perIngredient = personalIngredientsSet
        do {
            try context.save()
            delegatePer?.savePer(recipe: personalRecipe)
            dismiss(animated: true)
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            print("Failed to get image data")
            return
        }
        let recipeID = UUID().uuidString
        let imageName = "\(recipeID).jpg"

        // Upload image to Firebase Storage
        let imageRef = storageRef.child("perImage/\(imageName)")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                
                guard let imageURL = url?.absoluteString else {
                    print("Failed to get image URL")
                    return
                }
                
                // Prepare data to be saved to Firestore
                let recipeData: [String: Any] = [
                    "perTitle": title,
                    "perDescrip": description,
                    "perIngredient": ingredientsList,
                    "perTimeSpent": timeSpent,
                    "perRecipeID": recipeID,
                    "perImageURL": imageURL
                ]
                
                // Save the recipe data to Firestore
                db.collection("users").document(userID).collection("perRecipes").document(recipeID).setData(recipeData) { error in
                    if let error = error {
                        print("Error saving recipe: \(error.localizedDescription)")
                    } else {
                        print("Recipe successfully saved!")
                    }
                }
            }
        }
    }
    // Helper function to show alert messages
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Incorrect", message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .cancel)
        alert.addAction(okay)
        present(alert, animated: true)
    }
    func convertImageToData(image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: 1) // You can adjust the compression quality if needed
    }
    private func showView(forSegment index: Int) {
        let fromView: UIView?
        let toView: UIView?
        
        switch index {
        case 0:
            fromView = ingredientsView.isHidden ? directionsView : ingredientsView
            toView = overviewView
        case 1:
            fromView = overviewView.isHidden ? directionsView : overviewView
            toView = ingredientsView
        case 2:
            fromView = overviewView.isHidden ? ingredientsView : overviewView
            toView = directionsView
        default:
            return
        }
        if let fromView = fromView, let toView = toView {
            fromView.isHidden = true
            toView.isHidden = false
            
            UIView.transition(with: containerView, duration: 0.3, options: .allowAnimatedContent, animations: {
                fromView.alpha = 0
                toView.alpha = 1
            })
        }
    }
}
@available(iOS 13.0, *)
extension CreatePersonalRecipe: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
    }
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    func presentCameraSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        let alertcontroller = UIAlertController(title: "Error", message: "Access is denied", preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertcontroller.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            UIApplication.shared.open(url, options: [:])
        }))
        present(alertcontroller, animated: true)
    }
    func presentImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    @available(iOS 14, *)
    func checkPhotoPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                completion(newStatus == .authorized || newStatus == .limited)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    @available(iOS 14, *)
    @objc private func imageViewTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Photo", style: .default, handler: { _ in
            self.checkPhotoPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentImagePickerController(sourceType: .photoLibrary)
                    } else {
                        self.presentCameraSettings()
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Take a Picture", style: .default, handler: { _ in
            self.checkCameraPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentImagePickerController(sourceType: .camera)
                    } else {
                        self.presentCameraSettings()
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
}
@available(iOS 13.0, *)
extension CreatePersonalRecipe: UITableViewDataSource, UITableViewDelegate {
    private func setupUITable() {
        ingredientsView.addSubview(addButton)
        ingredientsView.addSubview(tableView)
        ingredientsView.addSubview(addIngredientsLabel)
        addButton.snp.makeConstraints { make in
            make.top.equalTo(ingredientsView).offset(10)
            make.leading.equalTo(ingredientsView).offset(20)
            make.height.width.equalTo(20)
        }
        addIngredientsLabel.snp.makeConstraints { make in
            make.top.equalTo(ingredientsView).offset(10)
            make.leading.equalTo(addButton.snp.trailing).offset(5)
            make.trailing.equalTo(ingredientsView).offset(-20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(addIngredientsLabel.snp.bottom).offset(10)
            make.leading.equalTo(ingredientsView)
            make.trailing.equalTo(ingredientsView)
            make.bottom.equalTo(ingredientsView).offset(-20)
        }
    }
    @available(iOS 16.0, *)
    @objc private func didTapCreateIngredient() {
        let formSheetVC = AddIngredient()
        formSheetVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 150)
        formSheetVC.delegate = self
        if let sheet = formSheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(resolver: { _ in 50 })
            sheet.detents = [customDetent] // Use the custom detent
            sheet.prefersGrabberVisible = true // Shows a grabber handle on the sheet
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        } else {
            formSheetVC.modalPresentationStyle = .pageSheet
        }
        present(formSheetVC, animated: true, completion: nil)
    }
    @objc private func showKeyboard(notification: Notification) {
        guard let size = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = size.height
        }
        view.layoutIfNeeded()
    }
    @objc private func hideKeyboard() {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 0
        }
        view.layoutIfNeeded()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = groceryItems[indexPath.row]
        cell.textLabel?.textColor = isDarkMode ? UIColor.white : UIColor.black
        cell.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor.white
        return cell
    }
}
@available(iOS 13.0, *)
extension CreatePersonalRecipe: FormSheetDelegate {
    func didUpdateTime(_ time: String) {
        selectedTime = time
        addTimeLabel.text = "Time Spent: " + time
    }
}
@available(iOS 13.0, *)
extension CreatePersonalRecipe: AddIngredientDelegate{
    func didAddIngredient(ingredient: String) {
        groceryItems.append(ingredient)
        tableView.reloadData()
    }
}
