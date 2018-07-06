//
//  ViewController.swift
//  TextInputApp
//
//  Created by Nobuhiro Takahashi on 2018/07/06.
//  Copyright © 2018年 Nobuhiro Takahashi. All rights reserved.
//

import UIKit
import NgKeyboardTracker
class ViewController: UIViewController, NgKeyboardTrackerDelegate {
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var inputButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var coordinator: NgPseudoInputAccessoryViewCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.interactive
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        
        coordinator = NgKeyboardTracker.shared().createPseudoInputAccessoryViewCoordinator()
        coordinator.setPseudoInputAccessoryViewHeight(50.0)
        NgKeyboardTracker.shared().add(self as NgKeyboardTrackerDelegate)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    // MARK: NgKeyboardTrackerDelegate
    
    func keyboardTrackerDidUpdate(_ tracker: NgKeyboardTracker!) {
        updateLayout()
    }
    
    func keyboardTrackerDidChangeAppearanceState(_ tracker: NgKeyboardTracker!) {
        updateLayout()
    }

    func updateLayout() {
        let s = self.view.frame.size
        tableView.frame = self.view.bounds
        tableView.contentSize = s
        
        let kbFrame = NgKeyboardTracker.shared().keyboardCurrentFrame(for: self.view)
        
        let inputContainerHeight = coordinator.pseudoInputAccessoryViewHeight()
        var bottomPadding = -inputContainerHeight
        if !CGRect.zero.equalTo(kbFrame) {
            bottomPadding += (s.height - kbFrame.origin.y )
        }
        bottomPadding = max(bottomPadding, 0)
        
        inputContainerView.frame = CGRect(x: 0, y: s.height - inputContainerHeight - bottomPadding - 50, width: s.width, height: inputContainerHeight)
        
        coordinator.setPseudoInputAccessoryViewHeight(inputContainerHeight)
    }
    
    @IBAction func inputButtonWasTapped(_ sender: Any) {
        print("input button was tapped")
        self.inputTextView.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.inputTextView.isFirstResponder) {
            self.inputTextView.resignFirstResponder()
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
