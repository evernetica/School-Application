import Alamofire
import MMDrawerController
import SDWebImage
import SVProgressHUD
import SwiftyJSON
import SystemConfiguration
import UIKit

class homeController: UIViewController {
    var collectionView: UICollectionView!
    var dataArray: Array<JSON>!
    var page: Int = Int()
    var refreshControl = UIRefreshControl()
    var isRefresh: Int = Int()
    var urlPage: String = ""
    var pageTitle: String = ""
    var moreDataNum: Int = Int()
    var articleID: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        URLCache.shared.removeAllCachedResponses()
        if sideBarPosition == "left" {
            setupLeftMenuButton()
        } else {
            setupRightMenuButton()
        }
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

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .automatic

            let attributes = [
                NSAttributedString.Key.foregroundColor: navigationBarTextColor, NSAttributedString.Key.font: UIFont(name: "SFUIText-Medium", size: 34),
            ]

            navigationController?.navigationBar.largeTitleTextAttributes = attributes as [NSAttributedString.Key: Any]

        } else {
        }

        if #available(iOS 11.0, *) {
            self.extendedLayoutIncludesOpaqueBars = true
        } else {
        }

        if articleID != "" {
            getDataArticle()
        }

        page = 0
        if urlPage == "" {
            navigationController?.navigationBar.topItem?.title = "Актуальное"
            urlPage = "\(urlWebsite)?json=get_recent_posts&count=15&page="
        } else {
            navigationController?.navigationBar.topItem?.title = pageTitle
        }
        getMoreData()
    }

    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
        }
    }

    func getMoreData() {
        URLCache.shared.removeAllCachedResponses()
        page += 1
        if connectedToNetwork() == false {
            SVProgressHUD.showError(withStatus: "No Internet Connection")
        } else {
            if isRefresh == 1 {
                refreshGetData()
            } else {
                SVProgressHUD.show()
                Alamofire.request("\(urlPage)\(page)").responseJSON { response in
                    if let data = response.result.value {
                        let json2 = JSON(data)
                        self.moreDataNum = json2["count"].intValue
                        if self.dataArray?.isEmpty == false {
                            self.dataArray.append(contentsOf: json2["posts"].arrayValue)
                            self.collectionView.reloadData()
                        } else {
                            if self.collectionView == nil {
                                self.dataArray = json2["posts"].arrayValue
                                self.setupCollectionView()
                            }
                        }
                    }
                    SVProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                }
            }
        }
    }

    func refreshGetData() {
        URLCache.shared.removeAllCachedResponses()
        Alamofire.request("\(urlPage)1").responseJSON { response in
            if let data = response.result.value {
                let json2 = JSON(data)
                self.moreDataNum = json2["count"].intValue
                self.dataArray.removeAll()
                self.isRefresh = 0
                self.dataArray = json2["posts"].arrayValue
                DispatchQueue.main.async(execute: { self.dataRefresh() })
            }
        }
    }

    func dataRefresh() {
        collectionView.reloadData()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    func getDataArticle() {
        URLCache.shared.removeAllCachedResponses()
        Alamofire.request("\(urlWebsite)?json=get_post&post_id=\(articleID)").responseJSON { response in
            if let data = response.result.value {
                let json2 = JSON(data)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "detail") as! detailsArticle
                controller.jsonData = json2["post"]
                self.navigationController!.pushViewController(controller, animated: true)
            }
        }
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        if #available(iOS 11.0, *) {
            collectionView.frame.size.height = UIScreen.main.bounds.height - 64
        } else {
            collectionView.frame.size.height = UIScreen.main.bounds.height - 64
        }

        collectionView.backgroundColor = UIColor.white
        collectionView.register(UINib(nibName: "homeViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        if #available(iOS 11.0, *) {
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        } else {
        }

        refreshControl.addTarget(self, action: #selector(homeController.refresh), for: UIControl.Event.valueChanged)

        if #available(iOS 10.0, *) {
            refreshControl.tintColor = .white
            self.collectionView.refreshControl = refreshControl
        } else {
            collectionView?.addSubview(refreshControl)
        }
    }

    @objc func refresh() {
        page = 0
        isRefresh = 1
        getMoreData()
    }

    func setupLeftMenuButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "menu.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(leftDrawerButtonPress), for: UIControl.Event.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 17) // CGRectMake(0, 0, 30, 30)
        button.imageView?.tintColor = .white
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton

        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }

    @objc func leftDrawerButtonPress(_ sender: AnyObject?) {
        mm_drawerController?.toggle(.left, animated: true, completion: nil)
    }

    func setupRightMenuButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "menu.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(rightDrawerButtonPress), for: UIControl.Event.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 17) // CGRectMake(0, 0, 30, 30)
        button.imageView?.tintColor = .white
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton

        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }

    @objc func rightDrawerButtonPress(_ sender: AnyObject?) {
        mm_drawerController?.toggle(.right, animated: true, completion: nil)
    }

    func getDateFromString(String: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: String)
        dateFormatter.dateFormat = "dd-MM-yy"
        return dateFormatter.string(from: dateObj!)
    }

    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return (isReachable && !needsConnection)
    }
}

extension homeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! homeViewCell
        cell.title.text = String(htmlEncodedString: dataArray[indexPath.row]["title_plain"].stringValue)
        let url = dataArray[indexPath.row]["thumbnail_images"]["full"]["url"].stringValue
        cell.imageArticle.sd_setImage(with: NSURL(string: url) as URL?, placeholderImage: UIImage(named: "empty.png"))
        cell.category.text = String(htmlEncodedString: dataArray[indexPath.row]["categories"][0]["title"].stringValue)
        cell.date.text = getDateFromString(String: dataArray[indexPath.row]["date"].stringValue)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == dataArray.count - 1 {
            if moreDataNum != 0 {
                view.isUserInteractionEnabled = false
                getMoreData()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "detail") as! detailsArticle
        controller.jsonData = dataArray[indexPath.row]
        navigationController!.pushViewController(controller, animated: true)
    }
}

extension String {
    init(htmlEncodedString: String) {
        self.init()
        guard let encodedData = htmlEncodedString.data(using: .utf8) else {
            self = htmlEncodedString
            return
        }

        let attributedOptions: [String: Any] = [
            convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.documentType): convertFromNSAttributedStringDocumentType(NSAttributedString.DocumentType.html), convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.characterEncoding): String.Encoding.utf8.rawValue,
        ]
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: convertToNSAttributedStringDocumentReadingOptionKeyDictionary(attributedOptions), documentAttributes: nil)
            self = attributedString.string
        } catch {
            print("Error: \(error)")
            self = htmlEncodedString
        }
    }
}

fileprivate func convertFromNSAttributedStringDocumentAttributeKey(_ input: NSAttributedString.DocumentAttributeKey) -> String {
    return input.rawValue
}

fileprivate func convertFromNSAttributedStringDocumentType(_ input: NSAttributedString.DocumentType) -> String {
    return input.rawValue
}

fileprivate func convertToNSAttributedStringDocumentReadingOptionKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.DocumentReadingOptionKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.DocumentReadingOptionKey(rawValue: key), value) })
}
