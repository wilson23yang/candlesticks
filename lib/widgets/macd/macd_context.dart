import 'package:flutter/material.dart';

class MACDContext extends InheritedWidget {
  final Function(int index,double dea,double dif,double macd) onMacdChange;

  MACDContext({
    Key key,
    @required Widget child,
    @required this.onMacdChange,
  }) : super(key: key, child: child);

  static MACDContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MACDContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(MACDContext oldWidget) {
    return onMacdChange != oldWidget.onMacdChange;
  }
}
