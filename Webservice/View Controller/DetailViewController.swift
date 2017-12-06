
import UIKit
import SDWebImage
import AFNetworking
import Alamofire

class DetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UISearchBarDelegate{
    
    @IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var btn: UIButton!
        
    var imagePicker = UIImagePickerController()
    var manager = AFHTTPSessionManager()
    
    var arrData = NSMutableArray()
    var arrSearch = NSMutableArray()
    var searchActive:Bool = false
    
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
        if searchActive {
            return self.arrSearch.count
        }
        return self.arrData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:CustomCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        var dict = NSDictionary()
        
        if searchActive {
            dict = self.arrSearch.object(at: indexPath.row) as! NSDictionary
        }
        else{
            dict = self.arrData.object(at: indexPath.row) as! NSDictionary
        }
        cell.lblTitle.text = dict.value(forKey: "product_name") as? String
        cell.lblDetail.text = dict.value(forKey: "short_description") as? String
        
        let arr = dict.value(forKey: "product_image") as! NSArray
        let str = arr.object(at: 0)
        
        cell.imgView.sd_setImage(with: URL(string: str as! String), placeholderImage: UIImage(named: ""))
        return cell
    }
    
    // MARK: - UISearchBar Delegate Methods -
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrSearch = NSMutableArray()
        if searchBar.text == "" {
            arrSearch = arrData
        } else {
            let namePredicate =
                NSPredicate(format: "product_name CONTAINS[cd] %@ OR short_description CONTAINS[cd] %@",searchBar.text!,searchBar.text!);
            
            let filteredArray = arrData.filter { namePredicate.evaluate(with: $0) };
            self.arrSearch.addObjects(from: filteredArray)
        }
        self.tbView.reloadData()
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
        dict.setValue("", forKey: "attribute_id")
        dict.setValue("", forKey: "brand_id")
        dict.setValue("", forKey: "category_id")
        dict.setValue("", forKey: "flavour_id")
        dict.setValue("", forKey: "goal_id")
        dict.setValue("", forKey: "measure_id")
        dict.setValue("20", forKey: "page_limit")
        dict.setValue("1", forKey: "page_num")
        dict.setValue("1", forKey: "product_type")
        dict.setValue("1", forKey: "sort_by")
        dict.setValue("412", forKey: "user_id")
        
        Alamofire.request(BROWSE_FILTER, method: .post, parameters: dict as? [String : AnyObject], encoding: JSONEncoding.default, headers: [:])
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let dict = JSON as! NSDictionary
                self.setData(dict: dict)
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        
//        self.manager.responseSerializer = AFHTTPResponseSerializer()
//        self.manager.post(BROWSE_FILTER, parameters: dict, progress: nil, success: { (operation:URLSessionDataTask, responseobject:Any?) in
//            do {
//                let resultJson = try JSONSerialization.jsonObject(with: responseobject as! Data, options: []) as? NSDictionary
//                let arr: NSArray = resultJson?.value(forKey: "data") as! NSArray
//                for i in 0..<arr.count{
//                    let dict = arr.object(at: i)
//                    self.arrData.addObjects(from: [dict])
//                }
//                self.tbView.reloadData()
//            } catch {
//                print("Error -> \(error)")
//            }
//        }, failure: { (operation:URLSessionDataTask?, error) in
//                print("Error -> \(error)")
//            })
    }
    
    func setData(dict: NSDictionary){
        let arr: NSArray = dict.value(forKey: "response") as! NSArray
        for i in 0..<arr.count{
            self.arrData.add(arr.object(at: i))
        }
        self.tbView.reloadData()
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
