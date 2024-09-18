
import UIKit
import Photos
import CoreData
import TOCropViewController
import FirebaseStorage
import FirebaseAuth
import KeychainSwift
import FirebaseFirestore
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

extension Notification.Name {
    static let userInterfaceStyleChanged = Notification.Name("userInterfaceStyleChanged")
}
extension UIImage {
    func roundedImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.size)
        let roundedImage = renderer.image { context in
            context.cgContext.addEllipse(in: CGRect(origin: .zero, size: self.size))
            context.cgContext.clip()
            self.draw(in: CGRect(origin: .zero, size: self.size))
        }
        return roundedImage
    }
}
@available(iOS 13.0, *)
class Profile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,NVActivityIndicatorViewable{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var label = UILabel()
    var image = UIImageView()
    let pickimage = UIButton(type: .system)
    let scrollView = UIScrollView()
    let view1 = UIView()
    let view2 = UIView()
    let settingButton = UIButton(type: .system)
    let defaults = UserDefaults.standard
    var pickedImageURL: URL?
    let keychain = KeychainSwift()
    private lazy var changeUsernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Username", for: .normal)
        button.layer.borderWidth = 1.0
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.systemGray3.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(changeUsernameButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log out", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(logoutButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var darkModeSwitch: UISwitch = {
        let Switch = UISwitch()
        Switch.translatesAutoresizingMaskIntoConstraints = false
        return Switch
    }()
    private lazy var darkModeLabel: UILabel = {
       let label = UILabel()
        label.text = "Dark Mode"
        label.textColor = UIColor(white: 0.4, alpha: 1)
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var indicatorLabel: UILabel = {
       let label = UILabel()
        label.text = ">"
        label.textColor = .black
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    var usernameFromCreateNewAccount: String?
    let settingsItems = [
        ("Dark Mode", "darkMode"),
        ("Change Username", "username"),
        ("Logout", "logout"),
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view1.backgroundColor = UIColor(white: 0.95, alpha: 1)
        navigationItem.title = "Setting"
        DispatchQueue.global().sync {
            settingButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
            settingButton.tintColor = .gray
        }
        view.addSubview(scrollView)
        scrollView.addSubview(view1)
        
        view1.addSubview(label)
        view1.addSubview(image)
        view1.addSubview(pickimage)
        view1.addSubview(view2)
        
        view2.addSubview(darkModeSwitch)
        view2.addSubview(changeUsernameButton)
        view2.addSubview(logoutButton)
        view2.addSubview(indicatorLabel)
        view2.addSubview(darkModeLabel)
        
        view2.layer.borderColor = UIColor.systemGray3.cgColor
        view2.layer.borderWidth = 1
        view2.backgroundColor = .white
        view2.layer.cornerRadius = 10
        
        pickimage.setTitle("Add Photo", for: .normal)
        pickimage.addTarget(self, action: #selector(pickimageAction), for: .touchUpInside)
        pickimage.backgroundColor = .systemGray5
        pickimage.layer.cornerRadius = 15
        pickimage.tintColor = .black
        pickimage.backgroundColor = UIColor(white: 0.9, alpha: 1)
        image.tintColor = .gray
        image.clipsToBounds = true
        image.layer.cornerRadius = image.frame.width / 2
        label.font = .systemFont(ofSize: 30)
        label.textColor = .black
        let storedUsername = UserDefaults.standard.string(forKey: "username")
        label.text = storedUsername ?? "User"
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        view1.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.height.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        image.snp.makeConstraints { make in
            make.top.equalTo(view1).offset(100)
            make.centerX.equalTo(view1)
            make.height.equalTo(100)
            make.width.equalTo(100)
        }
        pickimage.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(10)
            make.centerX.equalTo(view1)
            make.width.equalTo(100)
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(pickimage.snp.bottom).offset(20)
            make.centerX.equalTo(view1)
            make.height.equalTo(40)
        }
        view2.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(40)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(145)
        }
        darkModeLabel.snp.makeConstraints { make in
            make.top.equalTo(view2).inset(10)
            make.leading.equalTo(view2).offset(15)
            make.height.equalTo(40)
        }
        darkModeSwitch.snp.makeConstraints { make in
            make.top.equalTo(view2).inset(12)
            make.trailing.equalTo(view2).offset(-15)
            make.height.equalTo(40)
        }
        indicatorLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(changeUsernameButton)
            make.trailing.equalTo(changeUsernameButton.snp.trailing).inset(15)
        }
        changeUsernameButton.snp.makeConstraints { make in
            make.top.equalTo(darkModeLabel.snp.bottom)
            make.leading.trailing.equalTo(view2)
            make.height.equalTo(45)
        }
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(changeUsernameButton.snp.bottom)
            make.leading.trailing.equalTo(view2)
            make.height.equalTo(40)
        }
        
