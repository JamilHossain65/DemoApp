//
//  MapViewController.swift
//  Demo


import UIKit
import GoogleMaps

extension CLLocationCoordinate2D {
    func isEqual(_ coord: CLLocationCoordinate2D) -> Bool {
        return (fabs(self.latitude - coord.latitude) < .ulpOfOne) && (fabs(self.longitude - coord.longitude) < .ulpOfOne)
    }
}


class MapViewController: UIViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet private weak var mapCenterPinImage: UIImageView!
    @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
    //private var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1000
    
    //Sound Record
    let audioManager = AudioManager()
    //ui button
    var recordButton : UIButton!
    var playButton   : UIButton!
    var playTrackView: PlayerView!
    
    var soundArray:[SoundInfo] = [SoundInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        //record audio
        audioManager.initAudio()
        audioManager.delegate = self
    }
    
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
        
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: ["market"]) { places in
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

// MARK: - TypesTableViewControllerDelegate
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
    
    private func addPinAt(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.title = "Hello Jamil"
        marker.icon = UIImage(named: "map_pin")
        marker.map = self.mapView
        
        let soundInfo = SoundInfo()
        soundInfo.coordinate = position
        soundInfo.audioFile = "recording\(Date.timeStamp).flac"
        soundInfo.id = Date.timeStamp
        soundInfo.isRecord = true
        soundArray.append(soundInfo)
        
        loadRecordingUI()
    }
    
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
        guard let infoView = UIView.xibName("MarkerInfoView") as? MarkerInfoView else {
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
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        addPinAt(position: coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        
        let playFakeButton = UIButton()
        
        if let _player = player, _player.isPlaying {
            playFakeButton.isSelected = true
            audioManager.soundPlayer(.stop)
            
        }else{
            playFakeButton.isSelected = false
            
            for soundInfo in soundArray {
                if ((soundInfo.coordinate?.isEqual(marker.position)) != nil){
                    print("found soundInfo::\(soundInfo.id)")
                    audioManager.soundPlayer(id:soundInfo.id,.play)
                    break
                }
            }
        }
        
        //playButtonTapped(playButton: playFakeButton)
        
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
}

//MARK: - AudioManagerDelegate
extension MapViewController:AudioManagerDelegate {
    
    func loadRecordingUI(id:Int64? = 0){
        
        if playTrackView != nil {
            playTrackView.removeFromSuperview()
        }
        
        recordButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 122, y: self.view.frame.size.height - 64, width: 60, height: 60))
        recordButton.center = CGPoint(x:self.view.center.x, y: recordButton.center.y)
        recordButton.layer.borderWidth  = 2.0
        recordButton.layer.cornerRadius = 30.0
        recordButton.layer.borderColor  = UIColor.white.cgColor
        
        
        recordButton.setTitle("Speak", for: .normal)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        recordButton.backgroundColor = .gray
        view.addSubview(recordButton)
    }
    
    func playSoundUI(){
        //hide record button
        if recordButton != nil {
            recordButton.removeFromSuperview()
        }
        
        //        let codeBd = flag(from: "bd")
        //        let codeEn = flag(from: "us")
        
        playButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 122, y: self.view.frame.size.height - 64, width: 60, height: 60))
        //playButton.center = CGPoint(x:self.view.center.x, y: playButton.center.y)
        playButton.layer.borderWidth  = 1.0
        playButton.layer.cornerRadius = 30.0
        playButton.layer.borderColor  = UIColor.lightGray.cgColor
        
        playButton.titleLabel?.font   = UIFont(name: "Arial", size: 25)
        
        playButton.setTitle("play", for: .normal)
        playButton.setTitle("stop", for: .selected)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        playTrackView.addSubview(playButton)
        playButton.backgroundColor = .brown
    }
    
    func playViewUI(){
        //hide record button
        recordButton.removeFromSuperview()
        
        playTrackView = UIView.xibName("PlayerView") as? PlayerView
        
        var mFrame = playTrackView.frame
        mFrame.origin.y = self.view.frame.size.height - mFrame.size.height
        playTrackView.frame = mFrame
        
        playTrackView.playButton.setImage(UIImage(named: "play"), for: .normal)
        playTrackView.playButton.setImage(UIImage(named: "pause"), for: .selected)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeLeft.direction = .down
            self.view.addGestureRecognizer(swipeLeft)
        
        
        playTrackView.onAction = { button in
            self.playButtonTapped(playButton: button)
            
        }
        
        self.view.addSubview(playTrackView)
        
        /*
        
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let playviewHeight:CGFloat = screenWidth*161/512
        
        playTrackView = UIView(frame: CGRect(x: 0, y: screenHeight - playviewHeight - 20, width: 300, height: 80))
        playTrackView.backgroundColor = UIColor.init(patternImage: UIImage(named: "play_track")!)
        
        self.view.addSubview(playTrackView)
        
        //add a button on playview
        playButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        //playButton.center = CGPoint(x:playTrackView.center.x, y: playTrackView.center.y)
        playButton.setTitle("play", for: .normal)
        playButton.setTitle("stop", for: .selected)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)

        playButton.backgroundColor = .brown
        playTrackView.addSubview(playButton)
 */
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            print("Swipe Down")
            UIView.animate(withDuration: 0.5, delay: 0.1,
                           animations: { () -> Void in
                            self.playTrackView.isHidden = true
                           }, completion:{ (finish) in
                            let soundFile = self.soundArray.last
                            print("swipe file id::\(soundFile?.id)")
                            let id = soundFile?.id ?? 0
                            
                            self.audioManager.soundPlayer(id:id,.stop)
                           })
        }
    }
    
    @objc func recordTapped(){
        print("recordTapped")
        stopRecord()
        
        if let soundInfo = soundArray.filter{ $0.isRecord == true }.first {
            print("soundInfo::\(soundInfo.id ?? 0)")
            audioManager.recordTapped(id:soundInfo.id ?? 0)
            soundInfo.isRecord = false
        }
        
        recordButton.isSelected = !recordButton.isSelected
        recordButton.setTitle("Record", for: .normal)
        recordButton.setTitle("Stop", for: .selected)
        recordButton.backgroundColor = recordButton.isSelected ? .red: .gray
        
        if !recordButton.isSelected {
            //show play button ui
            //playSoundUI()
            playViewUI()
        }
        
    }
    
    func stopRecord(){
        if audioManager.audioRecorder != nil {
            audioManager.audioRecorder.stop()
        }
    }
    
    @objc func playButtonTapped(playButton:UIButton){
        playButton.isSelected = !playButton.isSelected
        
        let soundFile = soundArray.last
        print("soundFile?.id::\(soundFile?.id ?? 0)")
        let id = soundFile?.id ?? 0
        if playButton.isSelected {
            audioManager.soundPlayer(id:id,.play)
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
}
