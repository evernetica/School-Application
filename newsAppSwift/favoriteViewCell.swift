import UIKit

class favoriteViewCell: UITableViewCell {
    @IBOutlet var imageArt: UIImageView!
    @IBOutlet var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.white
        title.textColor = UIColor.black
        if directionApp == "LTR" {
            title.textAlignment = NSTextAlignment.left
        } else {
            title.textAlignment = NSTextAlignment.right
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
