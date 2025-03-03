import UIKit

final class TabBarController: UITabBarController{
    
    private var myTripsViewController: MyTripsCollectionViewController?
    private var profileViewController: ProfileViewHostingController?
    
    override func viewDidLoad() {
        
        navigationItem.title = "My Trips"
        navigationItem.hidesBackButton = true
        self.myTripsViewController = MyTripsCollectionViewController(nibName: "MyTripsCollectionView", bundle: nil)
        self.myTripsViewController?.tabBarItem = UITabBarItem(title: "My Trips", image: UIImage(systemName: "map"), tag: 0)
        self.myTripsViewController?.tabBarItem.selectedImage = UIImage(systemName: "map.fill")
        
        // SwiftUI-based TestViewProfile integrated in NewProfileViewController
        let testViewProfile = ProfileView(userName: "Javier") // Your SwiftUI view
        self.profileViewController = ProfileViewHostingController(userName: "Javier")
        self.profileViewController?.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 1)
        self.profileViewController?.tabBarItem.selectedImage = UIImage(systemName: "person.crop.circle.fill")
        
        self.tabBar.tintColor = .black
        self.tabBar.backgroundColor = .white
        
        self.viewControllers = [myTripsViewController!, profileViewController!]
        
        super.viewDidLoad()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.navigationItem.title = item.title
    }
}
