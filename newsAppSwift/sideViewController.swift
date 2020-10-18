import Alamofire
import OneSignal
import SwiftyJSON
import UIKit

class sideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DropdownDelegate {
    @IBOutlet var tableView: UITableView!

    var dataArray: Array<CategoryUI>! = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let categoryUI = CategoryUI()
        categoryUI.title = "Актуальное"
        dataArray.append(categoryUI)
        Alamofire.request("\(urlWebsite)?json=get_category_index").responseCategoryJSON { response in
            if let category = response.result.value {
                for categoryItem in category.categories {
                    if categoryItem.parent == 0 {
                        let categoryUI = CategoryUI()
                        categoryUI.id = categoryItem.id
                        categoryUI.categoryDescription = categoryItem.categoryDescription
                        categoryUI.postCount = categoryItem.postCount
                        categoryUI.slug = categoryItem.slug
                        categoryUI.title = categoryItem.title
                        for categoryChild in category.categories {
                            if categoryChild.parent == categoryUI.id {
                                categoryUI.child?.append(categoryChild)
                            }
                        }
                        self.dataArray.append(categoryUI)
                    }
                }

                self.setupTable()
                self.tableView.reloadData()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
    }

    func updateTableView() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SideViewCell", bundle: nil), forCellReuseIdentifier: "sideTableViewCell")

        tableView.frame.origin.y = 40
        tableView.frame.size.height = UIScreen.main.bounds.height - 20
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
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
            return dataArray.count
        } else {
            return 3
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideTableViewCell", for: indexPath) as! SideTableViewCell
        if indexPath.section == 0 {
            cell.titleLable.text = String(htmlEncodedString: dataArray[indexPath.row].title ?? "")
            cell.setCategory(child: dataArray[indexPath.row].child ?? [], indexPath: indexPath)
            cell.delegate = self
        } else {
            if indexPath.row == 0 {
                cell.titleLable.text = "Сохраненное"
            } else if indexPath.row == 1 {
                cell.titleLable.text = "Уведомления"
                let mySwitch = UISwitch(frame: CGRect(x: cell.bounds.origin.x + 200, y: cell.bounds.origin.y + 5, width: 0, height: 0))
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                let isSubscribed = status.subscriptionStatus.subscribed
                print("isSubscribed = \(isSubscribed)")
                if isSubscribed {
                    mySwitch.setOn(true, animated: false)
                } else {
                    mySwitch.setOn(false, animated: false)
                }
                mySwitch.addTarget(self, action: #selector(sideViewController.switchChanged(mySwitch:)), for: UIControl.Event.valueChanged)
                cell.addSubview(mySwitch)
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                updateTableView()
            } else {
                cell.titleLable.text = "Поделиться приложением"
            }
        }
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "  category"
        } else {
            return "  other"
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        returnedView.backgroundColor = UIColor(netHex: 0x041D54)

        let label = UILabel(frame: CGRect(x: 10, y: 5, width: view.frame.size.width - 20, height: 30))
        if section == 0 {
            label.text = "  Категории"
        } else {
            label.text = "  Другое"
        }
        label.textColor = .white
        label.font = UIFont(name: "SFUIText-Regular", size: 18)
        returnedView.addSubview(label)

        return returnedView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath[0] == 0 {
            if dataArray[indexPath.row].isSelected {
                return SideTableViewCell.heightForChildren(count: dataArray[indexPath.row].child?.count ?? 0)
            } else {
                return 40
            }
        } else {
            return 40
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func pressToOpen(indexPath: IndexPath) {
        dataArray[indexPath.row].isSelected = !dataArray[indexPath.row].isSelected
        tableView.reloadData()
    }

    func pressToClose(indexPath: IndexPath) {
        dataArray[indexPath.row].isSelected = !dataArray[indexPath.row].isSelected
        tableView.reloadData()
    }

    func openSelectedMenu(indexPathMain: IndexPath, indexPathChild: IndexPath) {
        let centerViewController = homeController()
        let navigationController = UINavigationController(rootViewController: centerViewController)
        let idCategory = dataArray[indexPathMain.row].child?[indexPathChild.row].id
        centerViewController.urlPage = "\(urlWebsite)?json=get_category_posts&category_id=\(idCategory!)&count=150&page="
        centerViewController.pageTitle = dataArray[indexPathMain.row].child?[indexPathChild.row].title ?? ""
        mm_drawerController?.setCenterView(navigationController, withCloseAnimation: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let centerViewController = homeController()
                let navigationController = UINavigationController(rootViewController: centerViewController)
                centerViewController.urlPage = ""
                mm_drawerController?.setCenterView(navigationController, withCloseAnimation: true, completion: nil)
            } else {
                let idCategory = dataArray[indexPath.row].id!
                let centerViewController = homeController()
                let navigationController = UINavigationController(rootViewController: centerViewController)
                centerViewController.urlPage = "\(urlWebsite)?json=get_category_posts&category_id=\(idCategory)&count=15&page="
                centerViewController.pageTitle = dataArray[indexPath.row].title ?? ""
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

    @objc func switchChanged(mySwitch: UISwitch) {
        if mySwitch.isOn {
            print("ON")
            OneSignal.setSubscription(true)
        } else {
            print("OFF")
            OneSignal.setSubscription(false)
        }
    }
}
