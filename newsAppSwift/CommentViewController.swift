import Alamofire
import SwiftyJSON
import UIKit

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView = UITableView()
    var dataArray: Array<JSON>!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Комментарии"

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .automatic

            let attributes = [
                NSAttributedString.Key.foregroundColor: navigationBarTextColor, NSAttributedString.Key.font: UIFont(name: "SFUIText-Medium", size: 34),
            ]

            navigationController?.navigationBar.largeTitleTextAttributes = attributes as [NSAttributedString.Key: Any]

        } else {
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
            navigationController?.navigationBar.tintColor = .white
            navigationItem.title = title

        } else {
            navigationController?.navigationBar.barTintColor = baseColor
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.isTranslucent = false
            navigationItem.title = title
        }

        if #available(iOS 11.0, *) {
            self.extendedLayoutIncludesOpaqueBars = true
        } else {
        }

        if dataArray.count == 0 {
            let label = UILabel(frame: .zero)
            label.text = "Нет комментариев"

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
        } else {
            setupTable()
        }
    }

    func getDateFromString(String: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: String)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: dateObj!)
    }

    func setupTable() {
        tableView = UITableView(frame: UIScreen.main.bounds, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "commentViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.frame.size.height = UIScreen.main.bounds.height - 64
        tableView.bounces = false
        tableView.allowsSelection = false
        tableView.backgroundColor = .white
        view.addSubview(tableView)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! commentViewCell
        cell.commentText.text = String(htmlEncodedString: dataArray[indexPath.row]["content"].stringValue)
        cell.name.text = String(htmlEncodedString: dataArray[indexPath.row]["name"].stringValue)
        cell.date.text = getDateFromString(String: dataArray[indexPath.row]["date"].stringValue)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
