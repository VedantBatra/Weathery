//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController , CLLocationManagerDelegate , changeCityDelegate{
    
    //Constants
    //http://api.openweathermap.org/data/2.5/weather
    //
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "a6752382db51cd619e10313a2f9eb7c0"
    
    //e72ca729af228beabd5d20e3b7749713 = angela's app id
    
    /***Get your own App ID at https://openweathermap.org/appid ****/
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String,parameters : [String:String]) {
        
        Alamofire.request(url, method : .get,parameters : parameters).responseJSON{
            response in
            if response.result.isSuccess{

                print("Success, got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error")
                self.cityLabel.text = "Connection Problem"
                
            }
        }
        
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON){
        
        //calling a value from the recieved json file
        if let tempResult = (json["main"]["temp"]).double {
        print("Temperature results are :",tempResult)
        
        weatherDataModel.temp = Int(tempResult - 273.15)
        
        weatherDataModel.city = json["name"].stringValue
            print(".............................",weatherDataModel.city)

        weatherDataModel.condition = json["weather"][0]["id"].intValue
            print(".............................",weatherDataModel.condition)
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        print(".............................",weatherDataModel.weatherIconName)
        
        
        updateUIWithWeatherData()
        }
    }
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temp)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
        
    }
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            //locationManager.delegate = nil
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            print(longitude,"Hello world")
            print(latitude)
            let params : [String : String] = ["lat" : latitude,"lon" : longitude,"appId" : APP_ID]
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
    func userEnteredNewCityName(city: String) {
        let params : [String: String] = ["q" : city,"appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


