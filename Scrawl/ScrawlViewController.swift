//
//  ViewController.swift
//  Scrawl
//
//  Created by Calios on 11/23/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

class ScrawlViewController: UIViewController {

	@IBOutlet var scrawlView: CDScrawlView!
	@IBOutlet var resetButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrawlView.backingImage = #imageLiteral(resourceName: "test")
		scrawlView.brushColor = .orange
		scrawlView.emptyHandler = { isEmpty in
			self.resetButton.isEnabled = !isEmpty
		}
	}

	@IBAction func reset(_ sender: Any) {
		scrawlView.resetBrushes()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

