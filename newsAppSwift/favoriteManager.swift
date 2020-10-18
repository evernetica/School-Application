import Foundation
import SwiftyJSON

func getFavoriteArray() -> [String] {
    let defaults = UserDefaults.standard
    let myArray = defaults.stringArray(forKey: "FavoritePost") ?? [String]()
    return myArray
}

func addFavoritePost(post: String) -> Bool {
    let defaults = UserDefaults.standard
    var myArray = getFavoriteArray()
    let json = JSON()
    if existePost(id: json["id"].stringValue) {
        return false
    } else {
        myArray.append(post)
        defaults.set(myArray, forKey: "FavoritePost")
        return true
    }
}

func deleteFromFavorite(id: String) -> Bool {
    let defaults = UserDefaults.standard
    var myArray = getFavoriteArray()
    for index in 0 ..< myArray.count {
        let json = JSON(parseJSON: myArray[index])
        if json["id"].stringValue == id {
            myArray.remove(at: index)
            defaults.set(myArray, forKey: "FavoritePost")
            return true
        }
    }
    return false
}

func existePost(id: String) -> Bool {
    let myArray = getFavoriteArray()
    for item in myArray {
        let json = JSON(parseJSON: item)
        if json["id"].stringValue == id {
            return true
        }
    }
    return false
}
