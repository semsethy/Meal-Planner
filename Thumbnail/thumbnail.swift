
import UIKit
import MobileCoreServices

extension UIImage {
    func resizeImageWith(maxSize: CGFloat) -> UIImage {
        var width = self.size.width
        var height = self.size.height
        let maxOrigin = max(self.size.width, self.size.height)
        if maxOrigin <= maxSize {
            return self
        }
        if width > height {
            width = maxSize
            height = (height / self.size.width) * width
        } else {
            height = maxSize
            width = (width / self.size.height)  * height
        }

        let widthRatio  = width  / self.size.width
        let heightRatio = height / self.size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        return UIGraphicsImageRenderer(size: newSize, format: imageRendererFormat).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
class ImageUtils {
    static let imageCache = NSCache<NSString, UIImage>()
    
    static func generateThumbnail(id: String, imageData: Data, size: CGSize = CGSize(width: 720, height: 720)) -> UIImage? {
        let maxDimensionInPixels = max(size.width, size.height)
        let cacheKey = id + "-\(maxDimensionInPixels)"
        let thumbnailURL = URL(fileURLWithPath: NSTemporaryDirectory() + cacheKey + ".jpeg")
        if let cachedImage = imageCache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }
        if FileManager.default.fileExists(atPath: thumbnailURL.path) {
            if let cachedImage = UIImage(contentsOfFile: thumbnailURL.path) {
                imageCache.setObject(cachedImage, forKey: cacheKey as NSString)
                return cachedImage
            }
        }
        
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return nil }
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        
        guard let destination = CGImageDestinationCreateWithURL(thumbnailURL as CFURL, kUTTypeJPEG, 1, nil) else {
            fatalError("Could not create image destination")
        }
        
        let imageProperties = [kCGImageDestinationLossyCompressionQuality: 0.7] as CFDictionary
        CGImageDestinationAddImage(destination, thumbnailImage, imageProperties)
        
        if !CGImageDestinationFinalize(destination) {
            return nil
        }
        
        let image = UIImage(cgImage: thumbnailImage)
        imageCache.setObject(image, forKey: cacheKey as NSString)
        return image
    }

}
