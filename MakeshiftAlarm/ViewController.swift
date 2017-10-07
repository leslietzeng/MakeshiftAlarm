//
//  ViewController.swift
//  MakeshiftAlarm
//
//  Created by Leslie Tzeng on 10/7/17.
//  Copyright © 2017 Leslie Tzeng. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    let motionManager = CMMotionManager()
    var alarmFlag: Bool = false
    var locked: Bool = false
    var waitTime = 5
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent //or default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.animationImages = [UIImage(named: "lock-6")!, UIImage(named: "lock-5")!, UIImage(named: "lock-4")!,
                                     UIImage(named: "lock-3")!, UIImage(named: "lock-2")!, UIImage(named: "lock-1")!,
                                     UIImage(named: "lock-0")!]
        imageView.animationDuration = 0.25
        imageView.animationRepeatCount = 1
        
        motionManager.deviceMotionUpdateInterval = 1
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        if (!locked) {
            lock()
        }
    }

    @IBAction func swipeLeft(_ sender: Any) {
        if (locked) {
            unlock()
        }
    }
    
    @IBAction func tapped(_ sender: Any) {
        if (locked) {
            unlock()
        } else {
            lock()
        }
    }
    
    func lock() {
        locked = true
        print("Lock")
        lockLabel.textColor = UIColor.red
        lockLabel.text = "LOCKED"
        toggleSwitch.setOn(true, animated:true)
        imageView.image = UIImage(named:"lock-0")
        imageView.startAnimating()
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (motionData, error) in
//            print("x: \(String(describing: motionData?.userAcceleration.x))")
//            print("y: \(String(describing: motionData?.userAcceleration.y))")
//            print("z: \(String(describing: motionData?.userAcceleration.z))")
            if let data = motionData {
                let accel = (data.userAcceleration.x * data.userAcceleration.x) +
                    (data.userAcceleration.y * data.userAcceleration.y) + (data.userAcceleration.z * data.userAcceleration.z)
                let rotation = data.rotationRate
                if (self.waitTime > 0) {
                    self.waitTime = self.waitTime - 1
                    return
                }
                if (accel > 0.001 && abs(rotation.y) > 0.01) {
                    print("ALARM")
                    self.alarm()
                }
                
             }
            
            
        }
    }
    
    func unlock() {
        alarmFlag = false
        motionManager.stopDeviceMotionUpdates()
        waitTime = 5
        locked = false
        self.view.backgroundColor =  UIColor(red: 0x38 / 0xFF, green: 0x97 / 0xFF, blue: 0xF0 / 0xFF, alpha: 0xFF / 0xFF)
        print("Unlock")
        lockLabel.textColor = UIColor.green
        lockLabel.text = "UNLOCKED"
        toggleSwitch.setOn(false, animated:true)
        imageView.image = UIImage(named:"lock-6")
        
    }
    
    func alarm() {
        alarmFlag = true
        motionManager.stopDeviceMotionUpdates()
        self.view.backgroundColor = UIColor.yellow
        imageView.image = UIImage(named: "alarm")
        lockLabel.text = "ALARM ON"
        playSound(3)
        
    }
    func playSound(_ count: Int) {
        AudioServicesPlaySystemSoundWithCompletion(1005) { 
            if (count > 0 && self.alarmFlag) {
                self.playSound(count - 1)
            }
        }
    }


}

