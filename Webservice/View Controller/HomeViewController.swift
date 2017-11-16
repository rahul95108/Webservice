
import UIKit
import AFNetworking

class HomeViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    var manager = AFHTTPSessionManager()
    
    
    // MARK: - UIView Life Cycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UIButton Action Methods -
    
    @IBAction func btnGET(_ sender: AnyObject){
        if (txtEmail.text?.isEmpty)! {
            let alertController = UIAlertController(title: "GET Service", message:"Please Provide Email id.", preferredStyle: UIAlertControllerStyle.alert)
            let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(OK)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            self.getService()
        }
    }
    
    // MARK: - GET Webservice Methods -
    
    func getService(){
//        Receive response as NSDictionary instead of NSData
        let FORGOT_EMAIL = FORGOT_API+txtEmail.text!
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.get(FORGOT_EMAIL, parameters: nil, progress: nil, success: { (operation: URLSessionDataTask, responseObject: Any?) in
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: responseObject as! Data, options: .allowFragments) as! NSDictionary
                print(jsonObject.value(forKey: "response")!)
                let alertController = UIAlertController(title: (jsonObject.value(forKey: "response") as! String), message:nil, preferredStyle: UIAlertControllerStyle.alert)
                let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                alertController.addAction(OK)
                self.present(alertController, animated: true, completion: nil)
            } catch {
                print("json error: \(error)")
            }
        }, failure: { (operation: URLSessionDataTask?, error) in
            print("Failure")
        })
        
//        manager.responseSerializer = AFHTTPResponseSerializer()
//        manager.get(FORGOT_EMAIL, parameters: nil, progress: nil, success: { (operation:URLSessionTask, responseObject: Any?) in
//
//        }, failure: {(operation:URLSessionTask, error) in
//
//        }
    }
}
