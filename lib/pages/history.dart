import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll/infinite_scroll.dart';
import 'package:kamus_investasi/databases/dictionaries/dictionary_repository.dart';
import 'package:kamus_investasi/databases/histories/history_repository.dart';
import 'package:kamus_investasi/models/dictionary_model.dart';
import 'package:kamus_investasi/pages/dictionary_detail.dart';
import 'package:kamus_investasi/utils/date_instance.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryRepository _historyRepo = HistoryRepository();

  int limit = 10;
  int pageList = 0;

  Future<List<DictionaryByDate>> getNextPageData(int page) async {
    List<DictionaryByDate>? data =
        await _historyRepo.all(limit: limit, page: page);
    return data;
  }

  List<DictionaryByDate> data = [];
  bool everyThingLoaded = false;
  bool isEmptyDictionary = false;
  bool isLastPage = false;

  void resetBool() {
    setState(() {
      pageList = 0;
      isEmptyDictionary = false;
      isLastPage = false;
      everyThingLoaded = false;
      data = [];
    });
  }

  Future<void> loadInitialData() async {
    data = await getNextPageData(pageList);
    if (data.isEmpty) {
      isEmptyDictionary = true;
    }

    if (data.length >= 1 && data.length < limit) {
      isLastPage = true;
    }
    setState(() {});
  }

  Future deleteAllHistory() async {
    await _historyRepo.deleteAll();
    resetBool();
    loadInitialData();
  }

  Future delete(int id, String date) async {
    await _historyRepo.delete(id, date);
    resetBool();
    loadInitialData();
  }

  Future<void> _refresh() async {
    resetBool();
    loadInitialData();
  }

  @override
  void initState() {
    loadInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat'),
        backgroundColor: Color.fromRGBO(14, 17, 17, 1),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                _deleteAllDialog();
              },
              icon: Icon(Iconsax.trash))
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            leading: Icon(
              Iconsax.info_circle,
              color: Colors.grey.shade800,
            ),
            title: Text(
              'Kamus yang Terakhir Kamu Lihat',
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            ),
            centerTitle: true,
            elevation: 0.5,
            backgroundColor: Colors.white,
          ),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: Colors.white,
              color: Color.fromRGBO(14, 17, 17, 1),
              displacement: 20,
              onRefresh: () => _refresh(),
              child: !isEmptyDictionary
                  ? InfiniteScrollList(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 10),
                      shrinkWrap: true,
                      loadingWidget: !isLastPage
                          ? Center(
                              child: Container(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                      color: Color.fromRGBO(14, 17, 17, 1))),
                            )
                          : Container(),
                      onLoadingStart: (page) async {
                        pageList++;
                        List<DictionaryByDate> newData =
                            await getNextPageData(pageList);
                        setState(() {
                          data += newData;
                          if (newData.isEmpty) {
                            everyThingLoaded = true;
                            isLastPage = true;
                          }
                        });
                      },
                      everythingLoaded: everyThingLoaded,
                      children: data
                          .map((item) => Container(
                                width: size.width,
                                margin: EdgeInsets.only(
                                    left: 15, right: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text(
                                        DateInstance.id(item.date ?? ''),
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          for (DictionaryModel row
                                              in item.listDictionaries ?? [])
                                            Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 5),
                                              child: ListTile(
                                                onTap: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (builder) {
                                                    return DictionaryDetailScreen(
                                                      id: row.id,
                                                      isSetHistory: false,
                                                    );
                                                  }));
                                                },
                                                contentPadding: EdgeInsets.zero,
                                                title: Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Text(
                                                    row.title ?? '',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                subtitle: Text(
                                                    row.fullTitle != 'null'
                                                        ? row.fullTitle!
                                                        : row.description!,
                                                    maxLines: 2,
                                                    style:
                                                        TextStyle(height: 1.5),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                trailing: GestureDetector(
                                                  onTap: () async {
                                                    await delete(
                                                        row.id!, item.date!);
                                                  },
                                                  child: Icon(
                                                    Iconsax.close_circle,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ))
                          .toList())
                  : Center(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: size.width * 0.43,
                            child: Image.asset('assets/images/history.png')),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Upps, maaf!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text('Riwayat masih kosong.',
                            style: TextStyle(color: Colors.grey.shade400))
                      ],
                    )),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Apakah kamu yakin ingin menghapus semua history?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ya, Hapus'),
              onPressed: () async {
                await deleteAllHistory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
