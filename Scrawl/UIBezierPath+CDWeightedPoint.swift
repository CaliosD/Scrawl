//
//  UIBezierPath+CDWeightedPoint.swift
//  Scrawl
//
//  Created by Calios on 11/26/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

struct CDWeightedPoint {
	let point: CGPoint
	var weight: CGFloat
	
	static let zero = CDWeightedPoint(point: .zero, weight: 0.0)	
}

struct CDLine {
	let startPoint: CGPoint
	let endPoint: CGPoint
	
	func length() -> CGFloat {
		return CGPoint.distance(startPoint, pointB: endPoint)
	}
}

struct CDLinePair {
	let firstLine: CDLine
	let secondLine: CDLine
}

extension UIBezierPath {
	class func cd_dot(with pointA: CDWeightedPoint) -> UIBezierPath {
		return UIBezierPath(arcCenter: pointA.point, radius: pointA.weight, startAngle: 0, endAngle: CGFloat.pi * 2.0, clockwise: true)
	}
	
	class func cd_line(with pointA: CDWeightedPoint, pointB: CDWeightedPoint) -> UIBezierPath {
		let linePair = UIBezierPath.linesPerpendicularToLine(with: pointA, pointB: pointB)
		
		let bezierPath = UIBezierPath()
		bezierPath.move(to: linePair.firstLine.startPoint)
		bezierPath.addLine(to: linePair.secondLine.startPoint)
		bezierPath.addLine(to: linePair.secondLine.endPoint)
		bezierPath.addLine(to: linePair.firstLine.endPoint)
		bezierPath.close()
		
		return bezierPath
	}
	
	class func cd_quadCurve(with pointA: CDWeightedPoint, pointB: CDWeightedPoint, pointC: CDWeightedPoint) -> UIBezierPath {
		let linePairAB = UIBezierPath.linesPerpendicularToLine(with: pointA, pointB: pointB)
		let linePairBC = UIBezierPath.linesPerpendicularToLine(with: pointB, pointB: pointC)
		
		let lineA = linePairAB.firstLine
		let lineB = CDLine.average(linePairAB.secondLine, lineB: linePairBC.firstLine)
		let lineC = linePairBC.secondLine
		
		let bezierPath = UIBezierPath()
		bezierPath.move(to: lineA.startPoint)
		bezierPath.addQuadCurve(to: lineC.startPoint, controlPoint: lineB.startPoint)
		bezierPath.addLine(to: lineC.endPoint)
		bezierPath.addQuadCurve(to: lineA.endPoint, controlPoint: lineB.endPoint)
		bezierPath.close()
		
		return bezierPath
	}
	
	class func cd_bezierCurve(with pointA: CDWeightedPoint, pointB: CDWeightedPoint, pointC: CDWeightedPoint, pointD: CDWeightedPoint) -> UIBezierPath {
		let linePairAB = UIBezierPath.linesPerpendicularToLine(with: pointA, pointB: pointB)
		let linePairBC = UIBezierPath.linesPerpendicularToLine(with: pointB, pointB: pointC)
		let linePairCD = UIBezierPath.linesPerpendicularToLine(with: pointC, pointB: pointD)
		
		let lineA = linePairAB.firstLine
		let lineB = CDLine.average(linePairAB.secondLine, lineB: linePairBC.firstLine)
		let lineC = CDLine.average(linePairBC.secondLine, lineB: linePairCD.firstLine)
		let lineD = linePairCD.secondLine
		
		let bezierPath = UIBezierPath()
		bezierPath.move(to: lineA.startPoint)
		bezierPath.addCurve(to: lineD.startPoint, controlPoint1: lineB.startPoint, controlPoint2: lineC.startPoint)
		bezierPath.addLine(to: lineD.endPoint)
		bezierPath.addCurve(to: lineA.endPoint, controlPoint1: lineC.endPoint, controlPoint2: lineB.endPoint)
		bezierPath.close()
		
		return bezierPath
	}
	
	// MARK: - private
	private class func linesPerpendicularToLine(with pointA: CDWeightedPoint, pointB: CDWeightedPoint) -> CDLinePair {
		let line = CDLine(startPoint: pointA.point, endPoint: pointB.point)
		let linePerpendicularToPointA: CDLine = linePerpendicular(to: line, middlePoint: pointA.point, newLength: pointA.weight)
		let linePerpendicularToPointB: CDLine = linePerpendicular(to: line, middlePoint: pointB.point, newLength: pointB.weight)
		return CDLinePair(firstLine: linePerpendicularToPointA, secondLine: linePerpendicularToPointB)
	}
	
	private class func linePerpendicular(to line: CDLine, middlePoint: CGPoint, newLength: CGFloat) -> CDLine {
		// Calculate end point if line started at 0,0
		var relativeEndPoint = line.startPoint - line.endPoint
		
		if newLength == 0 || __CGPointEqualToPoint(relativeEndPoint, .zero) {
			return CDLine(startPoint: middlePoint, endPoint: middlePoint)
		}
		
		// Modify line's length to be the length needed either side of the middle point
		let lengthEitherSideOfMiddlePoint = newLength / 2.0
		let originalLineLength = line.length()
		let lengthModifier = lengthEitherSideOfMiddlePoint / originalLineLength
		relativeEndPoint.x *= lengthModifier
		relativeEndPoint.y *= lengthModifier
		
		// Swap X/Y and invert one axis to get perpendicular line
		var perpendicularLineStartPoint = CGPoint(x: relativeEndPoint.y, y: -relativeEndPoint.x)
		// Make other axis negative for perpendicular line in the opposite direction
		var perpendicularLineEndPoint = CGPoint(x: -relativeEndPoint.y, y: relativeEndPoint.x)
		
		// Move perpendicular line to middle point
		perpendicularLineStartPoint.x += middlePoint.x
		perpendicularLineStartPoint.y += middlePoint.y
		
		perpendicularLineEndPoint.x += middlePoint.x
		perpendicularLineEndPoint.y += middlePoint.y
		
		return CDLine(startPoint: perpendicularLineStartPoint, endPoint: perpendicularLineEndPoint)
	}
}

// MARK: - Generic helper methods for frequently needed calculations on CGPoint.
extension CGPoint {
	static func average(_ pointA: CGPoint, pointB: CGPoint) -> CGPoint {
		return CGPoint(x: (pointA.x + pointB.x) * 0.5, y: (pointA.y + pointB.y) * 0.5)
	}
	
	static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: rhs.x - lhs.x, y: rhs.y - lhs.y)
	}
	
	static func hypotenuse(_ point: CGPoint) -> CGFloat {
		return sqrt(point.x * point.x + point.y * point.y)
	}
	
	static func distance(_ pointA: CGPoint, pointB: CGPoint) -> CGFloat {
		return hypotenuse(pointA - pointB)
	}
}

extension CDLine {
	static func average(_ lineA: CDLine, lineB: CDLine) -> CDLine {
		return CDLine(startPoint: CGPoint.average(lineA.startPoint, pointB: lineB.startPoint), endPoint: CGPoint.average(lineA.endPoint, pointB: lineB.endPoint))
	}
}
