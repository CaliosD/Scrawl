//
//  ViewController.swift
//  Example
//
//  Created by Calios on 11/27/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit
import Scrawl

class ViewController: UIViewController {

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
}

