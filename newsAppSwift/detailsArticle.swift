import MXParallaxHeader
import SDWebImage
import SVProgressHUD
import SwiftyJSON
import UIKit

class detailsArticle: UIViewController, UIScrollViewDelegate, UIWebViewDelegate {
    @IBOutlet var titleArt: UILabel!
    var jsonData: JSON = []
    var buttonFav = UIButton()
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var category: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var heightWeb: NSLayoutConstraint!
    @IBOutlet var traitArticle: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = baseColor
        SVProgressHUD.show()

        view.isUserInteractionEnabled = false
        let imageView = UIImageView()
        let url = jsonData["thumbnail_images"]["full"]["url"].stringValue
        imageView.sd_setImage(with: NSURL(string: url) as URL?, placeholderImage: UIImage(named: "empty.png"))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill

        scroll.parallaxHeader.view = imageView
        scroll.parallaxHeader.height = 200
        scroll.parallaxHeader.mode = MXParallaxHeaderMode.fill
        scroll.parallaxHeader.minimumHeight = 0

        let shape = CAShapeLayer()
        scroll.layer.addSublayer(shape)
        shape.opacity = 1
        shape.lineWidth = 0
        shape.lineJoin = CAShapeLayerLineJoin.miter
        shape.strokeColor = UIColor(hue: 0.786, saturation: 0.79, brightness: 0.53, alpha: 1.0).cgColor
        shape.fillColor = UIColor.white.cgColor

        if directionApp == "LTR" {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: -35))
            path.addLine(to: CGPoint(x: UIScreen.main.bounds.size.width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.close()
            shape.path = path.cgPath
        } else {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: UIScreen.main.bounds.size.width, y: -35))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: UIScreen.main.bounds.size.width, y: 0))
            path.close()
            shape.path = path.cgPath
        }

        titleArt.text = String(htmlEncodedString: jsonData["title_plain"].stringValue)
        titleArt.numberOfLines = 2
        titleArt.textColor = baseColor

        traitArticle.backgroundColor = baseColor.withAlphaComponent(0.8)
        category.text = String(htmlEncodedString: jsonData["categories"][0]["title"].stringValue)
        date.text = getDateFromString(String: jsonData["date"].stringValue)
        webView.scrollView.isScrollEnabled = false

        let htmlString: String = "<html><head><style type=\"text/css\"> body {font-family: \"SFUIText-Regular\"; font-size: 18;line-height:35px; direction:" + directionApp + ";} img { max-width: 100%; width: auto; height: auto; } iframe { max-width: atuo; width: auto; height: auto; }</style> </head><body>" + jsonData["content"].stringValue + "</body></html>"

        webView.loadHTMLString(htmlString, baseURL: nil)

        let buttonShare = UIButton(type: .custom)
        buttonShare.setImage(UIImage(named: "share.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        buttonShare.addTarget(self, action: #selector(rightDrawerShare), for: UIControl.Event.touchUpInside)
        buttonShare.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        buttonShare.imageView?.tintColor = .white
        let barButton = UIBarButtonItem(customView: buttonShare)

        buttonFav = UIButton(type: .custom)
        if existePost(id: jsonData["id"].stringValue) {
            buttonFav.setImage(UIImage(named: "heartFull.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        } else {
            buttonFav.setImage(UIImage(named: "heart.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        }
        buttonFav.addTarget(self, action: #selector(rightDrawerFavorite), for: UIControl.Event.touchUpInside)
        buttonFav.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        buttonFav.imageView?.tintColor = .white
        let barButton2 = UIBarButtonItem(customView: buttonFav)

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 20

        navigationItem.setRightBarButtonItems([barButton, space, barButton2], animated: false)

        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = baseColor

            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.compactAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = baseColor
            navigationItem.title = title

        } else {
            navigationController?.navigationBar.barTintColor = baseColor
            navigationController?.navigationBar.tintColor = baseColor
            navigationController?.navigationBar.isTranslucent = false
            navigationItem.title = title
        }
        navigationController?.navigationBar.tintColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
        }
    }

    func setupLeftMenuButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "menu.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 17)
        button.imageView?.tintColor = .white
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton

        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }

    @objc func rightDrawerShare(_ sender: AnyObject?) {
        let text = jsonData["url"].stringValue
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as! UIView?
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
        present(activityViewController, animated: true, completion: nil)
    }

    @objc func rightDrawerFavorite(_ sender: AnyObject?) {
        let data2 = jsonData.rawString()!
        if !existePost(id: jsonData["id"].stringValue) {
            if addFavoritePost(post: data2) {
                let alert = UIAlertController(title: "Новость добавлена в сохраненные", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
                buttonFav.setImage(UIImage(named: "heartFull.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
            } else {
                let alert = UIAlertController(title: "Post is already added", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }

    func getDateFromString(String: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: String)
        dateFormatter.dateFormat = "dd-MM-yy"
        return dateFormatter.string(from: dateObj!)
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let heightString = webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;"),
            let height = Float(heightString) {
            heightWeb.constant = CGFloat(height)

            _ = webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitUserSelect='none'")!
            _ = webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitTouchCallout='none'")!

            SVProgressHUD.dismiss()
            view.isUserInteractionEnabled = true
        }
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == UIWebView.NavigationType.linkClicked {
            let url = request.url!
            UIApplication.shared.openURL(url)
            return false
        }
        return true
    }

    @IBAction func commentViewController(_ sender: Any) {
        let vc = CommentViewController()
        vc.dataArray = jsonData["comments"].array
        navigationController!.pushViewController(vc, animated: true)
    }
}
