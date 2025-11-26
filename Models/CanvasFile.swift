import Foundation
import SwiftUI

enum FileType: String, Codable {
    case pdf
    case document
    case other
}

struct PDFAnnotation: Identifiable, Codable, Equatable {
    let id: UUID
    var pageNumber: Int
    var points: [CGPoint]
    var color: String
    var strokeWidth: CGFloat

    init(
        id: UUID = UUID(),
        pageNumber: Int,
        points: [CGPoint],
        color: String = "#000000",
        strokeWidth: CGFloat = 2
    ) {
        self.id = id
        self.pageNumber = pageNumber
        self.points = points
        self.color = color
        self.strokeWidth = strokeWidth
    }
}

struct PDFData: Codable, Equatable {
    var numPages: Int
    var pageSize: CGSize
    var annotations: [PDFAnnotation]

    init(
        numPages: Int = 1,
        pageSize: CGSize = CGSize(width: 612, height: 792),
        annotations: [PDFAnnotation] = []
    ) {
        self.numPages = numPages
        self.pageSize = pageSize
        self.annotations = annotations
    }
}

struct CanvasFile: Identifiable, Codable, Equatable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var fileName: String
    var fileType: FileType
    var fileData: Data
    var thumbnailData: Data?
    var pdfData: PDFData?
    var isDrawingMode: Bool
    var zIndex: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        fileName: String,
        fileType: FileType,
        fileData: Data,
        thumbnailData: Data? = nil,
        pdfData: PDFData? = nil,
        isDrawingMode: Bool = false,
        zIndex: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.fileName = fileName
        self.fileType = fileType
        self.fileData = fileData
        self.thumbnailData = thumbnailData
        self.pdfData = pdfData
        self.isDrawingMode = isDrawingMode
        self.zIndex = zIndex
        self.createdAt = createdAt
    }

    var position: CGPoint {
        get { CGPoint(x: x, y: y) }
        set { x = newValue.x; y = newValue.y }
    }

    var size: CGSize {
        get { CGSize(width: width, height: height) }
        set { width = newValue.width; height = newValue.height }
    }
}
