import UIKit
import UserNotifications
import FirebaseAuth
import FirebaseFirestore

protocol MealTimePickerDelegate: AnyObject {
    func didSelectMealTime(for recipe: Recipes)
}
@available(iOS 13.0, *)
class MealTimePickerViewController: UIViewController {
    
    weak var delegate: MealTimePickerDelegate?
    var recipe: Recipes?
    var indexPath: IndexPath?
    var selectedDate: Date?
    
    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        if #available(iOS 14.0, *) {
            picker.setValue(UIColor.black, forKey: "textColor")
        }
        return picker
    }()
    
    private lazy var remindMeSwitch: UISwitch = {
        let switchControl = UISwitch()
        return switchControl
    }()
    
    let label = UILabel()
    var initialTime: Date? // Optional: use this to set initial time in picker
    var initialRemindMe: Bool? // Optional: use this to set initial remind me switch status
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        if let initialTime = initialTime {
            timePicker.date = initialTime
        }
        if let initialRemindMe = initialRemindMe {
            remindMeSwitch.isOn = initialRemindMe
        }
        
        setupNavigationBar()
        setUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    
    func setUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        label.textColor = isDarkMode ? .white : .black
        timePicker.setValue(isDarkMode ? UIColor.white : UIColor.black, forKey: "textColor")
        remindMeSwitch.onTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        
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
    
    private func setupView() {
        let labelWithSwitch = createLabelWithSwitch(text: "Remind Me", switchControl: remindMeSwitch)
        
        let stackView = UIStackView(arrangedSubviews: [timePicker, labelWithSwitch])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func createLabelWithSwitch(text: String, switchControl: UISwitch) -> UIView {
        label.text = text
        
        let container = UIStackView(arrangedSubviews: [label, switchControl])
        container.axis = .horizontal
        container.spacing = 150 // Adjusted spacing for better layout
        container.alignment = .center
        return container
    }
    
    private func setupNavigationBar() {
        self.title = "Meal Time Picker"
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func doneButtonTapped() {
        guard let recipe = recipe, let selectedDate = selectedDate else { return }
        
        let selectedMealTime = timePicker.date
        let isReminderSet = remindMeSwitch.isOn
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedMealTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = 0
        
        if let finalMealTime = calendar.date(from: dateComponents) {
            recipe.mealTime = finalMealTime
        }
        recipe.remindMe = isReminderSet
        recipe.selectedDate = selectedDate
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try context.save()
            if !isReminderSet {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [recipe.recipeID ?? UUID().uuidString])
            } else if let mealTime = recipe.mealTime {
                scheduleNotification(for: recipe, at: mealTime)
            }
            delegate?.didSelectMealTime(for: recipe)
        } catch {
            print("Failed to save context: \(error)")
        }
        dismiss(animated: true)
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func scheduleNotification(for recipe: Recipes, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Meal Time Reminder"
        content.body = "It's time for your scheduled meal: \(recipe.title ?? "Recipe")"
        if #available(iOS 15.2, *) {
            content.sound = .defaultRingtone
        }
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: recipe.recipeID ?? UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                // Save notification to Firebase
                let notificationDict: [String: Any] = [
                    "title": content.title,
                    "body": content.body,
                    "alertTime": date
                ]
                FirestoreManager.shared.saveNotificationToFirestore(notificationDict: notificationDict, recipeID: recipe.recipeID ?? UUID().uuidString)
            }
        }
    }
}

class FirestoreManager {
    static let shared = FirestoreManager()
    
    private init() {}
    
    func saveNotificationToFirestore(notificationDict: [String: Any], recipeID: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("notification").document(recipeID).setData(notificationDict) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
