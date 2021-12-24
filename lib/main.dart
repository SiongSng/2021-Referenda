import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:referenda/data.dart';
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
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
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
    String sourceData;

    // Uri uri = Uri.parse(kIsWeb
    //     ? "https://rear-end.a102009102009.repl.co/2021-Referenda"
    //     : "https://www.cec.gov.tw/pc/zh_TW/00/00000000000000000.html");

    // Response response = await get(uri, headers: {});
    // sourceData = response.body;

    /// 由於公投已經結束，因此資料將不再從網路讀取
    sourceData = referendaData;
    dom.Document document = HtmlParser(sourceData).parse();
    List<dom.Element> trT = [];
    List<dom.Element> _ = document.getElementsByClassName("trT");
    for (dom.Element element in _) {
      int i = _.indexOf(element);
      bool _bool = i % 2 == 0;
      if (_bool) {
        trT.add(element);
      }
    }
    List<String> titles = [
      "第17案：重啟核四",
      "第18案：反萊豬進口",
      "第19案：公投綁大選",
      "第20案：真愛藻礁"
    ];

    List<String> descriptionList = [
      "您是否同意核四啟封商轉發電？",
      "你是否同意政府應全面禁止進口含有萊克多巴胺之乙型受體素豬隻之肉品、內臟及其相關產製品？",
      "你是否同意公民投票案公告成立後半年內，若該期間內遇有全國性選舉時，\n在符合公民投票法規定之情形下，公民投票應與該選舉同日舉行？",
      "您是否同意中油第三天然氣接收站遷離桃園大潭藻礁海岸及海域？\n(即北起觀音溪出海口，南至新屋溪出海口之海岸，及由上述海岸最低潮線往外平行延伸五公里之海域)"
    ];

    List<String> images = [
      "https://pgw.udn.com.tw/gw/photo.php?u=https://uc.udn.com.tw/photo/2021/03/15/98/11879022.jpg&x=0&y=0&sw=0&sh=0&sl=W&fw=800&exp=3600",
      "https://doqvf81n9htmm.cloudfront.net/data/crop_article/122782/shutterstock_1676775730.jpg_1140x855.jpg",
      "https://www.cna.com.tw/project/20211122-referendum/img/og_no19_1200x630.jpg",
      "https://live.staticflickr.com/65535/51154906011_f9c53e5d85_b.jpg"
    ];

    List<String> pollingPlace = document
        .getElementsByClassName("trFooterT")
        .map((e) => e.text)
        .toList();

    for (dom.Element tr in trT) {
      int index = trT.indexOf(tr);
      if (index >= 4) {
        break;
      }

      dom.Element referenda = trT[index];
      List<dom.Element> children = referenda.children;
      int agreeVotes =
          int.parse(children[0].text.toString().replaceAll(",", ""));
      int disagreeVotes =
          int.parse(children[1].text.toString().replaceAll(",", ""));
      int allVotes = agreeVotes + disagreeVotes;

      list.add(ReferendaItem(
          title: titles[index],
          description: descriptionList[index],
          image: images[index],
          agreeVotes: agreeVotes,
          disagreeVotes: disagreeVotes,
          totalVotes: allVotes,
          pollingPlace: pollingPlace[index]));
    }

    setLastUpdateState?.call(() {
      _lastUpdate = DateTime.now();
    });

    return list;
  }

  @override
  void initState() {
    super.initState();

    /// 由於公投已經結束，因此不需要自動更新票數
    // Timer.periodic(const Duration(seconds: 30), (timer) {
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
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
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    controller: ScrollController(),
                    itemBuilder: (context, index) {
                      ReferendaItem item = snapshot.data![index];
                      String agreeVotes = NumberFormat.compact(locale: "zh_TW")
                          .format(item.agreeVotes);
                      String disagreeVotes =
                          NumberFormat.compact(locale: "zh_TW")
                              .format(item.disagreeVotes);

                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          RowScrollView(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 500,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.network(item.image)),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      item.title,
                                      style: titleStyle,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      item.description,
                                      textAlign: TextAlign.center,
                                      style: subtitleStyle,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.thumb_up,
                                            color: Colors.green),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            "$agreeVotes (${item.agreeVotesPercentage}%)",
                                            style: subtitleStyle)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.thumb_down,
                                            color: Colors.red),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            "$disagreeVotes (${item.disagreeVotesPercentage}%)",
                                            style: subtitleStyle)
                                      ],
                                    ),
                                    Text(
                                        "有效票數：${NumberFormat.compact(locale: "zh_TW").format(item.totalVotes)}",
                                        style: subtitleStyle),
                                    Text(
                                        "開票完成率：${((item.donePollingPlaces / item.totalPollingPlaces) * 100).toStringAsFixed(2)}%",
                                        style: subtitleStyle)
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider()
                        ],
                      );
                    });
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
                      "資料最後更新日期： ${DateFormat.yMd('zh_TW').add_jms().format(_lastUpdate!)} (由於公投已結束，此資料將不再自動更新)\n資料來源：中華民國中央選舉委員會",
                      textAlign: TextAlign.center,
                    ))
                  : const SizedBox.shrink();
            },
          ),
        ]);
  }
}

// ignore: must_be_immutable
class RowScrollView extends StatelessWidget {
  late ScrollController _controller;
  bool center;
  Row child;

  RowScrollView({
    Key? key,
    ScrollController? controller,
    this.center = true,
    required this.child,
  }) : super(key: key) {
    _controller = controller ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Scrollbar(
            controller: _controller,
            child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                child: child)));
  }
}
