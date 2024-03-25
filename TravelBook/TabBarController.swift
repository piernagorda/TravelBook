import UIKit

final class TabBarController: UITabBarController{
    
    // private var featuredTripsViewController: FeaturedTableViewController?
    private var myTripsViewController: MyTripsCollectionViewController?
    private var profileViewController: ProfileViewController?
    
    override func viewDidLoad() {
        
        navigationItem.title = "Featured"
        navigationItem.hidesBackButton = true
        /*
        self.featuredTripsViewController = FeaturedTableViewController(nibName: "FeaturedTableView", bundle: nil)
        self.featuredTripsViewController?.tabBarItem = UITabBarItem(title: "Featured", image: UIImage(systemName: "star"), tag: 0)
        self.featuredTripsViewController?.tabBarItem.selectedImage = UIImage(systemName: "star.fill")
         */
        self.myTripsViewController = MyTripsCollectionViewController(nibName: "MyTripsCollectionView", bundle: nil)
        self.myTripsViewController?.tabBarItem = UITabBarItem(title: "My Trips", image: UIImage(systemName: "map"), tag: 1)
        self.myTripsViewController?.tabBarItem.selectedImage = UIImage(systemName: "map.fill")
        
        self.profileViewController = ProfileViewController(nibName: "ProfileView", bundle: nil)
        self.profileViewController?.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 2)
        self.profileViewController?.tabBarItem.selectedImage = UIImage(systemName: "person.crop.circle.fill")
        
        self.tabBar.tintColor = .black
        
        self.viewControllers = [myTripsViewController!, profileViewController!]
        
        super.viewDidLoad()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.navigationItem.title = item.title
    }
    
}
