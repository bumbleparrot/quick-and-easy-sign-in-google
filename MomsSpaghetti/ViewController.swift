//
//  ViewController.swift
//  MomsSpaghetti
//
//  Created by Michael Vo on 2/1/22.
//

import UIKit
import Amplify
import AWSMobileClient
import GoogleSignIn
import SwiftUI
import SwiftVideoBackground

class ViewController: UIViewController {
    @IBOutlet weak var signInButton: UIButton!
    
    var signInConfig = GIDConfiguration.init(clientID: "{your-client-id}.apps.googleusercontent.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        try? VideoBackground.shared.play(view: view, videoName: "wave-background-yellow", videoType: "mp4")
        signInButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func signInWithGoogle() {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { (user: GIDGoogleUser?, error: Error?) in
            if error != nil {
                print("Sign in with Google Error: \(error.debugDescription)")
                return
            }
            
            print("We signed in successfully?")
            if let user = user {
                print("Sign in was completed!: \(user)")
                self.fedateLoginToCognito(user)
            }
        }
    }
    
    func fedateLoginToCognito(_ user: GIDGoogleUser) {
        AWSMobileClient.default().federatedSignIn(providerName: "accounts.google.com", token: user.authentication.idToken!) { (userState:UserState?, error:Error?) in
            if error != nil {
                print("BP: error - federatedSignIn: \(String(describing: error))")
                return
            }
            
            switch userState {
            case .guest:
                break
            case .signedIn:
                print("BP: Signed in to Identity Pool")
                self.moveToSignedInViewController()
                break
            case .signedOut:
                break
            case .signedOutFederatedTokensInvalid:
                break
            case .signedOutUserPoolsTokenInvalid:
                break
            case .unknown:
                break
            default:
                break
            }
        }
    }
    
    func moveToSignedInViewController() {
        DispatchQueue.main.async {
            let signedInVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignedInViewController")
            self.present(signedInVC, animated: true, completion: nil)
        }
    }
}
