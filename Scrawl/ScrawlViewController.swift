//
//  ViewController.swift
//  Scrawl
//
//  Created by Calios on 11/23/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

class ScrawlViewController: UIViewController {

	@IBOutlet var scrawlView: ScrawlView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	}
}

