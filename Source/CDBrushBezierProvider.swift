//
//  CDBrushBezierProvider.swift
//  Scrawl
//
//  Created by Calios on 11/26/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

/// The weight of a signature-styled dot.
let CDDotBrushWeight: CGFloat = 3.0

/// If a new point is added without being at least this distance from the previous point, it will be ignored.
let CDTouchDistanceThreshold: CGFloat = 2.0

let CDMaxPointIndex = 3

protocol CDBrushBezierProviderDelegate {
	/**
	Provides the temporary signature bezier.
	This can be displayed to represent the most recent points of the signature,
	to give the feeling of real-time drawing but should not be permanently
	drawn, as it will change as more points are added.
	*/
	func updatedTemporaryBrushBezier(with provider: CDBrushBezierProvider, temporaryBezier: UIBezierPath?)
	
	/**
	Provides the finalized signature bezier.
	When enough points are added to form a full bezier curve, this will be
	returned as the finalized bezier and the temporary will reset.
	*/
	func generatedFinalizedBrushBezier(with provider: CDBrushBezierProvider, finalizedBezier: UIBezierPath?)
}

class CDBrushBezierProvider: NSObject {
	var point0: CDWeightedPoint = .zero
	var point1: CDWeightedPoint = .zero
	var point2: CDWeightedPoint = .zero
	var point3: CDWeightedPoint = .zero
	
	var nextPointIndex: UInt = 0
	var delegate: CDBrushBezierProviderDelegate?
	
	func addPointToBrushBezier(_ point: CGPoint) {
//		print(#function, "isFirstPoint: \(nextPointIndex == 0)")
		
		let isFirstPoint = (nextPointIndex == 0)
		if isFirstPoint {
			startNewLine(with: CDWeightedPoint(point: point, weight: CDDotBrushWeight))
		} else {
			let previousPoint: CGPoint = weightedPoint(at: nextPointIndex - 1).point
			if CGPoint.distance(point, pointB: previousPoint) < CDTouchDistanceThreshold {
				return
			}
			
			let isStartPointOfNextLine = nextPointIndex > CDMaxPointIndex
			if isStartPointOfNextLine {
				finalizeBezierPathWithNextLine(point)
				startNewLine(with: weightedPoint(at: 3))
			}
			
			let weightPoint = CDWeightedPoint(point: point, weight: brushWeightForLine(between: previousPoint, pointB: point))
			addWeightedPointToLine(weightPoint)
		}
		
		let newBezier = generateBezierPath(with: nextPointIndex - 1)
		updateTemporaryBezier(with: newBezier)
	}
	
	func reset() {
		nextPointIndex = 0
		updateTemporaryBezier(with: nil)
	}
	
	deinit {
		delegate = nil
	}

	// MARK: - private
	private func startNewLine(with point: CDWeightedPoint) {
//		print(#function)
		
		setWeightedPoint(point, index: 0)
		nextPointIndex = 1
	}
	
	private func addWeightedPointToLine(_ point: CDWeightedPoint) {
//		print(#function)
		
		setWeightedPoint(point, index: nextPointIndex)
		nextPointIndex += 1
	}
	
	private func finalizeBezierPathWithNextLine(_ nextStartPoint: CGPoint) {
//		print(#function, nextStartPoint)
		
		/*
		Smooth the join between beziers by modifying the last point of the current bezier
		to equal the average of the points either side of it.
		*/
		let touchPoint2 = weightedPoint(at: 2).point
		var newPoint3 = CDWeightedPoint(point: CGPoint.average(touchPoint2, pointB: nextStartPoint), weight: 0)
		newPoint3.weight = brushWeightForLine(between: touchPoint2, pointB: newPoint3.point)
		setWeightedPoint(newPoint3, index: 3)
		
		updateFinalizedBezier(with: generateBezierPath(with: 3))
	}
	
	private func generateBezierPath(with pointIndex: UInt) -> UIBezierPath? {
		switch pointIndex {
		case 0:
			return UIBezierPath.cd_dot(with: weightedPoint(at: 0))
		case 1:
			return UIBezierPath.cd_line(with: weightedPoint(at: 0), pointB: weightedPoint(at: 1))
		case 2:
			return UIBezierPath.cd_quadCurve(with: weightedPoint(at: 0), pointB: weightedPoint(at: 1), pointC: weightedPoint(at: 2))
		case 3:
			return UIBezierPath.cd_bezierCurve(with: weightedPoint(at: 0), pointB: weightedPoint(at: 1), pointC: weightedPoint(at: 2), pointD: weightedPoint(at: 3))
		default:
			return nil
		}
	}
	
	// MARK: - points index accessors
	private func setWeightedPoint(_ point: CDWeightedPoint, index: UInt) {
		switch index {
		case 0:
			point0 = point
		case 1:
			point1 = point
		case 2:
			point2 = point
		case 3:
			point3 = point
		default:
			break
		}
	}
	
	private func weightedPoint(at index: UInt) -> CDWeightedPoint {
		switch index {
		case 0:
			return point0
		case 1:
			return point1
		case 2:
			return point2
		case 3:
			return point3
		default:
			return .zero
		}
	}
	
	// MARK: - delegate calls
	private func updateTemporaryBezier(with bezier: UIBezierPath?) {
		if let delegate = delegate {
			delegate.updatedTemporaryBrushBezier(with: self, temporaryBezier: bezier)
		}
	}
	
	private func updateFinalizedBezier(with bezier: UIBezierPath?) {
		if let delegate = delegate {
			delegate.generatedFinalizedBrushBezier(with: self, finalizedBezier: bezier)
		}
	}
	
	// MARK: - helper
	private func brushWeightForLine(between pointA: CGPoint, pointB: CGPoint) -> CGFloat {
		let length = CGPoint.distance(pointA, pointB: pointB)
		
		// The is the maximum length that will vary weight. Anything higher will return the same weight.
		let maxLengthRange: CGFloat = 50.0
		
		/*
		These are based on having a minimum line thickness of 2.0 and maximum of 7, linearly over line lengths 0-maxLengthRange. They fit into a typical linear equation: y = mx + c
		
		Note: Only the points of the two parallel bezier curves will be at least as thick as the constant. The bezier curves themselves could still be drawn with sharp angles, meaning there is no true 'minimum thickness' of the signature.
		*/
		let gradient: CGFloat = 0.1
		let constant: CGFloat = 2.0
		
		var inversedLength = maxLengthRange - length
		inversedLength = max(0, inversedLength)
		
		return (inversedLength * gradient) + constant
	}
}
