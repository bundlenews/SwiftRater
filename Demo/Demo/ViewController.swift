//
//  ViewController.swift
//  Demo
//
//  Created by Fujiki Takeshi on 2017/03/28.
//  Copyright © 2017年 com.takecian. All rights reserved.
//

import UIKit
import SwiftRater

class ViewController: UIViewController {

    var count: Int = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

  @IBAction func incrementSignificantUsageCount(_ sender: UIButton) {
    SwiftRater.incrementSignificantUsageCount()
    SwiftRater.check()
  }
}
