import MMDrawerController
import OneSignal
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var drawerController: MMDrawerController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        URLCache.shared.removeAllCachedResponses()

        let centerViewController = homeController()
        let leftSideDrawerViewController = sideViewController()
        let rightSideDrawerViewController = rightSideViewController()

        let navigationController = UINavigationController(rootViewController: centerViewController)
        navigationController.restorationIdentifier = "homeController"

        rightSideDrawerViewController.restorationIdentifier = "rightSideViewController"

        leftSideDrawerViewController.restorationIdentifier = "sideViewController"

        if sideBarPosition == "left" {
            drawerController = MMDrawerController(center: navigationController, leftDrawerViewController: leftSideDrawerViewController)
        } else {
            drawerController = MMDrawerController(center: navigationController, rightDrawerViewController: rightSideDrawerViewController)
        }

        drawerController.showsShadow = true
        drawerController.restorationIdentifier = "Drawer"
        drawerController.maximumRightDrawerWidth = UIScreen.main.bounds.width - ((UIScreen.main.bounds.width * 15.3) / 100)
        drawerController.maximumLeftDrawerWidth = UIScreen.main.bounds.width - ((UIScreen.main.bounds.width * 15.3) / 100)
        drawerController.closeDrawerGestureModeMask = .all

        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = navigationBarTintColor
        UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([
            NSAttributedString.Key.font.rawValue: UIFont(name: "SFUIText-Regular", size: 18)!, NSAttributedString.Key.foregroundColor.rawValue: navigationBarTextColor,
        ])

        OneSignal.initWithLaunchOptions(launchOptions, appId: oneSignalAppId, handleNotificationReceived: { _ in
        }, handleNotificationAction: { result in

            let payload = result?.notification.payload
            if let additionalData = payload?.additionalData, let actionSelected = additionalData["launchURL"] as? String {
                centerViewController.articleID = actionSelected
            }
        }, settings: [kOSSettingsKeyAutoPrompt: true, kOSSettingsKeyInAppAlerts: false, kOSSettingsKeyInFocusDisplayOption: false])

        window?.rootViewController = drawerController
        window?.makeKeyAndVisible()

        return true
    }
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value) })
}
