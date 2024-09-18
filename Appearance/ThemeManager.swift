//
//  ThemeManager.swift
//  Meal Preparing
//
//  Created by JoshipTy on 23/8/24.
//


import Foundation
extension Notification.Name {
    static let changeTheme = Notification.Name("changeTheme")
}
class ThemeManager {
    static let shared = ThemeManager()
    var theme: PresentationTheme = defaultPresentationTheme
    var themeType = Theme.day {
        didSet {
            if oldValue != themeType {
                NotificationCenter.default.post(name: Notification.Name.changeTheme, object: nil)
            }
        }
    }
    private init() {
        
    }
    
    func applyTheme(type: Theme) {
        if type == .day {
            theme = defaultPresentationTheme
        } else {
            theme = defaultDarkPresentationTheme
        }
        self.themeType = type
    }
}
enum Theme: String {
    case day, night
}
