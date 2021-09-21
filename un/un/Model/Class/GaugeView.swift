//
//  GaugeView.swift
//  un
//
//  Created by Andres Liu on 1/21/21.
//

import UIKit

class GaugeView: UIView {
    var outerBezelColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
    var outerBezelWidth: CGFloat = 10

    var innerBezelColor = UIColor.white
    var innerBezelWidth: CGFloat = 5

    var insideColor = UIColor.white
    
    var segmentWidth: CGFloat = 20
    var segmentColors = [UIColor(rgb: 0xF7F7F7), UIColor(rgb: 0xB1B1B1), UIColor(rgb: 0x7E7E7E), UIColor(rgb: 0x515151) ,UIColor.black]
    
    var totalAngle: CGFloat = 180
    var rotation: CGFloat = -90
    
    var majorTickColor = UIColor.black
    var majorTickWidth: CGFloat = 2
    var majorTickLength: CGFloat = 25

    var minorTickColor = UIColor.black.withAlphaComponent(0.5)
    var minorTickWidth: CGFloat = 1
    var minorTickLength: CGFloat = 20
    var minorTickCount = 3
    
    var outerCenterDiscColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var outerCenterDiscWidth: CGFloat = 20
    var innerCenterDiscColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var innerCenterDiscWidth: CGFloat = 5
    
    var needleColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var needleWidth: CGFloat = 2
    let needle = UIView()
    
    let valueLabel = UILabel()
    var valueFont = UIFont.systemFont(ofSize: 56)
    var valueColor = UIColor.black
    
    var valueArea = 0
    var value: Int = 0 {
        didSet {
            // update the value label to show the exact number
            valueLabel.text = String(value)

            // figure out where the needle is, between 0 and 1
            let needlePosition = CGFloat(value) / 100
            
            // create a lerp from the start angle (rotation) through to the end angle (rotation + totalAngle)
            let lerpFrom = rotation
            let lerpTo = rotation + totalAngle
            
            // lerp from the start to the end position, based on the needle's position
            let needleRotation = lerpFrom + (lerpTo - lerpFrom) * needlePosition
            needle.transform = CGAffineTransform(rotationAngle: deg2rad(needleRotation))
        }
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        //drawBackground(in: rect, context: ctx)
        drawSegments(in: rect, context: ctx)
        //drawTicks(in: rect, context: ctx)
        drawCenterDisc(in: rect, context: ctx)
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
    
    func drawSegments(in rect: CGRect, context ctx: CGContext) {
        // 1: Save the current drawing configuration
        ctx.saveGState()

        // 2: Move to the center of our drawing rectangle and rotate so that we're pointing at the start of the first segment
        ctx.translateBy(x: rect.midX, y: rect.maxY)
        ctx.rotate(by: deg2rad(rotation) - (.pi / 2))

        // 3: Set up the user's line width
        ctx.setLineWidth(segmentWidth)

        // 4: Calculate the size of each segment in the total gauge
        //let segmentAngle = deg2rad(totalAngle / CGFloat(segmentColors.count))
        let segmentAngle = deg2rad(totalAngle / 100)

        // 5: Calculate how wide the segment arcs should be
        let segmentRadius = (((rect.width - segmentWidth) / 2) - outerBezelWidth) - innerBezelWidth
        
        // 6: Draw each segment
//        for (index, segment) in segmentColors.enumerated() {
        //for (index, segment) in segmentColors.enumerated() {
        for index in 0..<100 {
            // figure out where the segment starts in our arc
            let start = CGFloat(index) * segmentAngle

            // activate its color
            if index < valueArea {
                #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).set()
            } else {
                #colorLiteral(red: 0.6117647059, green: 0.01568627451, blue: 0.04705882353, alpha: 1).set()
            }
            
            //segment.set()
            
            // add a path for the segment
            ctx.addArc(center: .zero, radius: segmentRadius, startAngle: start, endAngle: start + segmentAngle, clockwise: false)
            
            // and stroke it using the activated color
            ctx.drawPath(using: .stroke)
        }

        // 7: Reset the graphics state
        ctx.restoreGState()
    }

    func drawCenterDisc(in rect: CGRect, context ctx: CGContext) {
        ctx.saveGState()
        ctx.translateBy(x: rect.midX, y: rect.maxY)

        let outerCenterRect = CGRect(x: -outerCenterDiscWidth / 2, y: -outerCenterDiscWidth / 2, width: outerCenterDiscWidth, height: outerCenterDiscWidth)
        outerCenterDiscColor.set()
        ctx.fillEllipse(in: outerCenterRect)

        let innerCenterRect = CGRect(x: -innerCenterDiscWidth / 2, y: -innerCenterDiscWidth / 2, width: innerCenterDiscWidth, height: innerCenterDiscWidth)
        innerCenterDiscColor.set()
        ctx.fillEllipse(in: innerCenterRect)
        ctx.restoreGState()
    }
    
    func setUp() {
        needle.backgroundColor = needleColor
        needle.translatesAutoresizingMaskIntoConstraints = false

        // make the needle a third of our height
        needle.bounds = CGRect(x: 0, y: 0, width: needleWidth, height: bounds.width / 2.5)

        // align it so that it is positioned and rotated from the bottom center
        needle.layer.anchorPoint = CGPoint(x: 0.5, y: 1)

        // now center the needle over our center point
        needle.center = CGPoint(x: bounds.midX, y: bounds.maxY - 1)
        addSubview(needle)

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
}

