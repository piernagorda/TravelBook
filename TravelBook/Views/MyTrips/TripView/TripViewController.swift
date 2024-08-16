//
//  TripViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-29.
//

import UIKit
import MapKit

class TripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
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
        map.delegate = self
        setUpMap()
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
    
    
    
    private func setUpMap() {
        let trip: TripModel = currentUser!.trips[index]
        var coordinates: [CLLocationCoordinate2D] = []
        let locations = trip.locations
        let count = locations.count - 1
        
        for i in 0 ..< count {
            var annotations : [CLLocationCoordinate2D] = []
            
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = locations[i].latitude
            annotation.coordinate.longitude = locations[i].longitude
            annotation.title = locations[i].city
            annotation.subtitle = locations[i].country
            self.map.addAnnotation(annotation)
            annotations.append(annotation.coordinate)
            coordinates.append(annotation.coordinate)
       
            let annotation2 = MKPointAnnotation()
            annotation2.coordinate.latitude = locations[i+1].latitude
            annotation2.coordinate.longitude = locations[i+1].longitude
            annotation2.title = locations[i+1].city
            annotation2.subtitle = locations[i+1].country
            self.map.addAnnotation(annotation2)
            annotations.append(annotation2.coordinate)
            coordinates.append(annotation2.coordinate)
        
            // map.addOverlay(MKPolyline(coordinates: annotations, count: 2))
            let startCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(trip.locations[i].latitude),
                                                         longitude: CLLocationDegrees(trip.locations[i].longitude))
            let endCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(trip.locations[i+1].latitude),
                                                       longitude: CLLocationDegrees(trip.locations[i+1].longitude))
            // Draw a curved line between the start and end locations
            drawCurvedLineBetween(startCoordinate, endCoordinate, mapView: self.map)
        }
        
        // Calculate the region to include all annotations
        if !coordinates.isEmpty {
            let region = regionForCoordinates(coordinates: coordinates)
            map.setRegion(region, animated: true)
        }
    }
    
    func drawCurvedLineBetween(_ start: CLLocationCoordinate2D, _ end: CLLocationCoordinate2D, mapView: MKMapView) {
        // This has been done using Bezier quadratic curves. More info here: https://www.youtube.com/watch?v=oRd3l7ILTNY
        let startPoint = CGPoint(x: start.latitude, y: start.longitude)
        let endPoint = CGPoint(x: end.latitude, y: end.longitude)

        // Calculate the distance between the two points
        let distance = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y)

        // Determine the amount to offset the control point, increasing with distance
        let curveHeight = distance * 0.2 // You can adjust this factor to make the curve more or less pronounced

        // Find the midpoint
        let midPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)

        // Control point is offset perpendicular to the line between start and end
        let controlPoint = CLLocationCoordinate2D(
            latitude: midPoint.x + curveHeight,
            longitude: midPoint.y
        )
        
        var curveCoordinates = [CLLocationCoordinate2D]()
        
        let steps = 500
        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let x = (1 - t) * (1 - t) * start.latitude + 2 * (1 - t) * t * controlPoint.latitude + t * t * end.latitude
            let y = (1 - t) * (1 - t) * start.longitude + 2 * (1 - t) * t * controlPoint.longitude + t * t * end.longitude
            curveCoordinates.append(CLLocationCoordinate2D(latitude: x, longitude: y))
        }
        
        let polyline = MKPolyline(coordinates: curveCoordinates, count: curveCoordinates.count)
        mapView.addOverlay(polyline)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            // Use a navy blue color
            renderer.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.8) // Adjust alpha for desired opacity
            // Adjust line width for a thinner line
            renderer.lineWidth = 4.0
            // Optionally, create a dashed line pattern
            // renderer.lineDashPattern = [NSNumber(value: 4), NSNumber(value: 8)] // Dash pattern: 4 points on, 8 points off
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    // Function to calculate the region to encompass all coordinates with additional padding
    private func regionForCoordinates(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = CLLocationDegrees(90.0)
        var maxLat = CLLocationDegrees(-90.0)
        var minLon = CLLocationDegrees(180.0)
        var maxLon = CLLocationDegrees(-180.0)
        
        for coordinate in coordinates {
            if coordinate.latitude < minLat {
                minLat = coordinate.latitude
            }
            if coordinate.latitude > maxLat {
                maxLat = coordinate.latitude
            }
            if coordinate.longitude < minLon {
                minLon = coordinate.longitude
            }
            if coordinate.longitude > maxLon {
                maxLon = coordinate.longitude
            }
        }
        
        // Adjust padding factor to zoom out more
        let paddingFactor: CLLocationDegrees = 1.3
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * paddingFactor,
                                    longitudeDelta: (maxLon - minLon) * paddingFactor)
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLon + maxLon) / 2)
        
        return MKCoordinateRegion(center: center, span: span)
    }
}
