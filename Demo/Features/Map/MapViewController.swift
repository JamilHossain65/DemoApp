//
//  MapViewController.swift
//  Feed Me


import UIKit
import GoogleMaps

class MapViewController: UIViewController {
  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet private weak var mapCenterPinImage: UIImageView!
  @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
  private var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
  private let locationManager = CLLocationManager()
  private let dataProvider = GoogleDataProvider()
  private let searchRadius: Double = 1000
    
    //Audio
    var recordButton : UIButton!
    var playButton : UIButton!
    let audioManager = AudioManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    mapView.delegate = self
    
    //record audio
    audioManager.initAudio()
    audioManager.delegate = self
    loadRecordingUI()
    playSoundUI()
  }
  
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    guard let navigationController = segue.destination as? UINavigationController,
//      let controller = navigationController.topViewController as? TypesTableViewController else {
//        return
//    }
//    controller.selectedTypes = searchedTypes
//    controller.delegate = self
//  }
  
  private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
    let geocoder = GMSGeocoder()
    
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      self.addressLabel.unlock()
      
      guard let address = response?.firstResult(), let lines = address.lines else {
        return
      }
      
      self.addressLabel.text = lines.joined(separator: "\n")
      
      let labelHeight = self.addressLabel.intrinsicContentSize.height
      self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                          bottom: labelHeight, right: 0)
      
      UIView.animate(withDuration: 0.25) {
        self.pinImageVerticalConstraint.constant = ((labelHeight - self.view.safeAreaInsets.top) * 0.5)
        self.view.layoutIfNeeded()
      }
    }
  }
  
  func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
    mapView.clear()
    
    dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
      places.forEach {
        let marker = PlaceMarker(place: $0)
        marker.map = self.mapView
      }
    }
  }
  
    @IBAction func refreshPlaces(_ sender: Any) {
        fetchNearbyPlaces(coordinate: mapView.camera.target)
    }
    
}

//// MARK: - TypesTableViewControllerDelegate
//extension MapViewController: TypesTableViewControllerDelegate {
//  func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
//    searchedTypes = controller.selectedTypes.sorted()
//    dismiss(animated: true)
//    fetchNearbyPlaces(coordinate: mapView.camera.target)
//  }
//}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard status == .authorizedWhenInUse else {
      return
    }
    
    locationManager.startUpdatingLocation()
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    
    mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    locationManager.stopUpdatingLocation()
    fetchNearbyPlaces(coordinate: location.coordinate)
  }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    reverseGeocodeCoordinate(position.target)
  }
  
  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    addressLabel.lock()
    
    if (gesture) {
      mapCenterPinImage.fadeIn(0.25)
      mapView.selectedMarker = nil
    }
  }
  
  func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
    guard let placeMarker = marker as? PlaceMarker else {
      return nil
    }
    guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
      return nil
    }
    
    infoView.nameLabel.text = placeMarker.place.name
    if let photo = placeMarker.place.photo {
      infoView.placePhoto.image = photo
    } else {
      infoView.placePhoto.image = UIImage(named: "generic")
    }
    
    return infoView
  }
  
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    mapCenterPinImage.fadeOut(0.25)
    return false
  }
  
  func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
    mapCenterPinImage.fadeIn(0.25)
    mapView.selectedMarker = nil
    return false
  }
}

extension MapViewController:AudioManagerDelegate {
    
    func loadRecordingUI(){
        recordButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 75, y: self.view.frame.size.height - 44, width: 70, height: 40))
        recordButton.setTitle("Speak", for: .normal)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        recordButton.backgroundColor = .gray
        recordButton.layer.cornerRadius = 7
        restartSpeech(sec:5)
        self.view.addSubview(recordButton)
    }
    
    func playSoundUI(){
//        let codeBd = flag(from: "bd")
//        let codeEn = flag(from: "us")
        
        playButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 122, y: self.view.frame.size.height - 44, width: 40, height: 40))
        
        playButton.layer.borderWidth  = 1.0
        playButton.layer.cornerRadius = 20.0
        playButton.layer.borderColor  = UIColor.lightGray.cgColor
        
        playButton.titleLabel?.font   = UIFont(name: "Arial", size: 25)
        
        playButton.setTitle("play", for: .normal)
        playButton.setTitle("stop", for: .selected)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        self.view.addSubview(playButton)
        playButton.backgroundColor = .brown
    }
    
    @objc func recordTapped(){
        print("recordTapped")
        stopRecord()
        
        audioManager.recordTapped()
        recordButton.isSelected = !recordButton.isSelected
        recordButton.setTitle("Record", for: .normal)
        recordButton.setTitle("Stop", for: .selected)
        recordButton.backgroundColor = recordButton.isSelected ? .red: .gray
    }
    
    func stopRecord(){
        if audioManager.audioRecorder != nil {
            audioManager.audioRecorder.stop()
        }
    }
    
    @objc func playButtonTapped(){
        playButton.isSelected = !playButton.isSelected
        
        if playButton.isSelected{
            audioManager.soundPlayer(.play)
        }else{
            audioManager.soundPlayer(.stop)
        }
    }
    
    //Mark: Audio manager Delegate
    func recordDidFinish(){
        print("recordDidFinish....")
        //let language = playButton.isSelected ? "bn":"en"
        //convertToText2(lang: language) //todo enable if need translate
    }
    
    func restartSpeech(sec:Double){
        self.perform(#selector(resetSpeech), with: nil, afterDelay: sec)
    }
    
    @objc func resetSpeech(){
        //recordTapped() //enable this line for aumatic recording when app launch
        //restartSpeech(sec:5)
    }
}
