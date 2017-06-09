//
//  ViewController.swift
//  MLImageTest
//
//  Created by Manuel J. Orán-Hernández on 6/7/17.
//  Copyright © 2017 Manuel J. Orán-Hernández. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit
import Vision



class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    let model = try? VNCoreMLModel(for: Resnet50().model)
    let imagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        activityIndicator.isHidden = true
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func chooseImageButtonTapped(_ sender: Any) {
        
        imagePicker.allowsEditing = false
        
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title:"Camera", style: .default, handler: {
            action in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            
            
        })
        
        let libraryAction = UIAlertAction(title:"Photo Library", style: .default, handler: {
            action in
            
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        
        
        present(actionSheet, animated: true)
        
        
        
        
    }
    
    
    
    @IBAction func predictButtonTapped(_ sender: Any) {
        
        if let image = imageView.image {
            
            updateUIState()
            
            resultsTextView.text.removeAll()
            resultsTextView.textAlignment = .center
            resultsTextView.text.append("Predicting...")
            
            DispatchQueue.global().async {
                
                let request = VNCoreMLRequest(model: self.model!, completionHandler: self.processPredictionResults)
                let handler = VNImageRequestHandler(cgImage: image.cgImage!)
                
                DispatchQueue.main.async {
                    try? handler.perform([request])
                }
                
            }
            
            
        }
    }
    
    
    
   private func processPredictionResults(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation]
            else { fatalError("Error making the prediction") }
        
        resultsTextView.text.removeAll()
        resultsTextView.textAlignment = .left
        
        for classification in results {
            
            // labels and confidences
            print(classification.identifier,
                  classification.confidence)
            
            resultsTextView.text.append("\n\(classification.identifier), \(classification.confidence)\n")
        }
        
        updateUIState()
        
    }
    
    
    private func updateUIState() {
        
        if activityIndicator.isAnimating {
            
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            view.alpha = 1.0
            
            UIApplication.shared.endIgnoringInteractionEvents()
            
            
            
        } else {
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            view.alpha = 0.8
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            
            
        }
        
        
    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
}



