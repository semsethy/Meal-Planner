import UIKit
import FirebaseAuth
import UserNotifications
import FirebaseFirestore

struct TriggeredNotification {
    let title: String
    let body: String
    let alertTime: Date
}

class NotificationHistoryViewController: UIViewController {

    private var triggeredNotifications: [TriggeredNotification] = []
    let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NotificationCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notification History"
        setupTableView()
        fetchNotificationsFromFirestore()
        setUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }

    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }

    private func setUIColor() {
        view.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        tableView.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        
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

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    private func fetchNotificationsFromFirestore() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("notification").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching notifications: \(error)")
                return
            }

            if let documents = snapshot?.documents {
                self.triggeredNotifications = documents.compactMap { document in
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let body = data["body"] as? String ?? ""
                    let timestamp = data["alertTime"] as? Timestamp
                    let alertTime = timestamp?.dateValue() ?? Date()
                    return TriggeredNotification(title: title, body: body, alertTime: alertTime)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension NotificationHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return triggeredNotifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        let notification = triggeredNotifications[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        cell.textLabel?.text = notification.body
        cell.detailTextLabel?.text = "\(dateFormatter.string(from: notification.alertTime)) - \(notification.body)"
        cell.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 0.95, alpha: 1)
        cell.textLabel?.textColor = isDarkMode ? .white : .black
        cell.detailTextLabel?.textColor = isDarkMode ? .white : .black
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class NotificationCell: UITableViewCell{
    
}
