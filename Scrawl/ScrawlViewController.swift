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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
//		let drawingView = CDScrawlView()
		scrawlView.backingImage = #imageLiteral(resourceName: "test")
		scrawlView.brushColor = .orange
//		view.addSubview(drawingView)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

