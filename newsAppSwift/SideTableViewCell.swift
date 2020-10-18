import UIKit

class SideTableViewCell: UITableViewCell {
    @IBOutlet var titleLable: UILabel!
    @IBOutlet var childTableView: UITableView!
    @IBOutlet var heightTable: NSLayoutConstraint!
    @IBOutlet var dropDownImage: UIButton!
    var delegate: DropdownDelegate?
    var isOpen: Bool = false

    static func heightForChildren(count: Int) -> CGFloat {
        return CGFloat(40 + 44 * count)
    }

    private var indexPath: IndexPath?

    var child: [Category] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        heightTable.constant = 0
        titleLable.frame = CGRect(x: 20, y: 12, width: titleLable.bounds.width * 0.87, height: titleLable.bounds.height)
    }

    @IBAction func clickDropdownImage(_ sender: Any) {
        if isOpen {
            isOpen = false
            if let image = UIImage(named: "close.png") {
                dropDownImage.setImage(image, for: .normal)
            }
            delegate?.pressToClose(indexPath: indexPath!)
        } else {
            isOpen = true
            if let image = UIImage(named: "open.png") {
                dropDownImage.setImage(image, for: .normal)
            }
            delegate?.pressToOpen(indexPath: indexPath!)
        }
    }

    override func prepareForReuse() {
        heightTable.constant = 0
        super.prepareForReuse()
    }

    func setCategory(child: [Category]?, indexPath: IndexPath) {
        self.child = child ?? []
        self.indexPath = indexPath
        if self.child.isEmpty {
            dropDownImage.isHidden = true
        } else {
            dropDownImage.isHidden = false
        }
        childTableView.delegate = self
        childTableView.dataSource = self
        childTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        childTableView.separatorStyle = .none
        childTableView.backgroundColor = .clear
        if (child?.count ?? 0) > 0 {
            heightTable.constant = CGFloat(44 * (child?.count ?? 0))
        } else {
            heightTable.constant = 0
        }
        childTableView.reloadData()
        layoutIfNeeded()
    }
}

extension SideTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.openSelectedMenu(indexPathMain: self.indexPath!, indexPathChild: indexPath)
    }
}

extension SideTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return child.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: cell.contentView.frame.size.width - 20, height: 30))
        label.textColor = .white
        label.font = UIFont(name: "SFUIText-Regular", size: 18)
        label.textAlignment = NSTextAlignment.left
        label.text = child[indexPath.row].title
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.addSubview(label)
        return cell
    }
}

protocol DropdownDelegate {
    func pressToOpen(indexPath: IndexPath)
    func pressToClose(indexPath: IndexPath)
    func openSelectedMenu(indexPathMain: IndexPath, indexPathChild: IndexPath)
}
