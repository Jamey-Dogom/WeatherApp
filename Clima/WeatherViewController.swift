//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
// module that allows us to use gps of iphone
import CoreLocation

// have to import pods
import Alamofire
import SwiftyJSON
import SVProgressHUD

// weather class is a subclass of uiview and it conforms to the rules of CLdelegate
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {

    
    @IBAction func cFToggle(_ sender: UISwitch) {
        
        if sender.isOn {
            
            temperatureLabel.text = (String ((weatherDataModel.temperature - 32) * 5/9)) + "°"
        }
        
        else {
             temperatureLabel.text = (String (weatherDataModel.temperature)) + "°"
        }
        
        
      
    }
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "d2403e638f70eb1a9d198858aa1adb12"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManger = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        
        locationManger.delegate = self
        
        // sets the accuracy of location data
        // option best for battery
        locationManger.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // get location data from the user while app is in use
        locationManger.requestWhenInUseAuthorization()
        
        // find location and gives message when it finds it
        locationManger.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url : String, parameters: [String : String]){
        
        // url is weatherurl , get request: retreives data, params from our locationManager
        // responseJSON contains data we need
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            // does this in background
            response in
            if response.result.isSuccess {
                print("Success got the weather data!")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                // print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        
        // Optional binding to prevent errors when unwrapping using !
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = (Int(tempResult - 273.15) * 9/5 + 32)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
      
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
       // update the weather image
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        // update the city name
        cityLabel.text = weatherDataModel.city
        // update the temperature
        temperatureLabel.text = (String (weatherDataModel.temperature)) + "°"
        
        
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    // tells delagate that new location data has been received
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // CLLocation is an array with location data
        // last value is the most accurate
        let location = locations[locations.count-1]
        
        // if value is less than 0 then location is invalid
        if location.horizontalAccuracy > 0 {
            // save the user's battery
            locationManger.stopUpdatingLocation()
            // print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            // combine both lat and long into dictionary
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        // Weather api says to call city by q
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
            }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self

    }
    
    
   
    
    
    }
    
    
    
    
}


