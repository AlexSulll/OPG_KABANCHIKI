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
//import "CategoryModel.qml"

ListModel {
    id: operationModel
//    objectName: "OperationModel"

//    property int id: 0
//    property int amount: 0
//    property int action: 0
//    property string category: ""
//    property string date: ""
//    property string desc: ""

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

    function addOperation(operation) {
        append({
                   id: operation.id,  // id операции
                   amount: operation.amount,  // Сумма операции
                   action: operation.action,  // Тип операции (0 - расход, 1 - доход)
                   category: operation.category,  // Категория
                   date: operation.date,  // Дата операции
                   desc: operation.desc  // Описание операции
        });
    }
}
