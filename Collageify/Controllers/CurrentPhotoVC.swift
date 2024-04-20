import UIKit
import Photos
import Firebase

class CurrentPhotoVC: UIViewController,OpalImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {

    var selectedDict = [String : Int]()
    var objTotalImgSelection = 0
    var picker = OpalImagePickerController()
    var objSelectiontype = 0
    var imagePicker = UIImagePickerController()

    //MARK:- Outlets
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

//        picker.imagePickerDelegate = self
//        picker.delegate = self
        btnDismiss.backgroundColor = UIColor.clear
        btnDismiss.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("CurrentPhotoVC_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
    }
    
    //MARK:- Button Action Zone
    @IBAction func btnDismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCameraAction(_ sender: UIButton) {
        openCamera()
    }
    
    @IBAction func btnGalleryAction(_ sender: UIButton) {
        openGallery()
    }
    
    //MARK:- UIImagePicker Delegate Methods
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if objSelectiontype == 1 {
            picker = OpalImagePickerController()
            picker.delegate = self
            picker.imagePickerDelegate = self
            picker.selectedDict = selectedDict
            picker.allowedMediaTypes = Set([PHAssetMediaType.image])
            presentOpalImagePickerController(picker, animated: true, select: { asset, allImages  in
                let requestOptions = PHImageRequestOptions()
                requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
                requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                requestOptions.isSynchronous = true
                var thumbnail = [UIImage]()
                let dGrrp = DispatchGroup()
                for images in asset{
                    if (images.mediaType == PHAssetMediaType.image) {
                        dGrrp.enter()
                        PHImageManager.default().requestImage(for: images , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
                            thumbnail.append(pickedImage!)
                            dGrrp.leave()
                        })
                    }
                }
                dGrrp.notify(queue: .main) {
                    self.gotoNext(thumbnails: thumbnail, allImages: allImages)
                }
            }, cancel: {
            })
        } else if objSelectiontype == 2 {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func gotoNext(thumbnails: [UIImage], allImages: [[String: Any]]) {
//        picker.dismiss(animated: true) {
//            let obj = self.storyboard!.instantiateViewController(withIdentifier: "EditImageVC") as! EditImageVC
//            obj.objIndex = self.objIndex
//            obj.objPickImage = 0
//            obj.objpresentPhotoVC = self
//            obj.objType = 1
//            obj.arrOfTotalImg.append(contentsOf: thumbnails)
//            self.navigationController?.pushViewController(obj, animated: true)
//        }
        picker.dismiss(animated: true) {
            let vc : ImageEditActionVC = self.storyboard?.instantiateViewController(withIdentifier: "EditImageStkVC") as! ImageEditActionVC
            vc.selectedDict = self.selectedDict
            vc.objType = 1
            vc.allImages = allImages
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            let obj : ImageEDITViewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "EditImageVC") as! ImageEDITViewcontroller
            obj.imgValue = pickedImage
            obj.objpresentPhotoVC = self
            obj.objType = 2
            self.navigationController?.pushViewController(obj, animated: true)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
