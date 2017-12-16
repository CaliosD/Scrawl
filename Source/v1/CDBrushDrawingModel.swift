//
//  CDBrushDrawingModel.swift
//  Scrawl
//
//  Created by Calios on 11/27/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

class CDBrushDrawingModel {
	var brushColor: UIColor = .black
	var backingImage: UIImage?
	var combinedImage: UIImage!		// TODO: double check
	var temporaryBrushBezierPath: UIBezierPath?		// TODO: double check
	var backingImageSize: CGSize = .zero {
		didSet {
			if __CGSizeEqualToSize(oldValue, backingImageSize) {
				return
			}
			// Add the temporary bezier into the current signature image, so the image can be resized
			endCurrentLine()
			
			// Resize signature image
			combinedImage = combinedImage(with: combinedImage, size: backingImageSize)
		}
	}
	
	private var bezierProvider: CDBrushBezierProvider!
	private var backupImage: UIImage?
		
	convenience init() {
		self.init(imageSize: .zero)
	}
	
	init(imageSize: CGSize) {
		backingImageSize = imageSize
		bezierProvider = CDBrushBezierProvider()
		bezierProvider.delegate = self
	}

	func update(with point: CGPoint) {
		bezierProvider.addPointToBrushBezier(point)
	}
	
	func endCurrentLine() {
		combinedImage = combinedImageAdding(bezierPath: temporaryBrushBezierPath)
		temporaryBrushBezierPath = nil
		bezierProvider.reset()
	}
	
	func resetAll() {
		combinedImage = nil
		temporaryBrushBezierPath = nil
		bezierProvider.reset()
	}

	func resetBrushes() {
		combinedImage = backupImage
		temporaryBrushBezierPath = nil
		bezierProvider.reset()
	}
	
	func addImageToCombinedImage(_ image: UIImage) {
		if backupImage == nil {
			backupImage = image
		}
		combinedImage = combinedImage(with: combinedImage, backingImage: image, bezierPath: nil, color: nil, size: backingImageSize)
	}
	
	// MARK: - private
	private func combinedImageAdding(bezierPath: UIBezierPath?) -> UIImage?{
		return combinedImage(with: combinedImage, backingImage: backingImage, bezierPath: bezierPath, color: brushColor, size: backingImageSize)
	}
	
	private func combinedImage(with drawingImage: UIImage?, backingImage: UIImage? = nil, bezierPath: UIBezierPath? = nil, color: UIColor? = nil, size: CGSize) -> UIImage? {
		guard size.isAvailable() else {
			return nil
		}
		
		if drawingImage == nil && backingImage == nil && bezierPath == nil {
			return nil
		}

		let imageFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		UIGraphicsBeginImageContextWithOptions(imageFrame.size, true, 0)
		
		if let drawingImage = drawingImage {
			drawingImage.draw(in: imageFrame)
		}
		if let backingImage = backingImage {
			backingImage.draw(in: imageFrame)
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

extension CDBrushDrawingModel: CDBrushBezierProviderDelegate {
	func updatedTemporaryBrushBezier(with provider: CDBrushBezierProvider, temporaryBezier: UIBezierPath?) {
		temporaryBrushBezierPath = temporaryBezier
	}

	func generatedFinalizedBrushBezier(with provider: CDBrushBezierProvider, finalizedBezier: UIBezierPath?) {
		combinedImage = combinedImageAdding(bezierPath: finalizedBezier)
	}
}

