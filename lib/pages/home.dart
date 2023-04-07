import 'package:flutter/material.dart';
import 'package:infinite_scroll/infinite_scroll.dart';
import 'package:kamus_investasi/databases/dictionaries/dictionary_repository.dart';
import 'package:kamus_investasi/models/dictionary_model.dart';
import 'package:kamus_investasi/pages/dictionary_alphabets.dart';
import 'package:kamus_investasi/pages/dictionary_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DictionaryRepository _dictionaryRepo = DictionaryRepository();
  final TextEditingController _searchController = TextEditingController();

  int limit = 10;
  int pageList = 0;

  Future<List<DictionaryByAlphabets>> getNextPageData(int page) async {
    List<DictionaryByAlphabets>? data = await _dictionaryRepo.all(
        limit: limit, page: page, q: _searchController.text);
    return data;
  }

  List<DictionaryByAlphabets> data = [];
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

  @override
  void initState() {
    loadInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Container(
        child: Stack(
          children: [
            !isEmptyDictionary
                ? InfiniteScrollList(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: (size.height * 0.2) + 50),
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
                      List<DictionaryByAlphabets> newData =
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
                    // children: [],
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
                                      item.alphabet ?? '',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(height: 10),
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
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: ListTile(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (builder) {
                                                  return DictionaryDetailScreen(
                                                    id: row.id,
                                                    isSetHistory: true,
                                                  );
                                                }));
                                              },
                                              contentPadding: EdgeInsets.zero,
                                              title: Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 5),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      TextStyle(height: 1.5)),
                                            ),
                                          ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (builder) {
                                              return DictionaryAlphabetsScreen(
                                                alphabet: item.alphabet,
                                              );
                                            }));
                                          },
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Text(
                                                'Selengkapnya...',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              )),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  )
                : Center(child: Text('Kata tidak ditemukan!')),
            Container(
              color: Color.fromRGBO(14, 17, 17, 1),
              width: size.width,
              height: size.height * 0.2,
              child: Center(
                child: Text(
                  'Kamus Trading',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: (size.height * 0.2) - 25, left: 15, right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: size.width,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ]),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade700),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(color: Colors.grey.shade700),
                        onChanged: (value) async {
                          resetBool();
                          await loadInitialData();
                        },
                        onSubmitted: (value) async {
                          resetBool();
                          await loadInitialData();
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            hintText: 'Cari Keyword Investasimu..'),
                      ),
                    ),
                    GestureDetector(
                        onTap: () async {
                          _searchController.text = '';
                          resetBool();
                          await loadInitialData();
                        },
                        child: Icon(Icons.close, color: Colors.grey.shade700)),
                  ]),
            ),

            // Icon(
            //   Iconsax.box_search,
            //   color: Colors.red,
            //   size: 100,
            // )
          ],
        ),
      ),
    );
  }
}
