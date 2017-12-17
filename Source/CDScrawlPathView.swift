//
//  CDScrawlPathView.swift
//  Scrawl
//
//  Created by Calios on 12/5/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

public class CDScrawlPathView: UIView {
	public var pathImageView: UIImageView?
	public var backingImage: UIImage?
	public var brushColor: UIColor = .black {
		didSet {
			bezierPathLayer.strokeColor = model.brushColor.cgColor
			bezierPathLayer.fillColor = model.brushColor.cgColor
			
			if brushColor != model.brushColor {
				temporaryPath = nil
				model.asyncEndCurrentLine(model.brushColor)
				model.brushColor = brushColor
			}
		}
	}
	
	var isPathEmpty = false {
		didSet {
			if let emptyHandler = emptyHandler {
				emptyHandler(isPathEmpty)
			}
		}
	}
	
	public var emptyHandler: ((Bool) -> Void)?
	private var model: CDBrushPathDrawingAsynModel!
	private var bezierPathLayer = CAShapeLayer()
	private var temporaryPath: UIBezierPath?
	private var currentTouch: UITouch?
	private var shouldCancelTouch: Bool = false
	
	init(frame: CGRect, presetImage: UIImage? = nil) {
		super.init(frame: frame)
		backingImage = presetImage
		
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setup()
	}
	
	private func setup() {
		model = CDBrushPathDrawingAsynModel(imageSize: frame.size)
		
		pathImageView = UIImageView()
		addSubview(pathImageView!)
		
		bezierPathLayer.strokeColor = brushColor.cgColor
		bezierPathLayer.fillColor = brushColor.cgColor
		layer.addSublayer(bezierPathLayer)
	}
	
	override public func layoutSubviews() {
		print(#function, backingImage ?? "empty backing image", frame)
		pathImageView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
		model.drawingSize = bounds.size

		updateViewFromModel()
	}
	
	// MARK: - public
	public func resetAllPaths() {
		model.resetAllPaths()
		updateViewFromModel()
	}

	public func scrawlImage() -> UIImage? {
		return model.finalizedPathImage()
	}
	
	public func combinedImage() -> UIImage? {
		if let backingImage = backingImage {
			let width = bounds.width
			let height = bounds.height
			UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
			let imageFrame = CGRect(x: 0, y: 0, width: width, height: height)
			backingImage.draw(in: imageFrame)

			if let pathImage = model.finalizedPathImage() {
				pathImage.draw(in: imageFrame)
			}
			if let lastPath = temporaryPath {
				brushColor.setStroke()
				brushColor.setFill()
				
				lastPath.stroke()
				lastPath.fill()
			}
			let resultImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return resultImage
		} else {
			return model.finalizedPathImage()
		}
	}
	
	// MARK: - touch
	override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function, touches.count, touches.first!.location(in: self))
		
		super.touchesBegan(touches, with: event)
		shouldCancelTouch = shouldCancel(touches)
		
		currentTouch = touches.first!

//		print("▶️", shouldCancelTouch)
		if !shouldCancelTouch {
			updateModel(touches, endPreviousLine: true)
		}
	}
	
	override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function, touches.first!.location(in: self))
		super.touchesMoved(touches, with: event)

		if !shouldCancelTouch {
			updateModel(touches, endPreviousLine: false)
		}
	}

	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function)
		super.touchesEnded(touches, with: event)
		
		if !shouldCancelTouch {
			shouldCancelTouch = true
			
			model.asyncEndCurrentLine(model.brushColor)
			updateViewFromModel()
		}
	}
	
	public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function, "⚡️ should cancel", temporaryPath as Any)
		super.touchesCancelled(touches, with: event)
		
		shouldCancelTouch = true
		
		if let temporaryPath = temporaryPath {
			bezierPathLayer.fillColor = UIColor.orange.cgColor
			bezierPathLayer.strokeColor = UIColor.orange.cgColor
			bezierPathLayer.path = temporaryPath.cgPath
			
			model.asyncEndCurrentLine(UIColor.clear)
			updateViewFromModel()
		}
		temporaryPath = nil

		bezierPathLayer.fillColor = brushColor.cgColor
		bezierPathLayer.strokeColor = brushColor.cgColor
	}

	private func shouldCancel(_ touches: Set<UITouch>) -> Bool {
		let isMultipleTouch = touches.count > 1
		if let currentTouch = currentTouch {
			// If two touches come hand in hand, treat them as multiple touch.
//			print("🚀: \(abs(currentTouch.timestamp - touches.first!.timestamp))")
			return (currentTouch != touches.first! && abs(currentTouch.timestamp - touches.first!.timestamp) < 0.05) || isMultipleTouch
		}
		return isMultipleTouch
	}
	
	// MARK: - private
	private func updateModel(_ touches: Set<UITouch>, endPreviousLine: Bool) {
//		print(#function)
		let point = touches.first?.location(in: self)
		
		if endPreviousLine {
			model.asyncEndCurrentLine(brushColor)
		}
		
		model.asyncUpdate(with: point!)
		updateViewFromModel()
	}
	
	private func updateViewFromModel() {
//		print(#function)
		model.asyncGetOutput { [weak self](existingImage, temporaryBezierPath) in
			guard let strongSelf = self else {
				return
			}
			
			DispatchQueue.main.async {
				strongSelf.temporaryPath = nil
				
				if strongSelf.pathImageView?.image != existingImage {
					strongSelf.pathImageView?.image = existingImage
				}
				if strongSelf.bezierPathLayer.path != temporaryBezierPath?.cgPath {
					// use the same color for last path when color changed.
					strongSelf.bezierPathLayer.fillColor = strongSelf.model.brushColor.cgColor
					strongSelf.bezierPathLayer.strokeColor = strongSelf.model.brushColor.cgColor
					strongSelf.bezierPathLayer.path = temporaryBezierPath?.cgPath
					strongSelf.temporaryPath = temporaryBezierPath
				}
				strongSelf.isPathEmpty = strongSelf.model.isPathEmpty
			}
		}
	}
}
