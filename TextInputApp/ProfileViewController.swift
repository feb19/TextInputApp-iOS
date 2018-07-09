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
    @IBOutlet weak var stepHealthLabel: UILabel!
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
                HKQuantityType.quantityType(forIdentifier: .stepCount)
            ]
            let steps = NSSet(array: quantities)
            storage.requestAuthorization(toShare: nil, read: steps as? Set<HKObjectType>) { (success, error) in
                self.isEnabled = success
                if self.isEnabled {
                    DispatchQueue.main.async {
                        
                        self.updateSteps(completion: { (steps) in
                            self.stepHealthLabel.text = steps.description
                        })
                    }
                }
            }
        } else {
            isEnabled = false
        }
        return isEnabled
    }
    
    func updateSteps(completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            var resultCount = 0.0
            
            guard let result = result else {
                print("\(String(describing: error?.localizedDescription)) ")
                completion(resultCount)
                return
            }
            
            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.count())
            }
            
            DispatchQueue.main.async {
                completion(resultCount)
            }
        }
        
        storage.execute(query)

    }
    
    func update(steps: Int) {
        self.stepLabel.text = "\(steps) 歩"
        self.steps = steps
    }
}
