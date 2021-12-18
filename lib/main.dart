import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:referenda/referenda.dart';

void main() async {
  await initializeDateFormatting("zh_TW");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2021 公投即時票數顯示',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          fontFamily: 'font'),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _lastUpdate;
  StateSetter? setLastUpdateState;

  Future<List<ReferendaItem>?> getReferenda() async {
    List<ReferendaItem> list = [];
    Uri uri =
        Uri.parse("https://www.cec.gov.tw/pc/zh_TW/00/00000000000000000.html");
    Response response = await get(uri);

    dom.Document document = HtmlParser(response.body).parse();
    List<dom.Element> trT = document.getElementsByClassName("trT");

    // 第17案
    dom.Element referenda17 = trT[0];
    List<dom.Element> children = referenda17.children;
    int agreeVotes = int.parse(children[0].text);
    int disagreeVotes = int.parse(children[1].text);

    list.add(ReferendaItem(
        title: "第17案：您是否同意核四啟封商轉發電？",
        agreeVotes: agreeVotes,
        disagreeVotes: disagreeVotes));

    setLastUpdateState?.call(() {
      _lastUpdate = DateTime.now();
    });

    return list;
  }

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = const TextStyle(fontSize: 40, color: Colors.blue);
    TextStyle subtitleStyle = const TextStyle(fontSize: 20);

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "2021 公投即時票數顯示",
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder<List<ReferendaItem>?>(
            future: getReferenda(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          controller: ScrollController(),
                          itemBuilder: (context, index) {
                            ReferendaItem item = snapshot.data![index];
                            return Column(
                              children: [
                                Text(
                                  item.title,
                                  style: titleStyle,
                                ),
                                Text("同意票數：${item.agreeVotes}",
                                    style: subtitleStyle),
                                Text("不同意票數：${item.disagreeVotes}",
                                    style: subtitleStyle),
                              ],
                            );
                          }),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        persistentFooterButtons: [
          StatefulBuilder(
            builder: (BuildContext context, setState) {
              setLastUpdateState = setState;

              return _lastUpdate != null
                  ? Center(
                      child: Text(
                          "資料最後更新日期： ${DateFormat.yMd('zh_TW').add_jms().format(_lastUpdate!)} (每過一分鐘將自動更新)"))
                  : const SizedBox.shrink();
            },
          ),
        ]);
  }
}
