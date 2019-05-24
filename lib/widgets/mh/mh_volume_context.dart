import 'package:flutter/material.dart';

class MhVolumeContext extends InheritedWidget {
  final Function(int index,double vol) onVolChange;

  MhVolumeContext({
    Key key,
    @required Widget child,
    @required this.onVolChange,
  }) : super(key: key, child: child);

  static MhVolumeContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MhVolumeContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(MhVolumeContext oldWidget) {
    return onVolChange != oldWidget.onVolChange;
  }
}
