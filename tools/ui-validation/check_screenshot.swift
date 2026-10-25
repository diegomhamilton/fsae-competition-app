#!/usr/bin/env -S xcrun swift -module-cache-path /tmp/fsae-ui-validation-module-cache

// Boot-screen gate adapted from the workflow of ios-bass-app:
// .agents/skills/ios-feature-validation/scripts/check_screenshot.swift.
// This independently implemented sampling gate has the same exit contract:
// 0 permits visual review, 1 is invalid input, 2 rejects a likely boot screen.
// It does not establish that the requested application state is correct.

import AppKit
import Foundation

func finish(_ status: Int32, _ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(status)
}

guard CommandLine.arguments.count == 2 else {
    finish(1, "usage: check_screenshot.swift <image>")
}

let imagePath = CommandLine.arguments[1]
guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)),
      let bitmap = NSBitmapImageRep(data: imageData),
      bitmap.pixelsWide > 0, bitmap.pixelsHigh > 0 else {
    finish(1, "error: cannot decode screenshot: \(imagePath)")
}

let columns = 80
let rows = 160
var sampled = 0
var darkSamples = 0
var brightSamples = 0
var perimeterSamples = 0
var darkPerimeterSamples = 0
var centralSamples = 0
var brightCentralSamples = 0

for row in 0..<rows {
    for column in 0..<columns {
        let x = min(bitmap.pixelsWide - 1, (column * bitmap.pixelsWide + bitmap.pixelsWide / 2) / columns)
        let y = min(bitmap.pixelsHigh - 1, (row * bitmap.pixelsHigh + bitmap.pixelsHigh / 2) / rows)
        guard let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else {
            finish(1, "error: cannot sample screenshot colors: \(imagePath)")
        }

        let luminance = 0.2126 * color.redComponent
            + 0.7152 * color.greenComponent
            + 0.0722 * color.blueComponent
        let dark = luminance < 0.075
        let bright = luminance > 0.85
        sampled += 1
        if dark { darkSamples += 1 }
        if bright { brightSamples += 1 }

        let perimeter = column < 8 || column >= columns - 8
            || row < 16 || row >= rows - 16
        if perimeter {
            perimeterSamples += 1
            if dark { darkPerimeterSamples += 1 }
        }

        let central = column >= columns / 4 && column < columns * 3 / 4
            && row >= rows / 4 && row < rows * 3 / 4
        if central {
            centralSamples += 1
            if bright { brightCentralSamples += 1 }
        }
    }
}

let darkFraction = Double(darkSamples) / Double(sampled)
let brightFraction = Double(brightSamples) / Double(sampled)
let darkPerimeterFraction = Double(darkPerimeterSamples) / Double(perimeterSamples)
let brightCentralFraction = Double(brightCentralSamples) / Double(centralSamples)
let blankBlackImage = darkFraction > 0.96 && brightFraction < 0.003
let centeredBootLogo = darkFraction > 0.78
    && darkPerimeterFraction > 0.93
    && brightFraction > 0.003 && brightFraction < 0.15
    && brightCentralFraction > 0.01

let metrics = String(
    format: "dark=%.3f bright=%.3f darkPerimeter=%.3f brightCenter=%.3f",
    darkFraction, brightFraction, darkPerimeterFraction, brightCentralFraction
)

if blankBlackImage || centeredBootLogo {
    finish(2, "reject: likely boot or blank black screen (\(metrics)); recapture after boot readiness")
}

print("accept: image passes boot-screen gate (\(metrics)); visual inspection is still required")
