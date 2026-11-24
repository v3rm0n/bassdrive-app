// Renders the Bassdrive app icon at any size with Core Graphics.
//
//   swift tool/app_icon/render_icon.swift <variant> <size> <out.png>
//
// Variants:
//   macos       Big Sur grid: 824px squircle on a 1024 canvas, drop shadow.
//   rounded     The squircle filling the whole canvas (Windows).
//   square      Full-bleed square (iOS, Android legacy, web). The OS masks it.
//   maskable    Full-bleed square, speaker inside the 66% safe zone.
//   foreground  Transparent, speaker inside the 66% safe zone (Android adaptive).
//
// The drawing mirrors lib/ui/player/speaker_cone.dart so the icon and the
// player show the same speaker.

import AppKit
import CoreGraphics
import Foundation

func rgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
  CGColor(
    srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
    green: CGFloat((hex >> 8) & 0xFF) / 255,
    blue: CGFloat(hex & 0xFF) / 255,
    alpha: alpha)
}

// Palette from lib/ui/theme/app_theme_tokens.dart.
let signal = rgb(0xFFD447)
let signalLight = rgb(0xFFE89A)
let signalDeep = rgb(0xE6A817)
let background = rgb(0x15111F)
let surface = rgb(0x1D1829)
let surfaceRaised = rgb(0x261F35)
let surfaceOverlay = rgb(0x302841)
let outline = rgb(0x332B45)
let outlineStrong = rgb(0x4A3F62)

let args = CommandLine.arguments
guard args.count == 4, let size = Int(args[2]) else {
  FileHandle.standardError.write("usage: render_icon.swift <variant> <size> <out.png>\n".data(using: .utf8)!)
  exit(64)
}
let variant = args[1]
let outPath = args[3]

