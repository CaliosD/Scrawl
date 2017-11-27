//
//  CDScrawlView.swift
//  Scrawl
//
//  Created by Calios on 11/27/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

class CDScrawlView: UIView {
	var imageView: UIImageView?
	var backingImage: UIImage? {
		didSet {
			if backingImage != nil {
				layoutIfNeeded()
			}
		}
	}
	
	var brushColor: UIColor = .black {
		didSet {
			model.brushColor = brushColor
			bezierPathLayer.strokeColor = brushColor.cgColor
			bezierPathLayer.fillColor = brushColor.cgColor
		}
	}
	
	var isBrushEmpty = false {
		didSet {
			if let emptyHandler = emptyHandler {
				emptyHandler(isBrushEmpty)
			}
		}
	}
	
	var emptyHandler: ((Bool) -> Void)?
	private var model: CDBrushDrawingAsynModel!
	private var bezierPathLayer = CAShapeLayer()
	
	init(frame: CGRect, presetImage: UIImage? = nil) {
		super.init(frame: frame)
		backingImage = presetImage
		
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setup()
	}
	
	private func setup() {
		isBrushEmpty = (backingImage == nil)
		model = CDBrushDrawingAsynModel(imageSize: frame.size)

		imageView = UIImageView()
		addSubview(imageView!)
		
		bezierPathLayer.strokeColor = brushColor.cgColor
		bezierPathLayer.fillColor = brushColor.cgColor
		layer.addSublayer(bezierPathLayer)
	}
	
	override func layoutSubviews() {
		print(#function, backingImage ?? "empty backing image")
		imageView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
		model.backingImageSize = bounds.size
		
		if let backingImage = backingImage {
			imageView?.contentMode = .scaleAspectFit
			imageView?.image = backingImage
			model.addImageToCombinedImage(backingImage)
		}
		updateViewFromModel()
	}
	
	// MARK: - public
	func reset() {
		model.reset()
		updateViewFromModel()
	}
	
	func combinedImage() -> UIImage {
		return model.finalizedImage()
	}
	
	// MARK: - touch
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		updateModel(touches, endPreviousLine: true)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		updateModel(touches, endPreviousLine: false)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		updateModel(touches, endPreviousLine: true)
	}
	
	// MARK: - private
	private func updateModel(_ touches: Set<UITouch>, endPreviousLine: Bool) {
		let point = touches.first?.location(in: self)
		
		if endPreviousLine {
			model.asyncEndCurrentLine()
		}
		
		model.asyncUpdate(with: point!)
		updateViewFromModel()
	}
	
	private func updateViewFromModel() {
		model.asyncGetOutput { [weak self] (combinedImage, temporaryBezierPath) in
			guard let strongSelf = self else {
				return
			}
			
			DispatchQueue.main.async {
				if strongSelf.imageView?.image != combinedImage {
					strongSelf.imageView?.image = combinedImage
				}				
			}
			
			if strongSelf.bezierPathLayer.path != temporaryBezierPath?.cgPath {
				strongSelf.bezierPathLayer.path = temporaryBezierPath?.cgPath
			}
			
			strongSelf.isBrushEmpty = strongSelf.bezierPathLayer.path == nil
		}
	}
}
