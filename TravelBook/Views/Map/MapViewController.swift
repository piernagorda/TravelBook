//
//  MapViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 7/12/24.
//

import UIKit
import MapKit
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        super.navigationController?.navigationBar.isHidden = true
        setUpMap()

        map.delegate = self
        // Do any additional setup after loading the view.
    }
    
    private func setUpMap() {
        var trip: TripModel = .mockOne()
        
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
       
            let annotation2 = MKPointAnnotation()
            annotation2.coordinate.latitude = locations[i+1].latitude
            annotation2.coordinate.longitude = locations[i+1].longitude
            annotation2.title = locations[i+1].city
            annotation2.subtitle = locations[i+1].country
            self.map.addAnnotation(annotation2)

            annotations.append(annotation2.coordinate)
        
            map.addOverlay(MKPolyline(coordinates: annotations, count: 2))
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let polylineRenderer  = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.lineWidth = 3.0
        return polylineRenderer
    }
}
