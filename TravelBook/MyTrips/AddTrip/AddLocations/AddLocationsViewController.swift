import UIKit
import CoreLocation

class AddLocationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    public var countriesInTrip: [LocationModel] = []
    private var filterData: [LocationModel] = []
    private var searching: Bool = false
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        super.viewDidLoad()
    }
    
    @IBAction func cancelPressed(){
        dismiss(animated: true)
    }
    
    @IBAction func donePressed(){
        if (countriesInTrip.count != 0 ){
            // temporaryTrip = TripModel(locations: countriesInTrip, year: 0, title: "", description: "")
            // mockUser?.addTrip(trip: <#T##TripModel#>)
        }
        dismiss(animated: true)
    }

}

func searchIfLocationInArray(location: LocationModel, array: [LocationModel]) -> Bool{
    for x in array{
        if (location.city.uppercased() == x.city.uppercased()){
            return true
        }
    }
    return false
}

extension AddLocationsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searching){
            return filterData.count
        }
        else{
            return countriesInTrip.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if (searching){
            cell.textLabel?.text = filterData[indexPath.row].city+", "+filterData[indexPath.row].country
        }
        else{
            cell.textLabel?.text = countriesInTrip[indexPath.row].city+", "+countriesInTrip[indexPath.row].country
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        countriesInTrip.append(filterData[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension AddLocationsViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterData = []
        if (searchText == "" ){
            self.searching = false
            filterData=[]
        }
        else{
            searching = true
            Task{ @MainActor [weak self] in
                let geocoder = CLGeocoder()
                do{
                    let req : [CLPlacemark] = try await geocoder.geocodeAddressString(searchText)
                    if (!req.isEmpty){
                        for x in req{
                            let city: LocationModel = LocationModel(country: x.country!,
                                                                    city: x.name!,
                                                                    latitude: x.location!.coordinate.latitude,
                                                                    longitude: x.location!.coordinate.longitude)
                            if (!searchIfLocationInArray(location: city, array: self!.filterData)){
                                self?.filterData.append(city)
                            }
                        }
                        self!.tableView.reloadData()
                    }
                    else{
                        print("Nothing found")
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
}
