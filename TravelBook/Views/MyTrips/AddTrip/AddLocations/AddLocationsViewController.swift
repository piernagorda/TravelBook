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
        self.navigationController?.topViewController?.navigationItem.leftBarButtonItem?.tintColor = .black
        self.navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Locations", style: .plain, target: self, action: #selector(addLocations))
        self.navigationController?.topViewController?.navigationItem.rightBarButtonItem?.tintColor = .black
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let location = searching ? filterData[indexPath.row] : countriesInTrip[indexPath.row]
        
        cell.textLabel?.text = "\(location.city), \(location.country)"
        
        // Check if the location is already selected and add a checkmark
        if searchIfLocationInArray(location: location, array: countriesInTrip) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = searching ? filterData[indexPath.row] : countriesInTrip[indexPath.row]

        // Add location if not already selected
        if !searchIfLocationInArray(location: selectedLocation, array: countriesInTrip) {
            var updatedLocation = selectedLocation
            updatedLocation.countryA2code = countryToAlpha2Code[selectedLocation.country]?.lowercased() ?? ""
            countriesInTrip.append(updatedLocation)
        } else {
            // If already selected, remove it
            countriesInTrip.removeAll { $0.city.uppercased() == selectedLocation.city.uppercased() }
        }

        tableView.reloadData() // Refresh to update checkmarks
    }

}

extension AddLocationsViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterData = []
        
        if searchText == "" {
            self.searching = false
            filterData = []
        } else {
            searching = true
            Task { @MainActor [weak self] in
                let geocoder = CLGeocoder()
                
                // Create a locale set to English (US)
                let locale = Locale(identifier: "en_US")
                
                // Perform synchronous geocoding with the English locale
                geocoder.geocodeAddressString(searchText, in: nil, preferredLocale: locale) { (placemarks, error) in
                    if let error = error {
                        print("Geocoding failed: \(error.localizedDescription)")
                        return
                    }

                    if let placemarks = placemarks, !placemarks.isEmpty {
                        for x in placemarks {
                            let city: LocationModel = LocationModel(country: x.country!,
                                                                    city: x.name!,
                                                                    latitude: x.location!.coordinate.latitude,
                                                                    longitude: x.location!.coordinate.longitude,
                                                                    countryA2Code: "")
                            if !(self!.searchIfLocationInArray(location: city, array: self!.filterData)) {
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
