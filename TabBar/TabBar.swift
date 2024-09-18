import UIKit

@available(iOS 13.0, *)
class TabBar: UITabBarController {

    let homeView = Home()
    let planView = Plan()
    let wishlistView = SavedRecipe()
    let profileView = Profile()
    let shoppingListView = ShoppingList()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the view controllers
        let home = UINavigationController(rootViewController: homeView)
        let plan = UINavigationController(rootViewController: planView)
        let wishlist = UINavigationController(rootViewController: wishlistView)
        let profile = UINavigationController(rootViewController: profileView)
        let shoppingList = UINavigationController(rootViewController: shoppingListView)

        // Set titles
        home.title = "Home"
        plan.title = "Meal Plan"
        wishlist.title = "Saved"
        profile.title = "Profile"
        shoppingList.title = "Shopping List"

        // Set tab bar item images
        shoppingList.tabBarItem.image = UIImage(systemName: "cart.fill")?.withRenderingMode(.alwaysTemplate)
        home.tabBarItem.image = UIImage(systemName: "house.fill")?.withRenderingMode(.alwaysTemplate)
        plan.tabBarItem.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate)
        wishlist.tabBarItem.image = UIImage(systemName: "bookmark.fill")?.withRenderingMode(.alwaysTemplate)
        profile.tabBarItem.image = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysTemplate)

        // Set view controllers
        let viewControllerList = [home, wishlist, plan, shoppingList, profile]
        self.viewControllers = viewControllerList

        // Set initial appearance
        setUIColor()

        // Observe for user interface style changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }

    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }

    func setUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        // Configure tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set background color based on mode
        appearance.backgroundColor = isDarkMode ? UIColor(white: 0.2, alpha: 1) : UIColor.white
        
        // Configure appearance for selected and unselected states
        appearance.stackedLayoutAppearance.selected.iconColor = isDarkMode ? UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1) : UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor(white: 0.5, alpha: 1)]
        appearance.stackedLayoutAppearance.normal.iconColor = isDarkMode ? UIColor.white : UIColor(white: 0.5, alpha: 1)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: isDarkMode ? UIColor(white: 1, alpha: 1) : UIColor(white: 0.5, alpha: 1)]

        // Apply the appearance settings to the tab bar
        tabBar.standardAppearance = appearance

        // Ensure the appearance is applied on scroll edge
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        // Set the tab bar frame (height adjustment should be handled carefully to avoid layout issues)
        var tabBarFrame = tabBar.frame
        tabBarFrame.size.height = 150 // Set your desired height here
        tabBar.frame = tabBarFrame
        
        // Configure shadow for tab bar
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        tabBar.layer.shadowRadius = 4.0
        tabBar.layer.shadowOpacity = 0.5
        tabBar.layer.masksToBounds = false
    }
}
