import 'data.dart';

mixin ValidationMixin {
  void validateName(String name) {
    final checkNameNotEmpty = checkNot("Ім'я");
    final errorMessage = checkNameNotEmpty(name);
    if (errorMessage != null) {
      throw ArgumentError(errorMessage);
    }
  }

  void validateAddress(String address) {
    final checkAddressNotEmpty = checkNot("Адреса");
    final errorMessage = checkAddressNotEmpty(address);
    if (errorMessage != null) {
      throw ArgumentError(errorMessage);
    }
  }

  void validateTime(String time) {
    final checkTimeNotEmpty = checkNot("Час");
    final errorMessage = checkTimeNotEmpty(time);

    assert(() {
      bool isValidFormat = RegExp(r'\b\d{2}:\d{2}\b').hasMatch(time);
      if (!isValidFormat) {
        throw AssertionError("Неправильний формат часу.");
      }
      return true;
    }());

    if (errorMessage != null) {
      throw ArgumentError(errorMessage);
    }
  }

  void validateEmail(String? email) {
    assert(() {
      if (email != null && email.isEmpty) {
        throw AssertionError("Email не може бути порожнім.");
      }
      return true;
    }());
    if (email != null &&
        !RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
            .hasMatch(email)) {
      throw ArgumentError("Неправильний формат електронної пошти.");
    }
  }

  Function(String) checkNot(String name) => (String value) {
        if (value.isEmpty) {
          return "$name не може бути порожнім.";
        }
      };

  Function(double) checkPrice(String name) => (double value) {
        if (value < 0) {
          return "$name повинна бути додатня.";
        }
      };

  Function(Map<String, double>) checkNotJson(String name) =>
      (Map<String, double> value) {
        if (value.isEmpty) {
          return "$name не може бути порожнім.";
        }
      };
}

class Restaurant with ValidationMixin {
  String _name;
  final Menu _menu;
  String _address;
  String? _email;
  String _openFrom;
  String _openTo;

  Restaurant(this._name, this._menu, this._address, this._email, this._openFrom,
      this._openTo) {
    validateName(_name);
    validateAddress(_address);
    validateEmail(_email);
    validateTime(_openFrom);
    validateTime(_openTo);
  }

  factory Restaurant.withMenu(
      String name, Map<String, double> menuItems, String address,
      {String? email, String openFrom = "08:00", String openTo = "20:00"}) {
    final menu = Menu.fromItems(menuItems);
    return Restaurant(name, menu, address, email, openFrom, openTo);
  }

  String get name => _name;
  set name(String name) {
    validateName(name);
    _name = name;
  }

  Map<String, double> get displayMenu => _menu.menu;

  String get nameRestaurant => _name;

  String get addressRestaurant => _address;

  String get emailRestaurant => _email ?? "Немає вказаного email";

  String get openFromRestaurant => _openFrom;

  String get openToRestaurant => _openTo;
}

class Menu with ValidationMixin {
  final Map<String, double> _menuItems = {};

  Menu();

  factory Menu.fromItems(Map<String, double> items) {
    final menu = Menu();
    menu.menuItems = items;
    return menu;
  }

  void set menuItems(Map<String, double> items) {
    final checkNotEmpty = checkNotJson("Меню");
    final errorMessage = checkNotEmpty(items);

    if (errorMessage != null) {
      throw ArgumentError(errorMessage);
    }

    items.forEach((item, price) {
      final checkPositivePrice = checkPrice("Ціна елементу '$item'");
      final priceErrorMessage = checkPositivePrice(price);
      assert(priceErrorMessage != null,
          "Повиннен бути не порожнім рядок з помилкою");
      if (priceErrorMessage != null) {
        throw ArgumentError(priceErrorMessage);
      }
    });

    _menuItems.clear();
    _menuItems.addAll(items);
  }

  Map<String, double> get menu => Map<String, double>.from(_menuItems);
}

void sortRestaurantsByName(List<Restaurant> restaurants) {
  Set<Restaurant> uniqueRestaurants = restaurants.toSet();
  List<Restaurant> sortedRestaurants = uniqueRestaurants.toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  restaurants.clear();
  restaurants.addAll(sortedRestaurants);
}

void main() {
  try {
    List<Restaurant> restaurantList =
        stores.map((store) => store['restaurant'] as Restaurant).toList();

    sortRestaurantsByName(restaurantList);

    restaurantList.forEach((restaurant) {
      print("**${restaurant.nameRestaurant}**");
      print("Меню".padRight(16) + "${restaurant.displayMenu}");
      print("Адреса".padRight(16) + "${restaurant.addressRestaurant}");
      print("Email".padRight(16) + "${restaurant.emailRestaurant}");
      print("Відкритий з".padRight(16) + "{restaurant.openFromRestaurant}");
      print("Зачиняється в".padRight(16) + "${restaurant.openToRestaurant} \n");
    });
  } catch (e) {
    print("Помилка: $e");
  }
}
