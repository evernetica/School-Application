import UIKit

class homeViewCell: UICollectionViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var imageArticle: UIImageView!
    @IBOutlet var category: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        title.numberOfLines = 2
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
        let top = UIColor.clear.cgColor
        let bottom = UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1.0).cgColor
        layer.colors = [top, bottom]
        layer.opacity = 0.7
        imageArticle.layer.insertSublayer(layer, at: 0)
        self.layer.cornerRadius = 4.0
    }
}
