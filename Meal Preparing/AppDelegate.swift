import UIKit
import CoreData
import FirebaseCore
import Firebase
import FirebaseAuth
import UserNotifications

@available(iOS 13.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // Create window first
        window = UIWindow(frame: UIScreen.main.bounds)

        // Setup Root View Controller
        window?.rootViewController = LetsGetStarted()
        window?.makeKeyAndVisible()
        
        // Apply Dark Mode based on saved preference
        let userPrefStyle = UserDefaults.standard.string(forKey: "userInterfaceStyle")
        if userPrefStyle == "dark" {
            window?.overrideUserInterfaceStyle = .dark
        } else {
            window?.overrideUserInterfaceStyle = .light
        }

        // Check notification permissions
        UNUserNotificationCenter.current().delegate = self // Set delegate to handle foreground notifications

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("🔔 Notification permission granted.")
                    UserDefaults.standard.set(true, forKey: "allowNotification")
                } else {
                    print("🚫 Notification permission denied.")
                    UserDefaults.standard.set(false, forKey: "allowNotification")
                }
            }
        }


        return true
    }

    

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Meal_Preparing")
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("MealPreparing.sqlite")
        
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving Support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func updateAppearance(darkModeEnabled: Bool) {
        window?.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
    }


    func applicationDidBecomeActive(_ application: UIApplication) {
        let userPrefStyle = UserDefaults.standard.string(forKey: "userInterfaceStyle")
        updateAppearance(darkModeEnabled: userPrefStyle == "dark")
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification while app is in foreground
        completionHandler([.alert, .sound])
    }
}
