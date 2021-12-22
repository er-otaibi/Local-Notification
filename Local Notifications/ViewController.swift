//
//  ViewController.swift
//  Local Notifications
//
//  Created by Mac on 10/05/1443 AH.
//

import UIKit

enum WorkoutState {
    case inactive
    case active
    case paused
}

class ViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource , UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var timerPicker: UIPickerView!
    @IBOutlet weak var dueToTimerLabel: UILabel!
 
    var pickerData: [String] = [String]()
    
    var timeInMilliseconds: Int?
    var secondsRemaining: Int?
    var numberInMinute :Int?
    var workoutState = WorkoutState.inactive
    
    var timer = Timer()
    var workoutInterval = 0.0
    var startDate = Date()
    
    
    var minute = 5
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        NotificationCenter.default.addObserver(self, selector: #selector(observerMethod), name: .NSExtensionHostDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(observerMethod), name: .NSExtensionHostDidBecomeActive, object: nil)
        self.timerPicker.delegate = self
        self.timerPicker.dataSource = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [[.alert, .sound, .badge]], completionHandler: { (granted, error) in
            // Handle Error
        })
        UNUserNotificationCenter.current().delegate = self
        
        pickerData = ["5", "10", "15", "20", "25", "30"]
        
        print("\(timer)")
        timer.invalidate()
   
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func updateTimerLabel() {
        
        let interval = -Int(startDate.timeIntervalSinceNow)
       // let hours = interval / 3600
        let minutes = interval / 60 % 60
        let seconds = interval % 60
        
        self.countDownLabel.text = String(format:"%02i:%02i", minutes, seconds)
        
    }
    
    func startButtonPressed() {
        
        if workoutState == .inactive {
            startDate = Date()
        } else if workoutState == .paused {
            startDate = Date().addingTimeInterval(-workoutInterval)
        }
        workoutState = .active
        
        
        
        updateTimerLabel()
        _foregroundTimer(repeated: true)
        print("Calling _foregroundTimer(_:)")
        
    }
    
    func _foregroundTimer(repeated: Bool) -> Void {
        NSLog("_foregroundTimer invoked.");
        
        //Define a Timer
    
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction(_:)), userInfo: nil, repeats: true)
        print("Starting timer")
        
    }
    
    @objc func timerAction(_ timer: Timer) {
        
        print("timerAction(_:)")
        print("\(minute * 60)")
        print(startDate.timeIntervalSinceNow)
        
        if -(startDate.timeIntervalSinceNow) >= (Double(minute) * 60.0){
            timer.invalidate()
            //clear everything this is when the timer stops
            workoutInterval = 0.0
            workoutState = .inactive
        }
        
        self.updateTimerLabel()
    }
    
    @objc func observerMethod(notification: NSNotification) {
        
        if notification.name == .NSExtensionHostDidEnterBackground {
            print("app entering background")
            
            // stop UI update
            timer.invalidate()
        } else if notification.name == .NSExtensionHostDidBecomeActive {
            print("app entering foreground")
            
            if workoutState == .active {
                updateTimerLabel()
                _foregroundTimer(repeated: true)
            }
        }
        
    }
    
    
    
    @IBAction func startTimerButton(_ sender: UIButton) {
     
        print(minute)
        workoutInterval = 0.0
        workoutState = .inactive
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests()
        changeTimer(timerInMinutes: minute)

        
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row]) Minutes"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        minute = Int(pickerData[row])!
    }
    
    func changeTimer(timerInMinutes: Int)  {
        
        addTim(minute: timerInMinutes)
        secondsRemaining = timerInMinutes * 60
        timeInMilliseconds = timerInMinutes * 60000
        
        startButtonPressed()
        
    }
    

    func addTim(minute:Int){
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        //adding 5 miniuts
        let a = Double(minute) * 60.0
        let addminutes = date.addingTimeInterval(a)
        dateFormatter.dateFormat = "H:mm:ss"
        
        let after_add_time = dateFormatter.string(from: addminutes)
        print("after add time-->",after_add_time)
        let timeArray = after_add_time.split(separator: ":")
        if let hour = Int(timeArray[0]), let minute = Int(timeArray[1]), let second = Int(timeArray[2]) {
           
            sendNotifications(hour: hour, minute: minute, second: second)
            dueToTimerLabel.text = "Work Until - \(hour):\(minute):\(second)"
        }
       
    }
    
    func sendNotifications(hour: Int, minute : Int, second : Int){
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Hurry up your timer is done.."
        content.body = "Your Task Should be Ended !"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "yourIdentifier"
        content.userInfo = ["example": "information"] // You can retrieve this when displaying notification
        
        // Setup trigger time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let uniqueID = UUID().uuidString // Keep a record of this if necessary
        let request = UNNotificationRequest(identifier: uniqueID, content: content, trigger: trigger)
        center.add(request) // Add the notification request
    }
    
    
}