        let userID = Auth.auth().currentUser?.uid
        if let userID = userID {
            fetchAndStoreUsername(userID: userID)
        }
        let savedMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") ?? "light"
        darkModeSwitch.isOn = savedMode == "dark"
        darkModeSwitch.addTarget(self, action: #selector(toggleMode), for: .valueChanged)
        view.layoutIfNeeded()
        loadUserInterfaceStyle()
        setupColors()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    @objc private func handleUserInterfaceStyleChange() {
        setupColors()
    }
    func setupColors() {
        // Define colors for light mode
        let lightSecondaryColor = UIColor(white: 0.95, alpha: 1)
        let lightLabelTextColor = UIColor.black
        let lightButtonTextColor = UIColor.black
        let lightViewBackgroundColor = UIColor.white
        let darkSecondaryColor = UIColor(white: 0.2, alpha: 1)
        let darkLabelTextColor = UIColor.white
        let darkViewBackgroundColor = UIColor(white: 0.1, alpha: 1)
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Apply colors based on the current user interface style
        let secondaryColor = isDarkMode ? darkSecondaryColor : lightSecondaryColor
        let labelTextColor = isDarkMode ? darkLabelTextColor : lightLabelTextColor
        let viewBackgroundColor = isDarkMode ? darkViewBackgroundColor : lightViewBackgroundColor

        // Set colors for labels
        label.textColor = labelTextColor
        darkModeLabel.textColor = labelTextColor
        indicatorLabel.textColor = labelTextColor

        // Set colors for buttons
        pickimage.backgroundColor = isDarkMode ? UIColor(white: 0.5, alpha: 1) : UIColor(white: 0.5, alpha: 1)
        pickimage.tintColor = isDarkMode ? .white : .white
        changeUsernameButton.setTitleColor(isDarkMode ? .white : lightButtonTextColor, for: .normal)
        logoutButton.setTitleColor(.red, for: .normal) // Red color for logout button remains unchanged

        // Set background colors
        view.backgroundColor = viewBackgroundColor
        view1.backgroundColor = viewBackgroundColor
        view2.backgroundColor = secondaryColor

        // Set tab bar appearance using UITabBarAppearance
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

    @objc func toggleMode() {
        let isDarkMode = darkModeSwitch.isOn
        UserDefaults.standard.set(isDarkMode ? "dark" : "light", forKey: "userInterfaceStyle")
        // Notify other parts of the app about the change
        NotificationCenter.default.post(name: .userInterfaceStyleChanged, object: nil)
    }
    @objc func changeUsernameButtonAction(){
        let usernameEditVC = UsernameEditViewController()
        usernameEditVC.currentUsername = label.text
        usernameEditVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(usernameEditVC, animated: true)
    }
    
    private func loadUserInterfaceStyle() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        darkModeSwitch.isOn = isDarkMode
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Check if the user interface style has changed
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
        }
    }
    @objc func logoutButtonAction(){
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.logoutUser()
            self.image.image = UIImage(systemName: "person.circle")
            UserDefaults.standard.removeObject(forKey: "userProfileImageURL")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func startAnimatingIndicator() {
        let size = CGSize(width: 30.0, height: 30.0)
        startAnimating(size, message: "Loading", type: .ballRotateChase, color: .white, textColor: .white)
    }
    func stopAnimatingIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    override func viewWillAppear(_ animated: Bool) {
        let userID = Auth.auth().currentUser?.uid
        if let userID = userID {
            fetchAndStoreUsername(userID: userID)
            loadProfileImage()
        }
    }
    func fetchAndStoreUsername(userID: String) {
        startAnimatingIndicator()
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(userID)
        userDocument.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                self.stopAnimatingIndicator()
                return
            }
            guard let document = document, document.exists,
                  let data = document.data(),
                  let username = data["username"] as? String else {
                print("Document does not exist or username field is missing")
                self.stopAnimatingIndicator()
                return
            }
            // Store the username in UserDefaults
            UserDefaults.standard.set(username, forKey: "username")
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.label.text = username
            }
            print("Username fetched and stored: \(username)")
            self.stopAnimatingIndicator()
        }
    }
    func loadProfileImage() {
        startAnimatingIndicator()  // Show loading indicator
        // If no saved image, fetch image URL and download the image
        fetchProfileImageURL { [weak self] imageURL in
            guard let self = self else { return }
            
            if let imageURL = imageURL {
                print("Fetched image URL: \(imageURL)")
                let storageRef = Storage.storage().reference(forURL: imageURL)
                storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                        self.image.image = UIImage(systemName: "person.circle.fill")
                    } else if let data = data, let downloadedImage = UIImage(data: data) {
                        // Save the image data to UserDefaults
                        UserDefaults.standard.set(data, forKey: "profileImageData")
                        
                        DispatchQueue.main.async {
                            self.image.image = downloadedImage.roundedImage()
                        }
                    } else {
                        self.image.image = UIImage(systemName: "person.circle.fill")
                    }
                    self.stopAnimatingIndicator()  // Hide loading indicator
                }
            } else {
                self.image.image = UIImage(systemName: "person.circle.fill")
                self.stopAnimatingIndicator()  // Hide loading indicator
            }
        }
    }

    func fetchProfileImageURL(completion: @escaping (String?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            completion(nil)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let document = document, document.exists,
                  let data = document.data(),
                  let imageURL = data["profileImageURL"] as? String else {
                completion(nil)
                return
            }
            completion(imageURL)
        }
    }

    func updateProfileImage(newImage: UIImage) {
        uploadImageToFirebase(image: newImage) { [weak self] url in
            guard let self = self, let imageUrl = url else { return }
            
            // Save image URL in Firestore and UserDefaults
            self.saveImageMetadataToFirestore(downloadURL: imageUrl)
            UserDefaults.standard.set(imageUrl, forKey: "userProfileImageURL")
            
            // Reload the profile image
            self.loadProfileImage()
        }
    }

    func uploadImageToFirebase(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let userID = Auth.auth().currentUser?.uid else {
            print("Failed to get image data or user ID")
            completion(nil)
            return
        }
        let storageRef = Storage.storage().reference().child("userImages/\(userID)/\(UUID().uuidString).jpg")
        let uploadTask = storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                if let downloadURL = url?.absoluteString {
                    completion(downloadURL)
                } else {
                    completion(nil)
                }
            }
        }
        // Optionally, monitor the upload progress
        uploadTask.observe(.progress) { snapshot in
            // Observe upload progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(percentComplete)%")
        }
    }

    func saveImageMetadataToFirestore(downloadURL: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).setData([
            "profileImageURL": downloadURL
        ], merge: true) { error in
            if let error = error {
                print("Error saving image URL to Firestore: \(error.localizedDescription)")
            } else {
                print("Image URL successfully saved to Firestore")
            }
        }
    }
    @objc func pickimageAction() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
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
                        print("Camera permission denied")
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    private func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "userProfileImageURL")
        UserDefaults.standard.removeObject(forKey: "username")
