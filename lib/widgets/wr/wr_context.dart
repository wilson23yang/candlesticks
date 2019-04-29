import 'package:flutter/material.dart';

class WrContext extends InheritedWidget {
  final Function(int period,double wr) onWrChange;

  WrContext({
    Key key,
    @required Widget child,
    @required this.onWrChange,
  }) : super(key: key, child: child);

  static WrContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(WrContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(WrContext oldWidget) {
    return onWrChange != oldWidget.onWrChange;
  }
}
