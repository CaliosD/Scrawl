//
//  CDBrushDrawingAsynModel.swift
//  Scrawl
//
//  Created by Calios on 11/27/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

typealias CDBrushDrawingOutput = (UIImage?, UIBezierPath?) -> Void

class CDBrushDrawingAsynModel {
	var model: CDBrushDrawingModel!
	var operationQueue: OperationQueue!
	var brushColor: UIColor = .black {
		didSet {
			model.brushColor = brushColor
		}
	}
	var backingImageSize: CGSize? {
		didSet {
			if let imageSize = backingImageSize {
				model.backingImageSize = imageSize
			}
		}
	}
	
	init(imageSize: CGSize) {
		model = CDBrushDrawingModel(imageSize: imageSize)
		
		operationQueue = OperationQueue()
		operationQueue.maxConcurrentOperationCount = 1
	}
	
	// MARK: - async
	func asyncUpdate(with point: CGPoint) {
		operationQueue.addOperation {
			self.model.update(with: point)
		}
	}
	
	func asyncEndCurrentLine() {
		operationQueue.addOperation {
			self.model.endCurrentLine()
		}
	}
	
	func asyncGetOutput(output: @escaping CDBrushDrawingOutput) {
		let currentQueue = OperationQueue()
		
		operationQueue.addOperation {
			let combinedImage = self.model.combinedImage
			let temporaryBezierPath = self.model.temporaryBrushBezierPath
			currentQueue.addOperation {
				output(combinedImage, temporaryBezierPath)
			}
		}
	}
	
	// MARK: - sync
	func reset() {
		operationQueue.cancelAllOperations()
		model.reset()
	}
	
	func addImageToCombinedImage(_ image: UIImage) {
		model.addImageToCombinedImage(image)
	}
	
	func finalizedImage() -> UIImage {
		return model.combinedImage
	}
}
