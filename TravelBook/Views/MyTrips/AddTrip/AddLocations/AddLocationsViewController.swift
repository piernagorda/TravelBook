import UIKit
import CoreLocation

class AddLocationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var countriesInTrip: [LocationModel] = []
    private var filterData: [LocationModel] = []
    private var searching: Bool = false
    public var callback: (_ closeModal: Bool, _ locations: [LocationModel]?) -> Void = { closeModal, locations in () }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        self.navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeModal))
        self.navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Locations", style: .plain, target: self, action: #selector(addLocations))
        super.viewDidLoad()
    }
    
    @objc func closeModal() { callback(true, nil) }
    
    @objc func addLocations() { callback(false, self.countriesInTrip) }
    
}

extension AddLocationsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func searchIfLocationInArray(location: LocationModel, array: [LocationModel]) -> Bool{
        for x in array {
            if location.city.uppercased() == x.city.uppercased() {
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searching ? filterData.count : countriesInTrip.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if searching {
            cell.textLabel?.text = filterData[indexPath.row].city + ", " + filterData[indexPath.row].country
        }
        else {
            cell.textLabel?.text = countriesInTrip[indexPath.row].city + ", " + countriesInTrip[indexPath.row].country
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var locationToAppend = filterData[indexPath.row]
        locationToAppend.countryA2code =  countryToAlpha2Code[locationToAppend.country] ?? ""
        print(locationToAppend.countryA2code)
        countriesInTrip.append(filterData[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension AddLocationsViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterData = []
        if searchText == "" {
            self.searching = false
            filterData = []
        }
        else {
            searching = true
            Task { @MainActor [weak self] in
                let geocoder = CLGeocoder()
                do{
                    let req : [CLPlacemark] = try await geocoder.geocodeAddressString(searchText)
                    if (!req.isEmpty) {
                        for x in req {
                            
                           
                            
                            let city: LocationModel = LocationModel(country: x.country!,
                                                                    city: x.name!,
                                                                    latitude: x.location!.coordinate.latitude,
                                                                    longitude: x.location!.coordinate.longitude,
                                                                    countryA2Code: "")
                            if !searchIfLocationInArray(location: city, array: self!.filterData) {
                                self?.filterData.append(city)
                            }
                        }
                        self!.tableView.reloadData()
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
}
