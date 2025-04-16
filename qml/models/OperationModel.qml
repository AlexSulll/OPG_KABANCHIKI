//Модель операции (расход, доход)
/*Объект состоит из следующих полей:
  id - индефикатор операции из БД
  action - действие (0 - расход, 1 - доход)
  category - категория дохода и расхода
  date - дата операции
  desc - коментарии
*/
import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject {
    objectName: "OperationModel"

    property int id: 0
    property int action: 0
    property int category: 0
    property string date: ""
    property string desc: ""

    function fromJson(json) {
        try {
            id = json['id'];
            action = json['action'];
            category = json['category'];
            date = json['date'];
            desc = json['desc'];
        } catch (e) {
            return False;
        }
        return True;
    }
}