//        UserDefaults.standard.removeObject(forKey: "profileImageData")
        Home.hasShownSkeletonView = false
        deleteData()
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError.localizedDescription)
        }
        navigateToLoginScreen()
    }
    private func deleteData() {
        // Define a function to delete all objects for a given request
        func deleteAll<T: NSManagedObject>(ofType type: T.Type, context: NSManagedObjectContext) {
            let request = T.fetchRequest()
            do {
                let results = try context.fetch(request) as! [T]
                for object in results {
                    context.delete(object)
                }
                try context.save()
            } catch {
                print("Failed to fetch or delete objects: \(error)")
            }
        }
        
        // Delete data from each entity
        deleteAll(ofType: Recipes.self, context: context)
        deleteAll(ofType: PersonalRecipe.self, context: context)
        deleteAll(ofType: FavoriteRecipe.self, context: context)
        deleteAll(ofType: ShoppingListRecipe.self, context: context)
    }

    private func navigateToLoginScreen() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let viewController = UINavigationController(rootViewController: SignIn())
            appDelegate.window?.rootViewController = viewController
        }
    }
}

@available(iOS 13.0, *)
extension Profile{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            let cropViewController = TOCropViewController(image: image)
            cropViewController.delegate = self
            cropViewController.aspectRatioPreset = .presetSquare
            cropViewController.aspectRatioLockEnabled = true
            cropViewController.resetAspectRatioEnabled = false
            present(cropViewController, animated: true, completion: nil)
        }
    }
    func saveImageAsJPEG(_ image: UIImage, to directory: FileManager.SearchPathDirectory, withName fileName: String, compressionQuality: CGFloat) -> URL? {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            print("Error: Unable to convert UIImage to JPEG Data")
            return nil
        }
        
        let fileManager = FileManager.default
        guard let directoryURL = fileManager.urls(for: directory, in: .userDomainMask).first else {
            print("Error: Unable to access directory")
            return nil
        }
        
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            print("Image successfully saved to \(fileURL)")
            return fileURL
        } catch {
            print("Error: Unable to write image data to file: \(error)")
            return nil
        }
    }

    func checkCameraPermission(completion: @escaping(Bool)-> Void ){
        switch AVCaptureDevice.authorizationStatus(for: .video){
            case .authorized:
                completion(true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video){ granted in
                    completion(granted)
                }
            case .denied, .restricted:
                completion(false)
            @unknown default:
                completion(false)
        }
    }
    func presentCameraSettings(){
        guard let url = URL(string: UIApplication.openSettingsURLString) else {return}
        let alertcontroller = UIAlertController(title: "Error", message: "Access is denied", preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertcontroller.addAction(UIAlertAction(title: "Setting", style: .default, handler: { _ in
            UIApplication.shared.open(url, options: [:])
        }))
        present(alertcontroller,animated: true)
    }
    func presentImagePickerController(sourceType: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    func checkPhotoPermission(completion: @escaping(Bool)-> Void){
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            completion(true)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                completion(newStatus == .authorized)
            }
        case .denied, .restricted:
            completion(false)
            
        @unknown default:
            completion(false)
        }
    }
}
@available(iOS 13.0, *)
extension Profile: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        updateProfileImage(newImage: image)
        cropViewController.dismiss(animated: true, completion: nil)
    }
    func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
class CenteredTextCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.textAlignment = .center
        textLabel?.textColor = .red
    }
}
