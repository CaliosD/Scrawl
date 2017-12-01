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

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var contentView: UIView!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var scrawlView: CDScrawlView!
	@IBOutlet var resetButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateScrollViewGesture()
		
		scrawlView.backingImage = #imageLiteral(resourceName: "test")
		scrawlView.brushColor = .cyan
		scrawlView.emptyHandler = { isEmpty in
			self.resetButton.isEnabled = !isEmpty
		}
	}

	private func updateScrollViewGesture() {
//		for gesture in scrollView.gestureRecognizers! {
//			if gesture is UIPanGestureRecognizer {
//				let pan = gesture as! UIPanGestureRecognizer
//				pan.minimumNumberOfTouches = 2
//			}
//		}
	}
	
	@IBAction func reset(_ sender: Any) {
		scrawlView.resetBrushes()
	}
	
	@IBAction func save(_ sender: Any) {
		let resultImage = scrawlView.combinedImage()
		UIImageWriteToSavedPhotosAlbum(resultImage, self, nil, nil)
	}
	
	@IBAction func rotate(_ sender: UIRotationGestureRecognizer) {
		imageView.transform = CGAffineTransform(rotationAngle: sender.rotation)
		scrawlView.transform = CGAffineTransform(rotationAngle: sender.rotation)
	}
}

extension ViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return contentView
	}
}

