import Alamofire
import OneSignal
import SwiftyJSON
import UIKit

class rightSideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var dataArray: Array<JSON>!
    override func viewDidLoad() {
        super.viewDidLoad()

        Alamofire.request("\(urlWebsite)?json=get_category_index").responseJSON { response in
            if let data = response.result.value {
                let json2 = JSON(data)
                self.dataArray = json2["categories"].arrayValue
                self.setupTable()
            }
        }

        view.backgroundColor = .clear
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let topSideBarBackgroundColor = baseColor.cgColor
        let bottomSideBarBackgroundColor = baseColor.withAlphaComponent(0.5).cgColor
        layer.colors = [topSideBarBackgroundColor, bottomSideBarBackgroundColor]
        view.layer.insertSublayer(layer, at: 0)
    }

    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.frame.origin.y = 20
        tableView.frame.size.height = UIScreen.main.bounds.height - 20
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
    }

    func reloadData() {
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataArray.count + 1
        } else {
            return 3
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: view.frame.size.width - 20, height: 30))
        label.textColor = .white
        label.font = UIFont(name: "SFUIText-Regular", size: 18)
        label.textAlignment = NSTextAlignment.right

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                label.text = "     الرئيسية"
            } else {
                label.text = "     \(String(htmlEncodedString: dataArray[indexPath.row - 1]["title"].stringValue))"
            }

        } else {
            if indexPath.row == 0 {
                label.text = "     المفضلة"
            } else if indexPath.row == 1 {
                label.text = "     التنبيهات"
                let mySwitch = UISwitch(frame: CGRect(x: cell.bounds.origin.x + 80, y: cell.bounds.origin.y + 5, width: 0, height: 0))
                let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
                if isRegisteredForRemoteNotifications {
                    mySwitch.setOn(true, animated: false)
                } else {
                    mySwitch.setOn(false, animated: false)
                }
                mySwitch.addTarget(self, action: #selector(sideViewController.switchChanged(mySwitch:)), for: UIControl.Event.valueChanged)
                cell.addSubview(mySwitch)
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            } else {
                label.text = "     شارك التطبيق"
            }
        }

        cell.backgroundColor = UIColor.clear
        cell.addSubview(label)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "  التصنيفات"
        } else {
            return "  الإعدادات"
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        returnedView.backgroundColor = UIColor.black.withAlphaComponent(0.1)

        let label = UILabel(frame: CGRect(x: 10, y: 5, width: view.frame.size.width - 20, height: 30))
        if section == 0 {
            label.text = "  التصنيفات"
        } else {
            label.text = "  الإعدادات"
        }
        label.textColor = .white
        label.font = UIFont(name: "SFUIText-Regular", size: 18)
        label.textAlignment = NSTextAlignment.right
        returnedView.addSubview(label)
        return returnedView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let centerViewController = homeController()
                let navigationController = UINavigationController(rootViewController: centerViewController)
                centerViewController.urlPage = ""
                mm_drawerController?.setCenterView(navigationController, withCloseAnimation: true, completion: nil)
            } else {
                let idCategory = dataArray[indexPath.row - 1]["id"].intValue
                let centerViewController = homeController()
                let navigationController = UINavigationController(rootViewController: centerViewController)
                centerViewController.urlPage = "\(urlWebsite)?json=get_category_posts&category_id=\(idCategory)&count=150&page="
                centerViewController.pageTitle = dataArray[indexPath.row - 1]["title"].stringValue
                mm_drawerController?.setCenterView(navigationController, withCloseAnimation: true, completion: nil)
            }
        } else {
            if indexPath.row == 0 {
                let centerViewController = favoriteViewController()
                let navigationController = UINavigationController(rootViewController: centerViewController)
               mm_drawerController?.setCenterView(navigationController, withCloseAnimation: true, completion: nil)
            } else if indexPath.row == 1 {
            } else {
                let text = linkAppstore
                let currentCell = tableView.cellForRow(at: indexPath)
                let textToShare = [text]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = currentCell as UIView?
                activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]

                present(activityViewController, animated: true, completion: nil)
            }
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    func switchChanged(mySwitch: UISwitch) {
        if mySwitch.isOn {
            print("ON")
            OneSignal.setSubscription(true)
        } else {
            print("OFF")
            OneSignal.setSubscription(false)
        }
    }
}
