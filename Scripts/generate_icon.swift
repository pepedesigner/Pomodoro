import AppKit

// Draws a simple tomato icon and writes build/AppIcon.iconset

_ = NSApplication.shared

let side: CGFloat = 1024

func tomatoImage() -> NSImage {
    let image = NSImage(size: NSSize(width: side, height: side))
    image.lockFocus()
    defer { image.unlockFocus() }

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        fatalError("Could not create graphics context")
    }

    // Body
    let bodyRect = CGRect(x: 130, y: 150, width: 764, height: 764)
    ctx.saveGState()
    ctx.addEllipse(in: bodyRect)
    ctx.clip()

    let colors = [
        NSColor(calibratedRed: 0.99, green: 0.47, blue: 0.35, alpha: 1).cgColor,
        NSColor(calibratedRed: 0.85, green: 0.16, blue: 0.10, alpha: 1).cgColor,
    ] as CFArray
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: colors,
        locations: [0.0, 1.0]
    )!
    let center = CGPoint(x: bodyRect.midX, y: bodyRect.midY)
    ctx.drawRadialGradient(
        gradient,
        startCenter: center,
        startRadius: 0,
        endCenter: center,
        endRadius: bodyRect.width / 2,
        options: []
    )
    ctx.restoreGState()

    // Gloss highlight
    ctx.saveGState()
    ctx.setFillColor(NSColor(calibratedWhite: 1, alpha: 0.28).cgColor)
    ctx.translateBy(x: 330, y: 560)
    ctx.rotate(by: -.pi / 7)
    ctx.fillEllipse(in: CGRect(x: 0, y: 0, width: 280, height: 150))
    ctx.restoreGState()

    // Leaves (star shape)
    let leaf = starPath(center: CGPoint(x: 512, y: 880), outerRadius: 140, innerRatio: 0.42)
    let leafColors = [
        NSColor(calibratedRed: 0.38, green: 0.74, blue: 0.32, alpha: 1).cgColor,
        NSColor(calibratedRed: 0.20, green: 0.55, blue: 0.20, alpha: 1).cgColor,
    ] as CFArray
    let leafGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: leafColors,
        locations: [0.0, 1.0]
    )!
    ctx.saveGState()
    leaf.addClip()
    ctx.drawLinearGradient(
        leafGradient,
        start: CGPoint(x: 512, y: 700),
        end: CGPoint(x: 512, y: 1000),
        options: []
    )
    ctx.restoreGState()

    // Stem
    let stem = NSBezierPath(roundedRect: NSRect(x: 488, y: 830, width: 48, height: 120), xRadius: 20, yRadius: 20)
    NSColor(calibratedRed: 0.45, green: 0.33, blue: 0.20, alpha: 1).setFill()
    stem.fill()

    return image
}

func starPath(center: CGPoint, outerRadius: CGFloat, innerRatio: CGFloat, points: Int = 5) -> NSBezierPath {
    let path = NSBezierPath()
    let innerRadius = outerRadius * innerRatio
    for i in 0..<(points * 2) {
        let angle = Double(i) * .pi / Double(points) - .pi / 2
        let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
        let x = center.x + CGFloat(cos(angle)) * radius
        let y = center.y + CGFloat(sin(angle)) * radius
        if i == 0 {
            path.move(to: NSPoint(x: x, y: y))
        } else {
            path.line(to: NSPoint(x: x, y: y))
        }
    }
    path.close()
    return path
}

func savePNG(_ image: NSImage, at url: URL, pixels: Int) {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { fatalError("Could not create bitmap rep") }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: pixels, height: pixels))
    NSGraphicsContext.restoreGraphicsState()

    guard let data = rep.representation(using: .png, properties: [:]) else {
        fatalError("Could not encode PNG")
    }
    try? data.write(to: url)
}

let outputDir = URL(fileURLWithPath: "build/AppIcon.iconset")
try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

let image = tomatoImage()
let sizes: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]
for (name, px) in sizes {
    savePNG(image, at: outputDir.appendingPathComponent(name), pixels: px)
    print("Wrote \(name)")
}
print("Done")
