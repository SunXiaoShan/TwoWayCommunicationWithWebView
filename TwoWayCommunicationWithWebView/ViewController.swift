//
//  ViewController.swift
//  TwoWayCommunicationWithWebView
//
//  Created by Huang, Phineas on 2022/2/21.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var mainWebView: WKWebView!
    @IBOutlet weak var mainLabelView: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupWebView()
        injectingJavaScript2WebView()
    }
    
    func setupWebView() {
        guard let url = Bundle.main.url(forResource: "index", withExtension: "html") else {
            print("setup webview failed")
            return
        }

        mainWebView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        
    }
    
    func injectingJavaScript2WebView() {
        let contentController = mainWebView.configuration.userContentController
        contentController.add(self, name: "toggleMessageHandler")
        let js = """
            var _selector = document.querySelector('input[name=myCheckbox]');
            _selector.addEventListener('change', function(event) {
                var message = (_selector.checked) ? "Toggle Switch is on" : "Toggle Switch is off";
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.toggleMessageHandler) {
                    window.webkit.messageHandlers.toggleMessageHandler.postMessage({
                        "message": message
                    });
                }
            });
        """

        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)
    }
    
    func updateMainLabel(_ context:String) {
        DispatchQueue.main.async {
            self.mainLabelView.text = context
        }
    }
}

extension ViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else {
            return
        }

        print(dict)
        
        handleMessageEvent(dict)
    }
    
    func handleMessageEvent(_ dict:[String : AnyObject]) {
        guard let message = dict["message"] else {
            return
        }

        let script = "document.getElementById('value').innerText = \"\(message)\""

        mainWebView.evaluateJavaScript(script) { [weak self] (result, error) in
            if let result = result {
                print("Label is updated with message: \(result)")
                self?.updateMainLabel("Label is updated with message: \(result)")
            } else if let error = error {
                print("An error occurred: \(error)")
            }
        }
    }
}

