import 'package:flutter/material.dart';

class MHContext extends InheritedWidget {
  final Function(double price, int timeMs) onMHChange;

  MHContext({
    Key key,
    @required Widget child,
    @required this.onMHChange,
  }) : super(key: key, child: child);

  static MHContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MHContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(MHContext oldWidget) {
    return onMHChange != oldWidget.onMHChange;
  }
}
