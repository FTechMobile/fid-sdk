//
//  FTSDKImageLoaderImpl.swift
//
//
//  Created by Nguyen Cuong on 31/10/2022.
//

import Foundation
import FTSDKCoreKit
import UIKit
import SDWebImage

final class FTSDKImageLoaderImpl: FTSDKImageLoaderProtocol {
    func loadImage(_ view: UIView?, url: String?, placeholder: String?) {
        if let button = view as? UIButton {
            button.sd_setImage(with: URL(string: url ?? ""),
                               for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    func loadImage(_ view: UIView?, url: String?, placeholderImage: UIImage?) {
        if let button = view as? UIButton {
            button.sd_setImage(with: URL(string: url ?? ""),
                               for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    func loadImage(_ view: UIView?, url: String?) {
        if let button = view as? UIButton {
            button.sd_setImage(with: URL(string: url ?? ""),
                               for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    func loadImageBackground(_ view: UIView?, url: String?) {
        if let button = view as? UIButton {
            button.sd_setBackgroundImage(with: URL(string: url ?? ""),
                               for: .normal)
        }
    }
    
    func loadImage(_ view: UIView?, url: String?, sizeImage: CGSize, edgeInserts: UIEdgeInsets) {
        if let button = view as? UIButton {
            button.sd_setImage(with: URL(string: url ?? ""), for: .normal) { image,error,_,_ in
                if var imageView = image {
                    if let resizedImage = imageView.resizedImage(size: sizeImage) {
                        imageView = resizedImage
                    }
                    button.setImage(imageView, for: .normal)
                }
            }
        }
    }
}

extension UIImage {
    func resizedImage(size: CGSize) -> UIImage? {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        self.draw(in: frame)
        let resizedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.withRenderingMode(.alwaysOriginal)
        return resizedImage
    }
}
