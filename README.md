# TwoWayCommunicationWithWebView

This is a demo two way communication between webview and iOS native code.

Reference:
https://diamantidis.github.io/2020/02/02/two-way-communication-between-ios-wkwebview-and-web-page

<br />

### HTML Resource

```html
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <style>
            .switch { position: relative; display: inline-block; width: 60px; height: 34px; }
            .switch input { opacity: 0; width: 0; height: 0; }
            label.switch { outline: none; }
            .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; -webkit-transition: .4s; transition: .4s; outline: none; }
            .slider:before { position: absolute; content: ""; height: 26px; width: 26px; left: 4px; bottom: 4px; background-color: white; -webkit-transition: .4s; transition: .4s; }
            input:checked + .slider { background-color: #2196F3; }
            input:focus + .slider { box-shadow: 0 0 1px #2196F3; }
            input:checked + .slider:before { -webkit-transform: translateX(26px); -ms-transform: translateX(26px); transform: translateX(26px); }
            .slider.round { border-radius: 34px; }
            .slider.round:before { border-radius: 50%; }
        </style>
    </head>
    <body>
        <h2 id="value">Toggle Switch is off</h2>
        <label class="switch">
            <input type="checkbox" name="myCheckbox">
            <span class="slider round"></span>
        </label>
    </body>
</html>
```

<br />

### Setup the webview

```swift
func setupWebView() {
    guard let url = Bundle.main.url(forResource: "index", withExtension: "html") else {
        print("setup webview failed")
        return
    }

    mainWebView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
}
```

<br />

### Inject a script into content & add an observer toggleMessageHandler

```swift
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
```

<br />

### Implement delegate

```swift
func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    guard let dict = message.body as? [String : AnyObject] else {
        return
    }

    print(dict)

    handleMessageEvent(dict)
}
```
