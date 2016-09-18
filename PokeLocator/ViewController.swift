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
    var geoFireRef: FIRDatabaseReference!
    
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
    
    
    
    
    //REGIONWILLCHANGEANIMATED handles swiping and showing things around the map
    //Here we make sure the map updates whenever you're panning it because remember the query is 2.5 kilometers, what if I swipe over to 5 kilometers? I want those pokemon to appear
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        //Here we grab the location of whereveer the center of the map isw where the user is scrolling, this time we get the long and lat
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: loc)
        
    }
    
    
    //Here when you tap the pokemon and the pop up appears with it, when you tap the map - We want to get the pokemon's location and get apple map's to show us a traveling direction to that sighted pokemon.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let anno = view.annotation as? PokeAnnotation {
            
            
            //This is the placemark for Apple maps
            var place = MKPlacemark(coordinate: anno.coordinate)
            let destination = MKMapItem(placemark: place)
            
            //This will show up as the name of the location on Apple Maps
            destination.name = "Pokemon Sighting"
            
            //We need to have a region distance and a region span in order to work with Apple maps
            //When you work with Apple Maps you need to have a placemark of where you start and where you're going, how far you want to be zoomed out, the region of the map
            //
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            //This is the center key and were do we want it centered, in the region - How far do we want to span out when we load the map
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
            
        }
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
    //Whenever addAnnotation is called in the 'showSightingsOnMap' func, THIS viewFor annotation function will be called and it will let you figure out what you want to do with your annotation and customize it before you drop it to the map. THIS IS WHERE WE DO OUR CUSTOM CONFIGURING FOR THE PIN IN THIS FUNCTION 'viewFor annotation'
    //Like cellForRowAtIndexPath function on a tableViewwhere we customize the cell before we show it to the user
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //We're going to create a custom annotation for that user
        //This will pass in anannotation thats supposed to be on the map and the user location is an annotation
        
        var annotationView: MKAnnotationView?
        var annoIdentifier = "Pokemon"
        
        
        //All this is saying is 'If this is a user location annotation, we want to change what's happening inside'
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
            
            //On the else if we'll create a reuseable annotation so basically if it can be reused, we'll reuse the annotation
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            //We'll dequeue it like how we dequeue a cell in a tableView to make it reuseable
            annotationView = deqAnno
            annotationView?.annotation = annotation
        } else {
            //If we don't have a annotation then we'll create one here
            //This function is called whenever we add an annotation to the mapView
            //WE DO THIS CLAUSE BECAUSE THE REUSE OF THE ANNOTATION MIGHT FAIL
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            
            //This is that call out pop up. We want the pop up to appear with the mapIcon
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        //e're making sure the annotation is NOT NIL, we're also making sure we are succesfully casting this annotation as a PokeAnnotation
        //If it fails like a user
        if let annotationView = annotationView, let anno = annotation as? PokeAnnotation {
            
            //If you show a callout on an annotation, you have to set the title (The self.title = self.pokemonName in PokeAnnotation) otherwise app will crash
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named:"\(anno.pokemonNumber)")
            
            let button = UIButton()
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(UIImage(named: "map"), for: .normal)
            
            annotationView.rightCalloutAccessoryView = button
        }
        
        
        
        return annotationView
    }
    
    //If you spot a random pokemon, it'll execute createSighting which will call geoFire.setLocation and when geoFire.setLocation happens, the GFEventType.keyEntered will be called
    //So anytime we add a new pokemon, it's going to call this and add it to the map
    
    
    //SIGHTING FUNCTION - a function to save a sighting of a pokemon and it's location to the database
    func createSighting(forLocation location: CLLocation, withPokemon pokeId: Int) {
        //Whenever you sight a pokemon and call this function, it will call geoFire base and set a location for that sighting data
        //We pass in the location and pass in the key that references that location
        geoFire.setLocation(location, forKey: "\(pokeId)")
    }
    
    
    
    
    
    //SHOW SIGHTINGS FUNCTION
    func showSightingsOnMap(location: CLLocation) {
        //Whenever we get the user's location, we want to show the sightings on the map where all the pokemon are - to display them on the screen
        //We need to create a query to show this - 2.5 withRadius means 2.5 kilometers
        let circleQuery = geoFire!.query(at: location, withRadius: 2.5)
        
        //We put a _ here because we don't need this variable. This will return something to us. WE don't care what it is we just want the action to occur. IF YOU DON'T WANT A RESULT, YOU CAN JUST USE _ IT'S A NEW SWIFT 3 THING
        //Whenever we find a key for a location, we want it to show that key's location on the map
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            //These could both be nil so we're making sure the key and location exist
            if let keyB = key, let locationB = location {
                //Here we created an annotation using our custom annotation we created in PokeAnnotation.swift - We're passing in the location of that SPECIFIC pokemon at that SPECIFIC location
                //The pokemonNumber is what was saved when we called the setLocation in the CREATESIGHTING function
                //When this annotation shows on the map, it will put the pin drop right there.
                let anno = PokeAnnotation(coordinate: (locationB.coordinate), pokemonNumber: Int(keyB)!)
                
                //The query will search the database for all the pokemon and their locations that were saved and add their annotations on the map
                self.mapView.addAnnotation(anno)
            }
        })
        
    }
    

    
    
    //On the map, when we press it, it adds a random Pokemon to the map. So when we press that pokeball, it adds a random pokemon in the middle of the map, so we can have a location to put it - Whatever the user is currently looking at
    //Everytime the Pokeball is pressed we create a sighting of a random pokemon in the middle of the map which calls GeoFire and sets the location for it on the Firebase Database
    @IBAction func spotRandomPokemon(_ sender: UIButton) {
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        let random = arc4random_uniform(151) + 1    //This is a range between 1-150
        
        createSighting(forLocation: loc, withPokemon: Int(random))
        print("Pokeball Tapped")
    }
  
    //Summary of the app so far
    // With .KeyEntered, anytime you add a new pokemon it's going to call this and add it on the map.
    // When the app first loads for the first time, showSightingsOnMap is going to be called and cycled through for every single pokemon on the map in it's specific geographical location and it's going to add it as an annotation - then the view for annotation will be called, we created an annoIdentifier 'Pokemon' if it's a user, use the Ash location, otherwise try a dequeue a resueable cell with the info in it - IF NOT createa a default one and in any of the cases let's customize the annotation by giving the image itself on the annotation giving it a Pokemon and then we set the CanShow call out on the map then we create a button - set the frame of it and give it the image of the map and the rightCalloutAccessoryView then we return it an dit'll show up on the map
    
    
}


// Challenge - Change spot Random Pokemon to have it show a collection view of all the pokemon, then tap which on you want to chose to
// When you tap the pokeball, it loads up a viewController with the collectionView of the pokemon and when you tap it, you have some sort of call back that creates a sighting
//Instead of putting in (random) for pokemon, you put the ID of the pokemon you chose









