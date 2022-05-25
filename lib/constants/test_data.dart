import 'package:pos/database/db.dart';

final notifications = ['Notifications'];

const noOfTables = 20;
List<String> Categories = ['Veg', 'Non-Veg', 'Drinks'];
String dropdownvalue = 'Veg';
List tables = [];
MenuSchema menu = MenuSchema();

class TableSchema {
  final int index;

  TableSchema({required this.index});
  //otherdatas
  String? name;
  bool isOccupied = false;
  List<Map<String, Object>> foods = [];

  @override
  String toString() {
    return 'index: $index, name: $name, foods: ${foods.toString()}';
  }

  double getitemPrice({required String foodName}) {
    for (int index = 0; index < menu.menu.length; index++) {
      if (menu.menu[index]['name'] == foodName) {
        return menu.menu[index]['price'] as double;
      }
    }
    return 0;
  }

  double getItemTotalPrice({required String foodName}) {
    double price = getitemPrice(foodName: foodName);
    double sum = price * howMuch(foodName);
    return sum;
  }

  double get getTotalPrice {
    double sum = 0.0;

    if (foods.isEmpty) {
      return sum;
    }

    for (final i in foods) {
      for (final j in menu.menu) {
        if (i['name'] == j['name']) {
          double price = j['price'] as double;
          int no = i['noOfItem'] as int;

          sum = sum + price * no;
        }
      }
    }
    return sum;
  }

  void clear() {
    name = null;
    foods = [];
    isOccupied = false;
  }

  int contains(String food) {
    for (int index = 0; index < foods.length; index++) {
      if (foods[index]['name'] == food) {
        return index;
      }
    }
    return -1;
  }

  int howMuch(String food) {
    int pos = contains(food);

    if (pos != -1) {
      return foods[pos]['noOfItem'] as int;
    } else {
      return 0;
    }
  }

  void add(String food, int quantity) {
    int pos = contains(food);
    if (pos != -1) {
      int prev = foods[pos]['noOfItem'] as int;
      foods[pos]['noOfItem'] = quantity + prev;
    } else {
      foods.add({
        'name': food,
        'noOfItem': quantity,
      });
    }
  }

  void addFoodList(List<Map<String, Object>> foodList) {
    for (final i in foodList) {
      add(i['name'] as String, i['noOfItem'] as int);
    }
  }

  void remove(String food, int quantity) {
    int pos = contains(food);
    if (pos != -1) {
      int prev = foods[pos]['noOfItem'] as int;
      if (prev > 1) {
        foods[pos]['noOfItem'] = prev - quantity;
      } else {
        foods.removeAt(pos);
      }
    }
  }
}

class MenuSchema {
  //this is temporary initialization
  List<Map<String, dynamic>> menu = [];
  List<String> category = [];
  MenuDB db = MenuDB();

  @override
  String toString() {
    return '$menu';
  }

  void delete({required String name}) {
    db.deleteSingleItem(name: name);
  }

  void addSingleItem({required name, required price, required category}) {
    double price_ = double.parse(price);
    if (!_checkContents(name) && price_ > 0) {
      db.addSingleItem({'name': name, 'price': price_, 'category': category});
    }
  }

  bool _checkContents(String name) {
    for (final item in menu) {
      if (item['name'] == name) {
        return true;
      }
    }
    return false;
  }

  void populateMenu() async {
    final List<Map<String, dynamic>> tempMenu = await db.getAllItems();
    menu.clear();
    for (final item in tempMenu) {
      menu.add(item);
    }
  }

  void addAllItems(List<Map<String, Object>> menuList) {
    db.addAllItems(menuList);
  }

  void allCategory() {
    for (final item in menu) {
      if (!category.contains(item['category'] as String)) {
        category.add(item['category'] as String);
      }
    }
  }

  void addList(List<Map<String, Object>> menuList) {
    for (final item in menuList) {
      menu.add(item);
    }
  }

  void updateByIndex({required index, name = '', price = 0.0}) {
    if (name == null || name == '') {
    } else {
      menu[index]['name'] = name;
    }
    if (price > 0.0) {
      menu[index]['price'] = price;
    }
    return;
  }

  void deleteSingleItem({required name}) {
    db.deleteSingleItem(name: name);
  }

  void clean() {
    menu.clear();
  }

  void updateByMap({required index, required Map<String, Object> map}) {
    updateByIndex(index: index, name: map['name'], price: map['price']);
  }
}
