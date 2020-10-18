import Alamofire
import SDWebImage
import SwiftyJSON
import UIKit

class favoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView = UITableView()
    var dataArray: Array<JSON>!
    override func viewDidLoad() {
        super.viewDidLoad()
        URLCache.shared.removeAllCachedResponses()
        if sideBarPosition == "left" {
            setupLeftMenuButton()
        } else {
            setupRightMenuButton()
        }
        navigationController?.navigationBar.barTintColor = baseColor
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
            navigationController?.navigationBar.tintColor = .white
            navigationItem.title = title

        } else {
            navigationController?.navigationBar.barTintColor = baseColor
            navigationController?.navigationBar.tintColor = .white
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

        navigationController?.navigationBar.topItem?.title = "Сохраненное"
        dataArray = []
        let data = getFavoriteArray()
        for item in data {
            let json = JSON(parseJSON: item)
            dataArray.append(json)
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Удалить"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)

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

        if dataArray.count == 0 {
            view.backgroundColor = UIColor.white
            let label = UILabel(frame: .zero)
            label.text = "Нет сохраненных записей"
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.font = UIFont(name: "SFUIText-Regular", size: 18)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            label.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            if #available(iOS 11.0, *) {
                label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
                label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
            } else {
            }
        } else {
            setupTable()
        }
    }

    func setupLeftMenuButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "menu.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(leftDrawerButtonPress), for: UIControl.Event.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 17)
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
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 17)
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
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: dateObj!)
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func setupTable() {
        tableView = UITableView(frame: UIScreen.main.bounds, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "favoriteViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.frame.size.height = UIScreen.main.bounds.height - 64
        tableView.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        if #available(iOS 11.0, *) {
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        } else {
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! favoriteViewCell
        cell.title.text = String(htmlEncodedString: dataArray[indexPath.row]["title_plain"].stringValue)
        let url = dataArray[indexPath.row]["thumbnail_images"]["full"]["url"].stringValue
        cell.imageArt.sd_setImage(with: NSURL(string: url) as URL?, placeholderImage: UIImage(named: "empty.png"))

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if deleteFromFavorite(id: dataArray[indexPath.row]["id"].stringValue) {
                dataArray.remove(at: indexPath.row)
                self.tableView.reloadData()
                if dataArray.count == 0 {
                    view.backgroundColor = UIColor.white
                    let label = UILabel(frame: .zero)
                    label.text = "Нет сохраненных записей"
                    label.font = UIFont(name: "SFUIText-Regular", size: 18)
                    label.textAlignment = NSTextAlignment.center
                    label.translatesAutoresizingMaskIntoConstraints = false
                    view.addSubview(label)

                    label.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
                    label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
                    if #available(iOS 11.0, *) {
                        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
                        label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
                    } else {
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "detail") as! detailsArticle
        controller.jsonData = dataArray[indexPath.row]
        navigationController!.pushViewController(controller, animated: true)
    }
}

extension UIApplication {
    class var statusBarBackgroundColor: UIColor? {
        get {
            return (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor
        } set {
            (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = newValue
        }
    }
}
