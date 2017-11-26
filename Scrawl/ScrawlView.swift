//
//  ScrawlView.swift
//  Scrawl
//
//  Created by Calios on 11/23/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

let bush_size = 32

final class ScrawlView: UIView {
	
	var path: UIBezierPath!
	var strokes: [NSValue] = []
	
	// 2.
	override class var layerClass: AnyClass {
		get {
			return CAShapeLayer.self
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		backgroundColor = UIColor.orange
		
		// 1.2.
		path = UIBezierPath()
		
		// 1.use UIBezierPath simply
//		path.lineJoinStyle = .round
//		path.lineCapStyle = .round
//		path.lineWidth = 5
		
		// 2.use CAShapeLayer
		let shapeLayer = layer as! CAShapeLayer
		shapeLayer.strokeColor = UIColor.white.cgColor
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.lineJoin = kCALineJoinRound
		shapeLayer.lineCap = kCALineCapRound
		shapeLayer.lineWidth = 5
		
		// 3.add chalk

	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let point = touches.first?.location(in: self)
		
		// 1.2.
		path.move(to: point!)
		
		// 3.
//		addBrushStroke(at: point!)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		let point = touches.first?.location(in: self)
		path.addLine(to: point!)
		
		// 1.
//		setNeedsDisplay()
		
		// 2.
		(layer as! CAShapeLayer).path = path.cgPath
		
		// 3.
//		addBrushStroke(at: point!)
	}

	// 1.
//	override func draw(_ rect: CGRect) {
//		UIColor.clear.setFill()
//		UIColor.red.setStroke()
//		path.stroke()
//	}
	
	// 3.
	func addBrushStroke(at point: CGPoint) {
		strokes.append(NSValue(cgPoint: point))
		
		setNeedsDisplay(brushRectForPoint(point))
	}
	
	func brushRectForPoint(_ point: CGPoint) -> CGRect {
		return CGRect(x: point.x - CGFloat(bush_size/2), y: point.y - CGFloat(bush_size/2), width: CGFloat(bush_size), height: CGFloat(bush_size))
	}
	
//	override func draw(_ rect: CGRect) {
//		for value in strokes {
//			let point = value.cgPointValue
//
//			// get brush rect
//			let brushRect = brushRectForPoint(point)
//
//			// only draw brush stroke if it intersects dirty rect
//			if rect.intersects(brushRect) {
//				// draw brush stroke
//				#imageLiteral(resourceName: "shape").draw(in: brushRect)
//			}
//		}
//	}
}
