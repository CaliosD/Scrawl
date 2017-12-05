//
//  ViewController.swift
//  Example
//
//  Created by Calios on 11/27/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit
import Scrawl

struct Pallete {
	static let black = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)	// 000000
	static let white = #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)	// EDEDED
	static let gold = #colorLiteral(red: 0.6784313725, green: 0.6, blue: 0.3607843137, alpha: 1)		// AD995C
	static let red = #colorLiteral(red: 0.8156862745, green: 0.2196078431, blue: 0.1647058824, alpha: 1)		// D0382A
	static let yellow = #colorLiteral(red: 0.9647058824, green: 0.7490196078, blue: 0.2549019608, alpha: 1)	// F6BF41
	static let blue = #colorLiteral(red: 0.2588235294, green: 0.6039215686, blue: 0.8509803922, alpha: 1)		// 429AD9
	static let green = #colorLiteral(red: 0.2941176471, green: 0.6509803922, blue: 0.3490196078, alpha: 1)	// 4BA659
	
	static func all() -> [UIColor] {
		return [Pallete.black, Pallete.white, Pallete.gold, Pallete.red, Pallete.yellow, Pallete.blue, Pallete.green]
	}
}

class ViewController: UIViewController {

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var contentView: UIView!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var scrawlView: CDScrawlPathView!
	@IBOutlet var resetButton: UIButton!

	private let colors = Pallete.all()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateScrollViewGesture()
		
		scrawlView.backingImage = #imageLiteral(resourceName: "soul")
		scrawlView.brushColor = .black
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
		scrawlView.resetAllPaths()
	}
	
	@IBAction func changeColor(_ sender: UIButton) {
		let index = Int(arc4random_uniform(UInt32(colors.count - 1)))
		scrawlView.brushColor = colors[index]
	}
	
	@IBAction func save(_ sender: Any) {
		if let resultImage = scrawlView.combinedImage() {
			UIImageWriteToSavedPhotosAlbum(resultImage, self, nil, nil)
		}
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