let space = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(
  data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
  space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.setShouldAntialias(true)
ctx.interpolationQuality = .high

// Work in a 1024 unit canvas with y pointing down.
let unit = CGFloat(size) / 1024
ctx.translateBy(x: 0, y: CGFloat(size))
ctx.scaleBy(x: unit, y: -unit)

/// Apple-style continuous corner: a superellipse fills the rect.
func squircle(_ rect: CGRect, exponent n: CGFloat = 5) -> CGPath {
  let path = CGMutablePath()
  let cx = rect.midX, cy = rect.midY, a = rect.width / 2, b = rect.height / 2
  let steps = 720
  for i in 0...steps {
    let t = CGFloat(i) / CGFloat(steps) * 2 * .pi
    let c = cos(t), s = sin(t)
    let x = cx + a * copysign(pow(abs(c), 2 / n), c)
    let y = cy + b * copysign(pow(abs(s), 2 / n), s)
    if i == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
  }
  path.closeSubpath()
  return path
}

func fillCircle(_ c: CGPoint, _ r: CGFloat, _ color: CGColor) {
  ctx.setFillColor(color)
  ctx.fillEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
}

func strokeCircle(_ c: CGPoint, _ r: CGFloat, _ width: CGFloat, _ color: CGColor) {
  ctx.setStrokeColor(color)
  ctx.setLineWidth(width)
  ctx.strokeEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
}

func radial(_ c: CGPoint, _ r: CGFloat, _ colors: [CGColor], _ stops: [CGFloat], focus: CGPoint? = nil) {
  let g = CGGradient(colorsSpace: space, colors: colors as CFArray, locations: stops)!
  ctx.saveGState()
  ctx.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
  ctx.clip()
  ctx.drawRadialGradient(
    g, startCenter: focus ?? c, startRadius: 0, endCenter: c, endRadius: r,
    options: [.drawsAfterEndLocation])
  ctx.restoreGState()
}

/// The body: a dark booth panel, lit from above.
func drawBody(_ shape: CGPath, _ rect: CGRect) {
  ctx.saveGState()
  ctx.addPath(shape)
  ctx.clip()
  let g = CGGradient(
    colorsSpace: space, colors: [surfaceRaised, background] as CFArray, locations: [0, 0.75])!
  ctx.drawLinearGradient(
    g, start: CGPoint(x: rect.midX, y: rect.minY), end: CGPoint(x: rect.midX, y: rect.maxY),
    options: [])
  ctx.restoreGState()
}

/// A speaker seen head-on, centred on `c` with outer radius `r`.
func drawSpeaker(_ c: CGPoint, _ r: CGFloat) {
  // Frame shadow, so the speaker sits in the panel rather than on it.
  ctx.saveGState()
  ctx.setShadow(offset: CGSize(width: 0, height: r * 0.03), blur: r * 0.08, color: rgb(0x000000, 0.55))
  fillCircle(c, r, surface)
  ctx.restoreGState()

  // Frame: a lighter rim at the top where the light catches it.
  ctx.saveGState()
  ctx.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
  ctx.clip()
  let rim = CGGradient(
    colorsSpace: space, colors: [surfaceOverlay, surface] as CFArray, locations: [0, 1])!
  ctx.drawLinearGradient(
    rim, start: CGPoint(x: c.x, y: c.y - r), end: CGPoint(x: c.x, y: c.y + r), options: [])
  ctx.restoreGState()
  strokeCircle(c, r - r * 0.018, r * 0.036, rgb(0x5B4F78))

  // Bolts.
  for i in 0..<8 {
    let a = CGFloat(i) * .pi / 4 + .pi / 8
    let p = CGPoint(x: c.x + cos(a) * r * 0.9, y: c.y + sin(a) * r * 0.9)
    fillCircle(p, r * 0.035, outlineStrong)
    fillCircle(CGPoint(x: p.x - r * 0.008, y: p.y - r * 0.01), r * 0.016, rgb(0x6A5E86))
  }

  // Surround: the rubber roll between frame and cone.
  let surroundR = r * 0.8
  radial(
    c, surroundR + r * 0.035, [surfaceOverlay, surfaceRaised, background], [0.88, 0.95, 1])
  strokeCircle(c, surroundR, r * 0.07, surfaceOverlay)

  // Cone: deepest at the centre.
  let coneR = r * 0.76
  radial(c, coneR, [background, surface, surfaceRaised], [0.25, 0.7, 1])
  for f: CGFloat in [0.44, 0.58, 0.7] {
    strokeCircle(c, r * f, max(1 / unit, r * 0.01), outline)
  }

  // Dust cap: the one bright thing.
  let capR = r * 0.3
  radial(c, capR * 1.9, [rgb(0xFFD447, 0.35), rgb(0xFFD447, 0)], [0.45, 1])
  ctx.saveGState()
  ctx.setShadow(offset: CGSize(width: 0, height: r * 0.02), blur: r * 0.04, color: rgb(0x000000, 0.5))
  fillCircle(c, capR, signal)
  ctx.restoreGState()
  radial(
    c, capR, [signalLight, signal, signalDeep], [0, 0.55, 1],
    focus: CGPoint(x: c.x - capR * 0.35, y: c.y - capR * 0.4))
}

let center = CGPoint(x: 512, y: 512)

switch variant {
case "macos":
  // Big Sur grid: 824pt body, 100pt margin, body sits 10pt above centre of shadow.
  let body = CGRect(x: 100, y: 100, width: 824, height: 824)
  let shape = squircle(body)
  ctx.saveGState()
  ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 20, color: rgb(0x000000, 0.35))
  ctx.addPath(shape)
  ctx.setFillColor(background)
  ctx.fillPath()
  ctx.restoreGState()
  drawBody(shape, body)
  drawSpeaker(center, 824 * 0.4)
  // Hairline edge so the icon holds its shape on a dark Dock.
  ctx.addPath(squircle(body.insetBy(dx: 1.5, dy: 1.5)))
  ctx.setStrokeColor(rgb(0xFFFFFF, 0.08))
  ctx.setLineWidth(3)
  ctx.strokePath()
case "rounded":
  let body = CGRect(x: 0, y: 0, width: 1024, height: 1024)
  drawBody(squircle(body), body)
  drawSpeaker(center, 1024 * 0.4)
case "square":
  let body = CGRect(x: 0, y: 0, width: 1024, height: 1024)
  drawBody(CGPath(rect: body, transform: nil), body)
  drawSpeaker(center, 1024 * 0.4)
case "maskable":
  let body = CGRect(x: 0, y: 0, width: 1024, height: 1024)
  drawBody(CGPath(rect: body, transform: nil), body)
  drawSpeaker(center, 1024 * 0.3)
case "foreground":
  drawSpeaker(center, 1024 * 0.3)
default:
  FileHandle.standardError.write("unknown variant \(variant)\n".data(using: .utf8)!)
  exit(64)
}

let image = ctx.makeImage()!
let rep = NSBitmapImageRep(cgImage: image)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: outPath))
