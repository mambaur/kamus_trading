import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll/infinite_scroll.dart';
import 'package:kamus_investasi/databases/bookmarks/bookmark_repository.dart';
import 'package:kamus_investasi/databases/dictionaries/dictionary_repository.dart';
import 'package:kamus_investasi/models/dictionary_model.dart';
import 'package:kamus_investasi/pages/dictionary_detail.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final BookmarkRepository _bookmarkRepo = BookmarkRepository();
  final DictionaryRepository _dictionaryRepo = DictionaryRepository();

  int limit = 10;
  int pageList = 0;

  Future<List<DictionaryModel>> getNextPageData(int page) async {
    List<DictionaryModel>? data =
        await _bookmarkRepo.all(limit: limit, page: page);
    return data;
  }

  List<DictionaryModel> data = [];
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

  Future deleteAllBookmark() async {
    await _bookmarkRepo.deleteAll();
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
          title: Text('Bookmark'),
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color.fromRGBO(14, 17, 17, 1),
          actions: [
            IconButton(
                onPressed: () {
                  _deleteAllDialog();
                },
                icon: Icon(Iconsax.star_15))
          ],
        ),
        backgroundColor: Colors.grey.shade100,
        body: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Color.fromRGBO(14, 17, 17, 1),
          displacement: 20,
          onRefresh: () => _refresh(),
          child: !isEmptyDictionary
              ? InfiniteScrollList(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 15),
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
                    List<DictionaryModel> newData =
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (builder) {
                                            return DictionaryDetailScreen(
                                              id: item.id,
                                              isSetHistory: true,
                                            );
                                          }));
                                        },
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(Iconsax.star),
                                        title: Text(
                                          item.title ?? '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            item.fullTitle != 'null'
                                                ? item.fullTitle!
                                                : item.description!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(height: 1.5)),
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
                        width: size.width * 0.5,
                        child: Image.asset('assets/images/bookmark.png')),
                    SizedBox(
                      height: 15,
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
                    Text('Bookmark masih kosong.',
                        style: TextStyle(color: Colors.grey.shade400))
                  ],
                )),
        ));
  }

  Future<void> _deleteAllDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Text('Apakah kamu yakin ingin menghapus semua bookmark?'),
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
                await deleteAllBookmark();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
