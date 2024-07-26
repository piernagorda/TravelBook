//
//  TripViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-29.
//

import UIKit
// import MapboxMaps

class TripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var coverImage: UIImageView?
    @IBOutlet weak var tableView: UITableView?
    
    public var index: Int!
    /*
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()
     */

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        self.coverImage?.image = UIImage(named: currentUser?.trips[index].tripImage ?? "default-image")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let city = currentUser?.trips[index].locations[indexPath.row].city
        let country = currentUser?.trips[index].locations[indexPath.row].country
        cell.textLabel?.text = (city ?? "") + ", " + (country ?? "")
        cell.imageView?.image = UIImage(named: currentUser?.trips[index].locations[indexPath.row].countryA2code ?? "AZ")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentUser?.trips[index].locations.count ?? 0
    }
        // Set the map's center coordinate and zoom level
        /*
        let originLatitude = Double(mockUser!.trips[self.index!].locations[0].latitude)
        let originLongitude = Double(mockUser!.trips[self.index!].locations[0].longitude)
        let destinationLatitude = Double(mockUser!.trips[self.index!].locations[1].latitude)
        let destinationLongitude = Double(mockUser!.trips[self.index!].locations[1].longitude)
        // Washington, D.C.
        let destination = CLLocationCoordinate2DMake(CLLocationDegrees(mockUser!.trips[self.index!].locations[1].latitude), CLLocationDegrees(mockUser!.trips[self.index!].locations[1].longitude))
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: (originLatitude + destinationLatitude)/2,
                                                      longitude: (originLongitude + destinationLongitude)/2)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate,
                                                                  zoom: 3),
                                     styleURI: .streets)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.setupExample()
        }.store(in: &cancelables)
         */
    /*
    func setupExample() {
        
        let origin = CLLocationCoordinate2DMake(CLLocationDegrees(mockUser!.trips[self.index!].locations[0].latitude), CLLocationDegrees(mockUser!.trips[self.index!].locations[0].longitude))
        let destination = CLLocationCoordinate2DMake(CLLocationDegrees(mockUser!.trips[self.index!].locations[1].latitude), CLLocationDegrees(mockUser!.trips[self.index!].locations[1].longitude))
        let arcLine = arc(start: origin, end: destination)
         
        // Add the layers to be rendered on the map.
        addLayers(for: arcLine)

        // Begin animating the airplane across the route line.
        startAnimation(routeLine: arcLine)
    }

    func arc(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> LineString {
        let line = LineString([start, end])
        let distance = Int(start.distance(to: end))

        var coordinates = [CLLocationCoordinate2D]()
        let steps = 500
        var index = 0

        while index < distance {
            index += distance / steps
            let coord = line.coordinateFromStart(distance: CLLocationDistance(index))!
            coordinates.append(coord)
        }

        return LineString(coordinates.compactMap({ $0 }))
    }

    func addLayers(for routeLine: LineString) {
        // Define the source data and style layer for the airplane's route line.
        var airplaneRoute = GeoJSONSource(id: "airplane-route")
        airplaneRoute.data = .feature(Feature(geometry: routeLine))

        var lineLayer = LineLayer(id: "line-layer", source: airplaneRoute.id)
        lineLayer.lineColor = .constant(StyleColor(.red))
        lineLayer.lineWidth = .constant(3.0)
        lineLayer.lineCap = .constant(.round)

        // Define the source data and style layer for the airplane symbol.
        var airplaneSymbol = GeoJSONSource(id: "airplane-symbol")
        let point = Point(routeLine.coordinates[0])
        airplaneSymbol.data = .feature(Feature(geometry: point))

        var airplaneSymbolLayer = SymbolLayer(id: "airplane", source: airplaneSymbol.id)
        // "airport" is the name the image that belongs in the style's sprite by default.
        airplaneSymbolLayer.iconImage = .constant(.name("airport"))
        airplaneSymbolLayer.iconRotationAlignment = .constant(.map)
        airplaneSymbolLayer.iconAllowOverlap = .constant(true)
        airplaneSymbolLayer.iconIgnorePlacement = .constant(true)
        // Get the "bearing" property from the point's feature dictionary,
        // and use that value to determine the rotation angle of the airplane icon.
        airplaneSymbolLayer.iconRotate = .expression(Exp(.get) {
            "bearing"
        })

        // Add the sources and layers to the map style.
        try! mapView.mapboxMap.addSource(airplaneRoute)
        try! mapView.mapboxMap.addLayer(lineLayer)

        try! mapView.mapboxMap.addSource(airplaneSymbol)
        try! mapView.mapboxMap.addLayer(airplaneSymbolLayer, layerPosition: nil)
    }

    func startAnimation(routeLine: LineString) {
        var runCount = 0

        _ = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { [weak self] timer in

            guard let self = self else { return }

            let coordinate = routeLine.coordinates[runCount]
            let nextCoordinate = routeLine.coordinates[runCount + 1]

            // Identify the new coordinate to animate to, and calculate
            // the bearing between the new coordinate and the following coordinate.
            var geoJSON = Feature(geometry: Point(coordinate))
            geoJSON.properties = ["bearing": .number(coordinate.direction(to: nextCoordinate))]

            // Update the airplane source layer with the new coordinate and bearing.
            self.mapView.mapboxMap.updateGeoJSONSource(withId: "airplane-symbol",
                                                                  geoJSON: .feature(geoJSON))

            runCount += 1

            if runCount == 500 {
                timer.invalidate()
            }
        }

    }
     */
}
