import 'dart:math';

import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:candlesticks/candlesticks.dart';

class DataSource {
  static final DataSource instance = new DataSource._internal();

  factory DataSource() {
    return instance;
  }

  ReplaySubject<CandleData> subject;

  var channel;

  DataSource._internal();

  Future<Stream<CandleData>> initTZB(int minute) async {
    if (subject != null) {
      subject.close();
      subject = null;
    }
    subject = ReplaySubject<CandleData>();
    var symbol = "eth_usdt";
    if (channel != null) {
      channel.sink.close();
      channel = null;
    }

    channel = IOWebSocketChannel.connect("wss://ws.tokenbinary.io/sub");
    /*
        channel.sink.add(
            '{"method":"pull_heart","data":{"time":"1541066934853"}}');
            */
    channel.sink.add(
        '{"method":"pull_gamble_user_market","data":{"market":"${symbol}","gamble":true}}');
    channel.sink.add(
        '{"method":"pull_gamble_kline_graph","data":{"market":"${symbol}","k_line_type":"${minute}","k_line_count":"500"}}');

    channel.stream.listen((request) {
      var msg = json.decode(utf8.decode(request));
      int now = DateTime.now().millisecond;
      channel.sink.add('{"method":"pull_heart","data":{"time":"${now}"}}');
      if (msg['method'] == 'push_gamble_kline_graph') {
        //print(msg['data']);
        List dataK = [];
        msg['data'].forEach((item) {
          var d = {};
          try {
            d['time'] = int.parse(item[0]);
            d['open'] = double.parse(item[1]);
            d['high'] = double.parse(item[2]);
            d['low'] = double.parse(item[3]);
            d['close'] = double.parse(item[4]);
            d['volume'] = double.parse(item[5]);
            d['virgin'] = item;
          } catch (e) {
            //print(e);
          }

          subject.sink.add(CandleData.fromArray(item));
        });
      }
    });
    return subject.stream;
  }

  Future<Stream<CandleData>> initRBTC(int minute) async {
    if (subject != null) {
      subject.close();
    }
    subject = ReplaySubject<CandleData>();

    var symbol = "del_pyc";

    channel = IOWebSocketChannel.connect(
        "wss://market-api.rbtc.io/sub");
    channel.sink.add(
        '{"method":"pull_heart","data":{"time":"1541066934853"}}');
    channel.sink.add(
        '{"method":"pull_user_market","data":{"market":"${symbol}"}}');
    channel.sink.add(
        '{"method":"pull_kline_graph","data":{"market":"${symbol}","k_line_type":"${minute}","k_line_count":"80"}}');

    channel.stream.listen((request) {
      var msg = json.decode(utf8.decode(request));
      if (msg['method'] == 'push_kline_graph') {
        //print(msg['data']);
        List dataK = [];
        msg['data'].forEach((item) {
          var d = {};
          try {
            d['time'] = int.parse(item[0]);
            d['open'] = double.parse(item[1]);
            d['high'] = double.parse(item[2]);
            d['low'] = double.parse(item[3]);
            d['close'] = double.parse(item[4]);
            d['volume'] = double.parse(item[5]);
            d['virgin'] = item;
          } catch (e) {
            //print(e);
          }

          dataK.add(d);
          if(dataK.length >= 2) {
//            print(dataK.last['time'] - dataK[dataK.length - 2]['time']);
          }
          subject.sink.add(CandleData.fromArray(item));
        });
//        kChartsKey.currentState.data = data;
//                print('pull_kline_graph');
//        kChartsKey.currentState.init();
//                channel.sink.close(5678, "raisin");
      }
    });
    return subject.stream;
  }


