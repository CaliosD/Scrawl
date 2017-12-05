//
//  CDBrushPathDrawingModel.swift
//  Scrawl
//
//  Created by Calios on 12/5/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import Foundation

class CDBrushPathDrawingModel {
	var brushColor: UIColor = .black
	var temporaryBrushBezierPath: UIBezierPath?
	var existingPathImage: UIImage?
	var historyPaths: [UIBezierPath] = []
	var backingImageSize: CGSize = .zero
	
	private var bezierProvider: CDBrushBezierProvider!
	
	convenience init() {
		self.init(drawingSize: .zero)
	}
	
	init(drawingSize: CGSize) {
		backingImageSize = drawingSize
		bezierProvider = CDBrushBezierProvider()
		bezierProvider.delegate = self
	}
	
	func update(with point: CGPoint) {
		bezierProvider.addPointToBrushBezier(point)
	}
	
	func endCurrentLine(_ color: UIColor) {
		if let temporaryBrushBezierPath = temporaryBrushBezierPath {
			historyPaths.append(temporaryBrushBezierPath)
		}
		existingPathImage = combinePathImageAdding(bezierPath: temporaryBrushBezierPath, color)
		temporaryBrushBezierPath = nil
		bezierProvider.reset()
	}
	
	func undo() {
		
	}
	
	func redo() {
		
	}
	
	func resetAllPaths() {
		existingPathImage = nil
		temporaryBrushBezierPath = nil
		bezierProvider.reset()
	}
	
	// MARK: - private
	private func combinePathImageAdding(bezierPath: UIBezierPath?, _ color: UIColor? = nil) -> UIImage? {
		let pColor = color ?? brushColor
		return combinePathImage(with: existingPathImage, bezierPath: bezierPath, color: pColor, size: backingImageSize)
	}
	
	private func combinePathImage(with existingPathImage: UIImage? = nil, bezierPath: UIBezierPath? = nil, color: UIColor? = nil, size: CGSize) -> UIImage? {
		guard size.isAvailable() else {
			return nil
		}

		if existingPathImage == nil && bezierPath == nil {
			return nil
		}
		
		let imageFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		
		if let existingPathImage = existingPathImage {
			existingPathImage.draw(in: imageFrame)
		}
		
		if let bezierPath = bezierPath {
			if let color = color {
				color.set()
				color.setFill()
			}
			bezierPath.stroke()
			bezierPath.fill()
		}
		
		let resultImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return resultImage
	}
}

extension CDBrushPathDrawingModel: CDBrushBezierProviderDelegate {
	func updatedTemporaryBrushBezier(with provider: CDBrushBezierProvider, temporaryBezier: UIBezierPath?) {
		temporaryBrushBezierPath = temporaryBezier
	}
	
	func generatedFinalizedBrushBezier(with provider: CDBrushBezierProvider, finalizedBezier: UIBezierPath?) {
		existingPathImage = combinePathImageAdding(bezierPath: finalizedBezier)
	}
}

extension CGSize {
	func isAvailable() -> Bool {
		return width > 0 && height > 0
	}
}
