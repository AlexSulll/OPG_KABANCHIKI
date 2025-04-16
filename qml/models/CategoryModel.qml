//Модель категории
/*Объект состоит из следующих полей:
    id - индефикатор категории из БД
    nameCategory - название категории
    pathToIcon - путь до иконки категории
*/
import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject {
    objectName: "CategoryModel"

    property int id: 0
    property string nameCategory: ""
    property string pathToIcon: ""

    function fromJson(json) {
        try {
            id = json['id'];
            nameCategory = json['nameCategory'];
            pathToIcon = json['pathToIcon'];
        } catch (e) {
            return False;
        }
        return True;
    }
}
