import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApplicationProvider {
  static ApplicationProvider? _instance;
  static ApplicationProvider get instance {
    _instance ??= ApplicationProvider._init();
    return _instance!;
  }

  ApplicationProvider._init();

  List<Provider> singleItems = [];
  List<Provider> dependItems = [];
  List<Provider> uiChangesItems = [];
}
// import 'package:provider/single_child_widget.dart';

// class ApplicationProvider {
//   static ApplicationProvider? _instance;
//   static ApplicationProvider get instance {
//     _instance ??= ApplicationProvider._init();
//     return _instance!;
//   }

//   ApplicationProvider._init();

//   List<SingleChildWidget> singleItems = [];
//   List<SingleChildWidget> dependItems = [
   
//   ];
//   List<SingleChildWidget> uiChangesItems = [];
// }
