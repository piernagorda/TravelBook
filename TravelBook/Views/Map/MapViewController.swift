//
//  MapViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 7/12/24.
//

import UIKit
import MapKit
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource {

    
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    let buffer = 3 //max items visible at the same time.
    var totalElements = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        super.navigationController?.navigationBar.isHidden = true
        setUpMap()

        map.delegate = self
        // Do any additional setup after loading the view.
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "datacell", for: indexPath) as? MyTripsViewCell else{
            return UICollectionViewCell()
        }
        let currentCell = indexPath.row % mockUser!.trips.count
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        cell.titleLabel?.text = mockUser!.trips[indexPath.row].title
        cell.yearLabel?.text = "\(mockUser!.trips[indexPath.row].year)"
        cell.image?.image = mockUser!.trips[indexPath.row].tripImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalElements = buffer + mockUser!.trips.count
            return totalElements
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

extension MapViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let itemSize = collectionView.contentSize.width/CGFloat(totalElements)
        
        if scrollView.contentOffset.x > itemSize*CGFloat(mockUser!.trips.count){
            collectionView.contentOffset.x -= itemSize*CGFloat(mockUser!.trips.count)
        }
        if scrollView.contentOffset.x < 0  {
            collectionView.contentOffset.x += itemSize*CGFloat(mockUser!.trips.count)
        }
    }
}