  Timer timer;
  Future<Stream<CandleData>> initRBTC2(int minute) async {
    if (subject != null) {
      subject.close();
    }
    subject = ReplaySubject<CandleData>();

    int lastTime = 0;
    List<dynamic> preItem;
    for (int i = 1; i <= 100; i++) {
      List<dynamic> item = <dynamic>[];
      try {
        int time = 1564028824000 + 60000 * i;
        lastTime = time;
        item.add(time);
        switch (i % 8) {
          case 0:
            item.add(20.0*i);//open
            item.add(22.0*i);//high
            item.add(18.0*i);//low
            item.add(21.0*i);//close
            break;
          case 1:
            item.add(21.0*i);
            item.add(24.0*i);
            item.add(20.3*i);
            item.add(22.0*i);
            break;
          case 2:
            item.add(22.5*i);
            item.add(23.0*i);
            item.add(22.0*i);
            item.add(23.0*i);
            break;
          case 3:
            item.add(23.0*i);
            item.add(23.0*i);
            item.add(19.0*i);
            item.add(19.0*i);
            break;
          case 4:
            item.add(19.0*i);
            item.add(19.9*i);
            item.add(17.0*i);
            item.add(18.0*i);
            break;
          case 5:
            item.add(18.0*i);
            item.add(19.9*i);
            item.add(15.0*i);
            item.add(17.0*i);
            break;
          case 6:
            item.add(17.0*i);
            item.add(17.9*i);
            item.add(15.0*i);
            item.add(16.0*i);
            break;
          case 7:
            item.add(16.0*i);
            item.add(20.9*i);
            item.add(15.0*i);
            item.add(20.0*i);
            break;
        }

        double volume = 50.0 * (Random().nextInt(9));
        item.add(volume);
        preItem = item;
        subject.sink.add(CandleData.fromArray2(item));
      } catch (e) {
        print(e);
      }
    }
    int count = 0;
    int currentItemTime = preItem[0];
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer){
      if(count % 10 == 0){
        currentItemTime = currentItemTime + 60000;
      }
      count++;

      List<dynamic> item = <dynamic>[];
      if(currentItemTime != preItem[0]){
        item.add(currentItemTime);
        double open = preItem[4];
        double close = open;
        double high = open;
        double low = open;
        double volume = 0;
        item.add(open);
        item.add(high);
        item.add(low);
        item.add(close);
        item.add(volume);
      } else {
        item.add(currentItemTime);
        double open = preItem[1];
        double close = open + (open * 0.1 * Random().nextDouble() - open * 0.05);
        double high = max(max(open, close), preItem[2]);
        double low = min(min(open,close),preItem[3]);
        double volume = preItem[5] + 10 * Random().nextDouble();
        item.add(open);
        item.add(high);
        item.add(low);
        item.add(double.parse(close.toStringAsFixed(4)));
        item.add(volume);
      }
      preItem = item;
      subject.sink.add(CandleData.fromArray2(item));
    });
    return subject.stream;
  }
  
  void stopTimer(){
    timer?.cancel();
  }

  Future<Stream<CandleData>> initRBTC3(int minute) async {
    if (subject != null) {
      subject.close();
    }
    subject = ReplaySubject<CandleData>();

    int i = 1;
    List<dynamic> item = <dynamic>[];

    item.add(1533052800000);//2018-08-01 00:00:00
    item.add(20.0*i);//open
    item.add(22.0*i);//high
    item.add(19.5*i);//low
    item.add(21.0*i);//close
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();


    item.add(1535731200000);//2018-09-01 00:00:00
    item.add(21.0*i);
    item.add(22.5*i);
    item.add(20.3*i);
    item.add(22.0*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();


    item.add(1538323200000);//2018-10-01 00:00:00
    item.add(22.5*i);
    item.add(23.3*i);
    item.add(22.0*i);
    item.add(23.0*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();


    item.add(1541001600000);//2018-11-01 00:00:00
    item.add(23.0*i);
    item.add(23.0*i);
    item.add(19.0*i);
    item.add(19.0*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();


    item.add(1543593600000);//2018-12-01 00:00:00
    item.add(19.0*i);
    item.add(19.9*i);
    item.add(17.0*i);
    item.add(18.0*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();

    item.add(1546272000000);//2019-01-01 00:00:00
    item.add(18.0*i);
    item.add(18.9*i);
    item.add(16.8*i);
    item.add(17.0*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();


    item.add(1548950400000);//2019-02-01 00:00:00
    item.add(17.0*i);
    item.add(17.9*i);
    item.add(15.9*i);
    item.add(16.0*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();

    item.add(1551369600000);//2019-03-01 00:00:00
    item.add(16.0*i);
    item.add(20.2*i);
    item.add(15.5*i);
    item.add(20.0*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();

    item.add(1554048000000);//2019-04-01 00:00:00
    item.add(20.0*i);
    item.add(21.0*i);
    item.add(18.0*i);
    item.add(19.0*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();

    item.add(1556640000000);//2019-05-01 00:00:00
    item.add(18.3*i);
    item.add(19.0*i);
    item.add(17.0*i);
    item.add(17.0*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();

    item.add(1559318400000);//2019-06-01 00:00:00
    item.add(17.0*i);
    item.add(17.8*i);
    item.add(16.9*i);
    item.add(16.9*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();

    item.add(1561910400000);//2019-07-01 00:00:00
    item.add(16.6*i);
    item.add(17.0*i);
    item.add(16.9*i);
    item.add(16.9*i);
    item.add(50.0 * (Random().nextInt(9)));
    subject.sink.add(CandleData.fromArray2(item));
    item.clear();

    return subject.stream;
  }
}
