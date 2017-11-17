
import UIKit
import MBProgressHUD
import AFNetworking

class HomeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPostEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
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
        else if (!self.isValidEmail(testStr: txtEmail.text!)){
            let alertController = UIAlertController(title: "GET Service", message:"Please Provide Valid Email id.", preferredStyle: UIAlertControllerStyle.alert)
            let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(OK)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            self.showHud()
            self.getService()
        }
    }
    
    @IBAction func btnPOST(_ sender: AnyObject){
        if (txtPostEmail.text?.isEmpty)! {
            let alertController = UIAlertController(title: "POST Service", message:"Please Provide Email id.", preferredStyle: UIAlertControllerStyle.alert)
            let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(OK)
            self.present(alertController, animated: true, completion: nil)
        }
        else if (!self.isValidEmail(testStr: txtPostEmail.text!)){
            let alertController = UIAlertController(title: "POST Service", message:"Please Provide Valid Email id.", preferredStyle: UIAlertControllerStyle.alert)
            let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(OK)
            self.present(alertController, animated: true, completion: nil)
        }
        else if (txtPassword.text?.isEmpty)! {
            let alertController = UIAlertController(title: "POST Service", message:"Please Provide Password.", preferredStyle: UIAlertControllerStyle.alert)
            let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(OK)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            self.showHud()
            self.postService()
        }
    }
    
    // MARK: - Email Validation -
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // MARK: - Webservice Methods -
    
    func getService(){
        let FORGOT_EMAIL = FORGOT_API+txtEmail.text!
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.get(FORGOT_EMAIL, parameters: nil, progress: nil, success: { (operation:URLSessionDataTask, responseObject:Any?) in
            do {
                self.hidHud()
                let resultJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as? NSDictionary
                let alert = UIAlertController(title: "Alert", message: resultJson?.value(forKey: "response") as? String, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } catch {
                print("Error -> \(error)")
            }
        }, failure: { (operation:URLSessionDataTask?, error) in
            self.hidHud()
            print("Error")
        })
    }
    
    func postService(){
        let dict = NSMutableDictionary()
        dict.setValue(txtPostEmail.text, forKey: "Email_id")
        dict.setValue(txtPassword.text, forKey: "Password")
        dict.setValue("", forKey: "device_token")
        dict.setValue("iOS", forKey: "device_type")
        dict.setValue("1", forKey: "login_type")
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(LOGIN_API, parameters: dict, progress: nil, success: { (operation:URLSessionDataTask, responseObject:Any?) in
            self.hidHud()
            do {
                let resultJson = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as? [String:AnyObject]
                print("Result",resultJson!)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController")
                self.navigationController?.pushViewController(vc!, animated: true)
            } catch {
                print("Error -> \(error)")
            }
        }, failure: { (operation:URLSessionDataTask?, error) in
                self.hidHud()
                print("Error")
            })
    }
    
    // MARK: - UITextfield Delegate Methods -
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Progress Hud -
    
    func showHud(){
        self.view.endEditing(true)
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
    }
    
    func hidHud(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}
