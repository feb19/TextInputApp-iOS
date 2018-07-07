//
//  ProfileViewController.swift
//  TextInputApp
//
//  Created by Nobuhiro Takahashi on 2018/07/07.
//  Copyright © 2018年 Nobuhiro Takahashi. All rights reserved.
//

import Foundation
import CoreMotion
import HealthKit
import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var stepLabel: UILabel!
    var pedometer: CMPedometer!
    var steps: Int = 0
    var storage = HKHealthStore()
    var isEnabled = false
    
    override func viewDidLoad() {
        pedometer = CMPedometer()
        pedometer.startUpdates(from: NSDate() as Date, withHandler: { (data, error) -> Void in
            if error==nil {
                let steps = data?.numberOfSteps
                DispatchQueue.main.async(execute: { () -> Void in
                    self.update(steps: steps as! Int)
                })
            }
            
        })
        update(steps: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if checkAuthorize() {
            print("OK")
        } else {
            print("NG")
        }
    }
    
    func checkAuthorize() -> Bool {
        if HKHealthStore.isHealthDataAvailable() {
            let quantities = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)]
            let steps = NSSet(array: quantities)
            storage.requestAuthorization(toShare: nil, read: steps as? Set<HKObjectType>) { (success, error) in
                self.isEnabled = success
                if self.isEnabled {
                    DispatchQueue.main.async {
                        
                    }
                }
            }
        } else {
            isEnabled = false
        }
        return isEnabled
    }
    
    func update(steps: Int) {
        self.stepLabel.text = "\(steps) 歩"
        self.steps = steps
    }
}
