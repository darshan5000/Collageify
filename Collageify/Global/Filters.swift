//
//  Filters.swift
//  Photo Collage Maker
//
//  Created by Grapes Infosoft on 14/09/19.
//  Copyright © 2019 Grapes Infosoft. All rights reserved.
//

import UIKit
import CoreImage

var context: CIContext!
var currentFilter: CIFilter!

func simpleBlurFilterExample(myImage: UIImage, filter: String, key: String, value : Double) -> UIImage {
    let inputCIImage = CIImage(cgImage: myImage.cgImage!)
    
    currentFilter = CIFilter(name: filter)
    currentFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
    currentFilter.setValue(value, forKey: key)
    
    
    if let output = currentFilter.outputImage {
        return UIImage(ciImage: output)
    } else {
        return myImage
    }
}

func applyFilter(image: UIImage, filterName: String?) -> UIImage {
    
    let beginImage = CIImage(cgImage: image.cgImage!)
    
    let filter = CIFilter(name: filterName!)
    
    filter!.setValue(beginImage, forKey: kCIInputImageKey)
    
    filter!.setDefaults()
    
    let context = CIContext(options: nil)
    let imageRef = context.createCGImage((filter?.outputImage!)!, from: beginImage.extent)
    
    let newImage = UIImage(cgImage: imageRef!)
    return newImage
}

func getScannedImage(inputImage: UIImage) -> UIImage? {
    
    let openGLContext = EAGLContext(api: .openGLES2)
    let context = CIContext(eaglContext: openGLContext!)
    
    let filter = CIFilter(name: "CIColorControls")
    let coreImage = CIImage(image: inputImage)
    
    filter?.setValue(coreImage, forKey: kCIInputImageKey)
    filter?.setValue(5, forKey: kCIInputContrastKey)
    filter?.setValue(1, forKey: kCIInputSaturationKey)
    filter?.setValue(1.2, forKey: kCIInputBrightnessKey)
    
    if let outputImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
        let output = context.createCGImage(outputImage, from: outputImage.extent)
        return UIImage(cgImage: output!)
    }
    return nil
}
