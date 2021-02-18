//
//  ViewController.swift
//  PracticalTest
//
//  Created by ABHAY on 29/11/1942 Saka.
//  Copyright © 1942 ABHAY. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityTabView: UIView!
    @IBOutlet weak var allCityButton: UIButton!
    @IBOutlet weak var chicagoCityButton: UIButton!
    @IBOutlet weak var newYorkCItyButton: UIButton!
    @IBOutlet weak var loAnglesCityButton: UIButton!
    @IBOutlet weak var totalSelectionCountLbl: UILabel!
    
    var cityData     = [[String: Any]]()
    var cityTempData = [[String: Any]]()
    var activeCity = ""
    var totalSelection = 0
    
    let APIUrl = "https://api.npoint.io/81ada0361bbd877efb9e/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityTableView.delegate = self
        cityTableView.dataSource = self
        searchTextField.delegate = self
        cityTabView.layer.cornerRadius = 20
        
        getCityData()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        self.cityTableView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.minimumPressDuration = 1.0 // 1 second press
        longPressRecognizer.delegate = self
        
        // Do any additional setup after loading the view.
        
    }
    
    //MARK:- filter data
    func filterRecords(cityName: String, searchTerm: String) {
        if searchTerm == "" {
            if cityName == "" {
                cityData = cityTempData
            } else {
                let predicate = NSPredicate(format: "SELF contains[c] %@", cityName)
                cityData = cityTempData.filter { predicate.evaluate(with: $0["city"] as? String ?? "") }
            }
        } else {
            if cityName == "" {
                let predicate = NSPredicate(format: "SELF contains[c] %@", searchTerm)
                cityData = cityTempData.filter { predicate.evaluate(with: $0["first_name"] as? String ?? "") || predicate.evaluate(with: $0["last_name"] as? String ?? "" ) }
            } else {
                let predicate = NSPredicate(format: "SELF contains[c] %@", cityName)
                cityData = cityTempData.filter { predicate.evaluate(with: $0["city"] as? String ?? "") }
                
                let namePredicate = NSPredicate(format: "SELF contains[c] %@", searchTerm)
                cityData = cityData.filter {namePredicate.evaluate(with: $0["first_name"] as? String ?? "") || namePredicate.evaluate(with: $0["last_name"] as? String ?? "" ) }

            }
        }           
        cityTableView.reloadData()
    }
    
    //MARK:- switch city actions
    @IBAction func switchCityAction(_ sender: UIButton) {
        totalSelectionCountLbl.text = "0"
        totalSelection = 0
        switch sender.tag {
        case 0:
            allCityButton.setTitleColor(.link, for: .normal)
            chicagoCityButton.setTitleColor(.black, for: .normal)
            newYorkCItyButton.setTitleColor(.black, for: .normal)
            loAnglesCityButton.setTitleColor(.black, for: .normal)
            activeCity = ""
            filterRecords(cityName: "", searchTerm: ((searchTextField.text?.count  ?? 0) == 0 ? "" : (searchTextField.text ?? "") ))
            break
        case 1:
            allCityButton.setTitleColor(.black, for: .normal)
            chicagoCityButton.setTitleColor(.link, for: .normal)
            newYorkCItyButton.setTitleColor(.black, for: .normal)
            loAnglesCityButton.setTitleColor(.black, for: .normal)
            activeCity = "Chicago"
            filterRecords(cityName: "Chicago", searchTerm: ((searchTextField.text?.count  ?? 0) == 0 ? "" : (searchTextField.text ?? "") ))
            break
       case 2:
            allCityButton.setTitleColor(.black, for: .normal)
            chicagoCityButton.setTitleColor(.black, for: .normal)
            newYorkCItyButton.setTitleColor(.link, for: .normal)
            loAnglesCityButton.setTitleColor(.black, for: .normal)
            activeCity = "NewYork"
            filterRecords(cityName: "NewYork", searchTerm: ((searchTextField.text?.count  ?? 0) == 0 ? "" : (searchTextField.text ?? "") ))
            break
       case 3:
            allCityButton.setTitleColor(.black, for: .normal)
            chicagoCityButton.setTitleColor(.black, for: .normal)
            newYorkCItyButton.setTitleColor(.black, for: .normal)
            loAnglesCityButton.setTitleColor(.link, for: .normal)
            activeCity = "Los Angeles"
            filterRecords(cityName: "Los Angeles", searchTerm: ((searchTextField.text?.count  ?? 0) == 0 ? "" : (searchTextField.text ?? "") ))
            break
        default:
            break
        }

    }
    //MARK:- get data from API
    func getCityData() {
        let header:HTTPHeaders = [.contentType("application/json")]
        AF.request(APIUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).response { response in
            switch response.result {
                case .success(let data):
                    do {
                        guard let safeData = data else { return }
                        let data = try JSONSerialization.jsonObject(with: safeData, options: .mutableContainers)
                        let responseData  = data as? [[String:Any]] ?? [[:]]
                        for item in responseData {
                            var dictionary = item
                            dictionary["status"] = false
                            self.cityData.append(dictionary)
                        }
                        self.cityData     = responseData
                        self.cityTempData = responseData
                        self.cityTableView.reloadData()
                    } catch {
                        debugPrint(error)
                    }
                break
                case .failure(let error):
                    debugPrint(error)
            }
        }
    }
    
    //MARK:- show toast message
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

//MARK:- Extension for tableview
extension ViewController:UITableViewDelegate, UITableViewDataSource {
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cityData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cityTableView.dequeueReusableCell(withIdentifier: "EmpCell") as! CityTableViewCell
        cell.selectionStyle = .none
        let dictionary = cityData[indexPath.row]
        cell.empName.text = (dictionary["first_name"] as? String ?? "") + " " + (dictionary["last_name"] as? String ?? "")
        if (dictionary["status"] as? Bool ?? false) == false {
            cell.cellView.backgroundColor = .white
        } else {
            cell.cellView.backgroundColor = .gray
        }
        return cell
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: self.cityTableView)
            if let indexPath = cityTableView.indexPathForRow(at: touchPoint) {
                var dictionary = cityData[indexPath.row]
                dictionary.updateValue(true, forKey: "status")
                cityData[indexPath.row] = dictionary
                cityTableView.reloadData()
                let fullName = (dictionary["first_name"] as? String ?? "") + " " + (dictionary["last_name"] as? String ?? "")
                showToast(message: fullName)
                totalSelection = 0
                for item in cityData {
                    if (item["status"] as? Bool ?? false) {
                        totalSelection += 1
                    }
                }
                totalSelectionCountLbl.text = String(totalSelection)
            }
        }
    }
    
}

//MARK:- extension for search textfield
extension ViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            filterRecords(cityName: activeCity, searchTerm: txtAfterUpdate)
        }
    
        return true
    }
}


