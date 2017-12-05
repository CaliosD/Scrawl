//
//  CDBrushPathDrawingAsynModel.swift
//  Scrawl
//
//  Created by Calios on 12/5/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

typealias CDBrushDrawingPathOutput = (UIImage?, UIBezierPath?) -> Void

class CDBrushPathDrawingAsynModel {
	var model: CDBrushPathDrawingModel!
	let drawingQueue = DispatchQueue(label: "com.calios.scrawl.drawingQueue")
	var brushColor: UIColor = .black {
		didSet {
			model.brushColor = brushColor
		}
	}
	var drawingSize: CGSize? {
		didSet {
			if let imageSize = drawingSize {
				model.backingImageSize = imageSize
			}
		}
	}
	
	convenience init() {
		self.init(imageSize: .zero)
	}
	
	init(imageSize: CGSize) {
		model = CDBrushPathDrawingModel(drawingSize: imageSize)
	}
	
	// MARK: - async
	func asyncUpdate(with point: CGPoint) {
		drawingQueue.async {
			self.model.update(with: point)
		}
	}
	
	func asyncEndCurrentLine(_ color: UIColor) {
		drawingQueue.async {
			self.model.endCurrentLine(color)
		}
	}
	
	func asyncGetOutput(output: @escaping CDBrushDrawingPathOutput) {
		
		drawingQueue.async {
			let existingPathImage = self.model.existingPathImage
			let temporaryBrushBezierPath = self.model.temporaryBrushBezierPath
			DispatchQueue.main.async {
				output(existingPathImage, temporaryBrushBezierPath)
			}
		}
	}
	
	// MARK: - sync
	func resetAllPaths() {
		model.resetAllPaths()
	}

	func finalizedPathImage() -> UIImage? {
		return model.existingPathImage
	}
}
