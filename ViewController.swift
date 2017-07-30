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
    var selectedImage:UIImage?// to handle image upload failure
    var imageURLs = Array<String>()
    var cloudinary:CLDCloudinary?
    var params:CLDUploadRequestParams?
    
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
        setUpCloudinary()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Image Uploader method
    func uploadImage(image: UIImage, id:String, onCompletion: @escaping (_ status: Bool, _ url: String?) -> Void) {
        params?.setPublicId(id)
        let data = UIImagePNGRepresentation(image) as Data?
        cloudinary?.createUploader().signedUpload(data: data!, params: params, progress: { (progress)  in
            // Handle upload progress
        }, completionHandler: { (response, error) in
            // Handle response
            if error != nil{
                onCompletion(false, "Upload Failed!!!")
            }else{
               onCompletion(true, response?.secureUrl)
            }
        })
    }
    
    // MARK: - Initial setup methods
    func setUpCloudinary(){
        let config = CLDConfiguration(cloudinaryUrl: "cloudinary://155341583529472:4ftWQPJoT_a4DzvIe-eJzxKc0Ro@ds2iaixrj")
        cloudinary = CLDCloudinary(configuration: config!)
        params = CLDUploadRequestParams()
        let transformation = CLDTransformation().setWidth(200).setHeight(200)
        params?.setTransformation(transformation)
    }
    
   }

extension ViewController:UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        self.dismiss(animated: true, completion: { () -> Void in
            // do something after dismisal fo image picker
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
        }else{
            let alert = UIAlertController(title: "Error", message: "Something went wrong. Could not fetch image. Please try again.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 232.0
    }
}

