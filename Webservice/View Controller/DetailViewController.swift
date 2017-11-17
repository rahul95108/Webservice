
import UIKit
import AFNetworking

class DetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    @IBOutlet var tbView: UITableView!
    @IBOutlet var imgView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    var manager = AFHTTPSessionManager()
    var arrData = NSMutableArray()
    
    // MARK: - UIView Life Cycle Methods -

    override func viewDidLoad() {
        super.viewDidLoad()
        self.callChepterService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableView Delegate Methods -
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.arrData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:CustomCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        let dict = self.arrData.object(at: indexPath.row) as! NSDictionary
        cell.lblTitle.text = (dict.value(forKey: "short_description") as! String)
        return cell
    }
    
    // MARK: - UIButton Action Methods -
    
    @IBAction func btnUpload(_ sender: AnyObject){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgView.contentMode = .scaleToFill
            imgView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        self.imagUpload()
    }
    
    // MARK: - Webservice Delegate Methods -
    
    func callChepterService(){
        let dict = NSMutableDictionary()
        dict.setValue("4", forKey: "course_id")
        dict.setValue("412", forKey: "user_id")
        
        self.manager.responseSerializer = AFHTTPResponseSerializer()
        self.manager.post(CHEPTER_API, parameters: dict, progress: nil, success: { (operation:URLSessionDataTask, responseobject:Any?) in
            do {
                let resultJson = try JSONSerialization.jsonObject(with: responseobject as! Data, options: []) as? NSDictionary
                let arr: NSArray = resultJson?.value(forKey: "data") as! NSArray
                for i in 0..<arr.count{
                    let dict = arr.object(at: i)
                    self.arrData.addObjects(from: [dict])
                }
                self.tbView.reloadData()
            } catch {
                print("Error -> \(error)")
            }
        }, failure: { (operation:URLSessionDataTask?, error) in
                print("Error -> \(error)")
            })
    }
    
    // MARK: - Image Upload -
    
    func imagUpload(){
        let data = UIImagePNGRepresentation(imgView.image!) as NSData?
        print(data as Any);
        
        let dict = NSMutableDictionary()
        dict.setValue("", forKey: "birth_date")
        dict.setValue("", forKey: "bmi")
        dict.setValue("", forKey: "contact_no")
        dict.setValue("", forKey: "gender")
        dict.setValue("", forKey: "goal_id")
        dict.setValue("", forKey: "height")
        dict.setValue("", forKey: "height_type")
        dict.setValue("Rahul Patel", forKey: "name")
        dict.setValue("412", forKey: "user_id")
        dict.setValue("", forKey: "weight")
        dict.setValue("", forKey: "weight_type")
        
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(EDIT_PROFILE, parameters: dict, constructingBodyWith: { (formData:AFMultipartFormData) in
            formData.appendPart(withFileData: data! as Data, name: "profile_url", fileName: "image.jpg", mimeType: "image/jpeg")
        }, progress: nil, success: { (operation:URLSessionDataTask?, responseObject: Any?) in
            print("success")
        }) { (operation:URLSessionDataTask?, error) in
            print("failure")
        }
    }
}
