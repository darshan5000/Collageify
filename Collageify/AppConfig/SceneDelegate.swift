import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        InAppPurchase().verifySubscriptions([.autoRenewableForMonth, .autoRenewableForYear], completion: { isPurchased in
            isSubScription = isPurchased
            userDefault.set(true, forKey: "isSubScription")
            if isSubScription ==  true {
                IS_ADS_SHOW = false
            }
            isSubScription = userDefault.bool(forKey: "isSubScription")
        })
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
}
