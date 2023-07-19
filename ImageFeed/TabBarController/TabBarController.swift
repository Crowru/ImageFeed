import Foundation
import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListNavigationViewController = storyboard.instantiateViewController(withIdentifier: "NavigationViewController")
        let profileViewContoller = ProfileViewController()
        profileViewContoller.tabBarItem = UITabBarItem(title: nil,
                                                       image: UIImage(named: "tab_profile_active"),
                                                       selectedImage: nil)
        self.viewControllers = [imagesListNavigationViewController, profileViewContoller]
    }
}
