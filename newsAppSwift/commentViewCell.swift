import UIKit

class commentViewCell: UITableViewCell {
    @IBOutlet var date: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var commentText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        date.textColor = baseColor
        name.textColor = baseColor
        if directionApp == "LTR" {
            commentText.textAlignment = NSTextAlignment.left
        } else {
            commentText.textAlignment = NSTextAlignment.right
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
