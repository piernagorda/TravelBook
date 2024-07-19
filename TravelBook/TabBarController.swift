import UIKit

final class TabBarController: UITabBarController{
    
    // private var featuredTripsViewController: FeaturedTableViewController?
    private var myTripsViewController: MyTripsCollectionViewController?
    private var profileViewController: ProfileViewController?
    private var mapViewController: MapViewController?
    
    override func viewDidLoad() {
        
        navigationItem.title = "My Trips"
        navigationItem.hidesBackButton = true
        self.myTripsViewController = MyTripsCollectionViewController(nibName: "MyTripsCollectionView", bundle: nil)
        self.myTripsViewController?.tabBarItem = UITabBarItem(title: "My Trips", image: UIImage(systemName: "map"), tag: 0)
        self.myTripsViewController?.tabBarItem.selectedImage = UIImage(systemName: "map.fill")
        
        self.mapViewController = MapViewController(nibName: "MapView", bundle: nil)
        self.mapViewController?.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "mappin.square"), tag: 1)
        self.mapViewController?.tabBarItem.selectedImage = UIImage(systemName: "mappin.square.fill")
        
        self.profileViewController = ProfileViewController(nibName: "ProfileView", bundle: nil)
        self.profileViewController?.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 2)
        self.profileViewController?.tabBarItem.selectedImage = UIImage(systemName: "person.crop.circle.fill")
        
        self.tabBar.tintColor = .black
        self.tabBar.backgroundColor = .white
        
        self.viewControllers = [myTripsViewController!, mapViewController!, profileViewController!]
        

        super.viewDidLoad()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.navigationItem.title = item.title
    }
    
}
