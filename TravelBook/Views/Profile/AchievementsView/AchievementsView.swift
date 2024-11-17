//
//  AchievementsView.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 11/17/24.
//

import SwiftUI

struct AchievementsView: View {
    private static let size: CGFloat = 100
    private static let spacingBetweenColumns: CGFloat = 16
    private static let spacingBetweenRows: CGFloat = 16
    private static let totalColumns: Int = 30

    let gridItems = Array(
        repeating: GridItem(
            .fixed(size),
            spacing: spacingBetweenColumns,
            alignment: .center
        ),
        count: totalColumns
    )

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea([.all])
//            Axes()
//                .edgesIgnoringSafeArea([.all])
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(
                    columns: gridItems,
                    alignment: .center,
                    spacing: Self.spacingBetweenRows
                ) {
                    ForEach(0..<1000) { value in
                        GeometryReader { proxy in
                            Image(appName(value))
                                .resizable()
                                .cornerRadius(Self.size/2)
                                .scaleEffect(
                                    scale(
                                        proxy: proxy,
                                        value: value
                                    )
                                )
                                .offset(
                                    x: offsetX(value),
                                    y: 0
                                )
                        }
                        // You need to add height
                        .frame(
                            height: Self.size
                        )
                    }
                }
            }
        }
    }

    func offsetX(_ value: Int) -> CGFloat {
        let rowNumber = value / gridItems.count

        if rowNumber % 2 == 0 {
            return Self.size/2 + Self.spacingBetweenColumns/2
        }

        return 0
    }

    func appName(_ value: Int) -> String {
        "JAVIER"
    }

    var center: CGPoint {
        CGPoint(
            x: UIScreen.main.bounds.size.width*0.5,
            y: UIScreen.main.bounds.size.height*0.5
        )
    }

    // This was my hardcoded approach... really bad for the future!
//    var deviceCornerAngle: CGFloat {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            return (UIDevice.current.orientation == .portrait) ? 55 : 35
//        } else {
//            return (UIDevice.current.orientation == .portrait) ? 65 : 25
//        }
//    }

    func scale(proxy: GeometryProxy, value: Int) -> CGFloat {
        let rowNumber = value / gridItems.count

        // We need to consider the offset for even rows!
        let x = (rowNumber % 2 == 0)
        ? proxy.frame(in: .global).midX + proxy.size.width/2
        : proxy.frame(in: .global).midX

        let y = proxy.frame(in: .global).midY
        let maxDistanceToCenter = getDistanceFromEdgeToCenter(x: x, y: y)

        let currentPoint = CGPoint(x: x, y: y)
        let distanceFromCurrentPointToCenter = distanceBetweenPoints(p1: center, p2: currentPoint)

        // This creates a threshold for not just the pure center could get
        // the max scaleValue.
        let distanceDelta = min(
            abs(distanceFromCurrentPointToCenter - maxDistanceToCenter),
            maxDistanceToCenter*0.3
        )

        // Helps to get closer to scale 1.0 after the threshold.
        let scalingFactor = 3.3
        let scaleValue = distanceDelta/(maxDistanceToCenter) * scalingFactor

        return scaleValue
    }

    func getDistanceFromEdgeToCenter(x: CGFloat, y: CGFloat) -> CGFloat {
        let m = slope(p1: CGPoint(x: x, y: y), p2: center)
        let currentAngle = angle(slope: m)

        let edgeSlope = slope(p1: .zero, p2: center)
        let deviceCornerAngle = angle(slope: edgeSlope)

        if currentAngle > deviceCornerAngle {
            let yEdge = (y > center.y) ? center.y*2 : 0
            let xEdge = (yEdge - y)/m + x
            let edgePoint = CGPoint(x: xEdge, y: yEdge)

            return distanceBetweenPoints(p1: center, p2: edgePoint)
        } else {
            let xEdge = (x > center.x) ? center.x*2 : 0
            let yEdge = m * (xEdge - x) + y
            let edgePoint = CGPoint(x: xEdge, y: yEdge)

            return distanceBetweenPoints(p1: center, p2: edgePoint)
        }
    }

    func distanceBetweenPoints(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let xDistance = abs(p2.x - p1.x)
        let yDistance = abs(p2.y - p1.y)

        return CGFloat(
            sqrt(
                pow(xDistance, 2) + pow(yDistance, 2)
            )
        )
    }

    func slope(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return (p2.y - p1.y)/(p2.x - p1.x)
    }

    func angle(slope: CGFloat) -> CGFloat {
        return abs(atan(slope) * 180 / .pi)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
    }
}

struct Axes: View {
    var body: some View {

        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: geometry.frame(in: .global).maxX, y: geometry.frame(in: .global).midY))
                path.addLine(to: CGPoint(x: 0, y: geometry.frame(in: .global).midY))
                path.move(to: CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).midY))
                path.addLine(to: CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).maxY))

                path.addLine(to: CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).minY - 60))
            }
            .stroke(Color.blue, lineWidth: 3)
        }
    }
}
