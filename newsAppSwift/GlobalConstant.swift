import Foundation
import UIKit

let baseColor = UIColor(netHex: 0x1D3C81)

let sideBarPosition = "left"

let directionApp = "LTR"

let urlWebsite = "http://3gym-samara.ru"

let oneSignalAppId = "9abb6182-9849-45b7-8a30-189bbfdd9c3e"

let applicationID = ""

let linkAppstore = "http://itunes.apple.com/"

let navigationBarTintColor = UIColor(netHex: 0x784BB9)
let navigationBarTextColor = UIColor(netHex: 0xFFFFFF)

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xFF, green: (netHex >> 8) & 0xFF, blue: netHex & 0xFF)
    }
}
