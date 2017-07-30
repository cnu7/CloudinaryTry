//
//  ViewController.swift
//  CloudinaryTry
//
//  Created by srinivasan on 30/07/17.
//  Copyright © 2017 srinivasan. All rights reserved.
//

import UIKit
import Cloudinary
import SDWebImage

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var selectedImage:UIImage?
    var imageURLs = Array<String>()
//    var imageDic = Dictionary<String, Any>()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - IBAction methods

    @IBAction func addButtonClicked(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - ViewController methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Other methods
    func uploadImage(image: UIImage, id:String, onCompletion: @escaping (_ status: Bool, _ url: String?) -> Void) {
        let config = CLDConfiguration(cloudinaryUrl: "cloudinary://155341583529472:4ftWQPJoT_a4DzvIe-eJzxKc0Ro@ds2iaixrj")
        let cloudinary = CLDCloudinary(configuration: config!)
        let data = UIImagePNGRepresentation(image) as Data?
        let params = CLDUploadRequestParams()
        let transformation = CLDTransformation().setWidth(200).setHeight(200)
//        let transformation = CLDTransformation().setWidth(200).setHeight(200).setCrop(.Thumb).setGravity(.Face)
//        params.setTransformation(CLDTransformation().setGravity(.NorthWest))

        params.setTransformation(transformation)
        params.setPublicId(id)
        let req = cloudinary.createUploader().signedUpload(data: data!, params: params, progress: { (progress)  in
            // Handle progress
        }, completionHandler: { (response, error) in
            // Handle response
            if error != nil{
                onCompletion(false, "Upload Failed!!!")
            }else{
               onCompletion(true, response?.secureUrl)
            }
        })
//        let request = cloudinary.createUploader().upload(data: data!, uploadPreset: "", params: params, progress: { (progress) in
//            // Handle progress
//        }) { (response, error) in
//            // Handle response
//        }

//        cloudinary.createUploader().signedUpload(data: data, params: <#T##CLDUploadRequestParams?#>, progress: <#T##((Progress) -> Void)?##((Progress) -> Void)?##(Progress) -> Void#>, completionHandler: <#T##((CLDUploadResult?, NSError?) -> ())?##((CLDUploadResult?, NSError?) -> ())?##(CLDUploadResult?, NSError?) -> ()#>)
//        let forUpload = UIImagePNGRepresentation(image)
//        let uploader:CLUploader = CLUploader(cloudinary, delegate: self)
//        uploader.upload(forUpload, options: nil,
//                        withCompletion: { (dataDictionary: [NSObject: AnyObject]!, errorResult:String!, code:Int, context: AnyObject!) -> Void in
//                            self.uploadResponse = Mapper<ImageUploadResponse>().map(dataDictionary)
//                            if code < 400 { onCompletion(status: true, url: self.uploadResponse?.imageURL)}
//                            else {onCompletion(status: false, url: nil)}
//        },
//                        andProgress: { (bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, context:AnyObject!) -> Void in
//                            print("Upload progress: \((totalBytesWritten * 100)/totalBytesExpectedToWrite) %");
//        }
//        )
    }
    
   }

extension ViewController:UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        
        if let image = info["UIImagePickerControllerOriginalImage"] as! UIImage?{
            selectedImage = image
            uploadImage(image: image, id: "\(self.imageURLs.count)", onCompletion: { (success:Bool, response:String?) in
                if success{
                    self.imageURLs.append(response!)
                    self.tableView.reloadData()
                    let alert = UIAlertController(title: "SUCCESS", message: "Image uploaded successfully.", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK",
                                                 style: .cancel, handler: { (alert:UIAlertAction) in
                        self.tableView.scrollToRow(at: IndexPath(row: self.imageURLs.count - 1, section: 0), at: .bottom, animated: true)
                    })
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController(title: "FAILED", message: "Something went wrong. Try uploading again.", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK",
                                                 style: .cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
       
//        let params = CLDUploadRequestParams()
//        let trans = CLDTransformation().setCrop("limit").set.setTags("samples").setWidth(200).setHeight(200)
//        params.setTransformation([trans])
//        cloudinary.createUploader().upload(url: "sample.jpg",  params: params)
//            .response({ (resultRes, errorRes) in
//                print(resultRes)
//            })
    }
}


extension ViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.imageURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ImageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
        cell.customImageView?.sd_setImage(with: URL(string:self.imageURLs[indexPath.row]), placeholderImage: UIImage(named: "placeholder.png"))
//        if let image = self.imageDic[self.imageURLs[indexPath.row]] as? UIImage{
//            cell.imageView?.image = image
//        }else{
//            //downloadImage
//            let urlString = self.imageURLs[indexPath.row]
//            NetworkHelper.sharedInstance.getData(urlString, params: nil, onSuccess: { (data) in
//                self.imageDic[self.imageURLs[indexPath.row]] = data
//                if (self.tableView.indexPathsForVisibleRows?.contains(indexPath))! {
//                    cell.imageView?.image = data as? UIImage
//                }
//            }){ (error) in
//                print(error)
//            }
//
//        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 232.0
    }
}

