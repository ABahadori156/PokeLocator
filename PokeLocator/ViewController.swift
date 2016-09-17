//
//  ViewController.swift
//  PokeLocator
//
//  Created by Pasha Bahadori on 9/16/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    //We got how to initialize GeoFire from the GeoFire github documentation - ALWAYS LOOK UP DOCUMENTATION
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference
    
    //Executed when view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //This means the map will follow with the user's location as he moves (like in PokemonGo)
        //As the location updates come in, we want to use the trackingMode to keep the map centered
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        //INITIALIZING GEOFIRE
        //This is a Firebase Database reference to the general database I'm using
        geoFireRef = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        
    }
    
    //This code is executed whenever the view appears
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        
        //This means we only get the location of the user WHEN THE APP IS IN USE otherwise it'll drain the battery
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            //Yes we want to show the user's location on the map
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
            //If we ask for the user's authorization and they say yes, then we have to go ahead and update the map.
        }
    }
    
    //If we ask for the user's authorization and they say yes, then we have to go ahead and update the map.
    //When the user says yes or no, we want this function to be called so we can get their location or not
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        //If the user says yes to authorization in use, then let's get the user location triggered so we get their location on the map
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    //Now we want to center our map whenever the user accesses their map
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        //This function will take the information from coordinateRegion and use it to center the user on the map
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Now we want to update the call back function for when the user's location actually is updated
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //We only want the map to center once when the app first loads
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    //Now we want to get the graphic of Ash showing on the user location instead of the blue circle default
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //We're going to create a custom annotation for that user
        //This will pass in anannotation thats supposed to be on the map and the user location is an annotation
        
        var annotationView: MKAnnotationView?
        
        //All this is saying is 'If this is a user location annotation, we want to change what's happening inside'
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
        }
        return annotationView
    }
    
    
    @IBAction func spotRandomPokemon(_ sender: UIButton) {
        
    }
  

}

