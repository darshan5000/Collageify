//
//  AuthViewController.swift
//  Spotify
//
//  Created by Salvador on 05/02/23.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {

    //    @IBOutlet weak var viewWeb: UIView!
    //
    //    private let webView: WKWebView = {
    //        let prefs = WKWebpagePreferences()
    //        prefs.allowsContentJavaScript = true
    //        let config = WKWebViewConfiguration()
    //        config.defaultWebpagePreferences = prefs
    //        let webView = WKWebView(frame: .zero, configuration: config)
    //        return webView
    //    }()
    //
    //    public var completionHandler: ((Bool) -> Void)?
    //
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //        webView.navigationDelegate = self
    //        viewWeb.addSubview(webView)
    //        guard let url = AuthManager.shared.signInURL else { return  }
    //        webView.load(URLRequest(url: url))
    //    }
    //
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //        webView.frame = view.bounds
    //    }
    //
    //    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    //        guard let url = webView.url else { return }
    //        guard let code =  URLComponents(string: url.absoluteString)?.queryItems?.first(where: {$0.name == "code"})?.value else { return }
    //
    //        webView.isHidden = true
    //        AuthManager.shared.exchangeCodeForToken(code: code) {[weak self] success in
    //            DispatchQueue.main.async {
    //                self?.dismiss(animated: true, completion: {
    //                    self?.completionHandler?(success)
    //                })
    //            }
    //        }
    //    }
    //
    //    @IBAction func actionClose(_ sender: UIButton) {
    //        self.dismiss(animated: true)
    //    }
}
