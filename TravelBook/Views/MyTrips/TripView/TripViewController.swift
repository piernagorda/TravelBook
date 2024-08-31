//
//  TripViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-29.
//

import UIKit
import MapKit

class TripViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    let reuseIdentifier = "datacell7"

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    private var previousLocation: LocationModel?
    private var zoomOutRegion: MKCoordinateRegion?
    
    public var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "TripViewCell", bundle: nil)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        map.delegate = self
        setUpMap()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TripViewCellController else {
            return UICollectionViewCell()
        }
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        cell.image?.image = UIImage(named: currentUser?.trips[index].locations[indexPath.row].countryA2code.lowercased() ?? "default-image2")
        cell.city?.text = currentUser?.trips[index].locations[indexPath.row].city
        cell.country?.text = currentUser?.trips[index].locations[indexPath.row].country
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentUser?.trips[index].locations.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if previousLocation == nil {
            previousLocation = currentUser!.trips[index].locations[indexPath.row]
            let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentUser!.trips[index].locations[indexPath.row].latitude),
                                                  longitude: CLLocationDegrees(currentUser!.trips[index].locations[indexPath.row].longitude))

                    let region = MKCoordinateRegion(
                        center: location,
                        latitudinalMeters: 10000, // Zoom level - adjust as needed
                        longitudinalMeters: 10000  // Zoom level - adjust as needed
                    )
            map.setRegion(region, animated: true)
        } else {
            // Step 1: Set the region of all the coordinates
            let newLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentUser!.trips[index].locations[indexPath.row].latitude),
                                                     longitude: CLLocationDegrees(currentUser!.trips[index].locations[indexPath.row].longitude))

            map.setRegion(zoomOutRegion!, animated: true)
            
            // Step 2: After a delay, zoom into the new location
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let zoomedInRegion = MKCoordinateRegion(
                    center: newLocation,
                    latitudinalMeters: 10000, // Adjust these values for the zoom level at the new location
                    longitudinalMeters: 10000
                )
                self.map.setRegion(zoomedInRegion, animated: true)
            }
        }
    }
    
}

extension TripViewController {
    
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
            self.zoomOutRegion = region
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
    
    private func calculateDistanceCovered(_ locations: [LocationModel]) -> Int {
        var distanceCovered: Double = 0.0
        
        for i in 0 ..< locations.count - 1 {
            let locationA = CLLocation(latitude: locations[i].latitude, longitude: locations[i].longitude)
            let locationB = CLLocation(latitude: locations[i+1].latitude, longitude: locations[i+1].longitude)
            distanceCovered += locationA.distance(from: locationB)
        }
        
        return Int(distanceCovered)
    }
}
