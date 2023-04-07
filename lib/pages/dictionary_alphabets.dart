import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kamus_investasi/databases/dictionaries/dictionary_repository.dart';
import 'package:kamus_investasi/models/dictionary_model.dart';
import 'package:kamus_investasi/pages/dictionary_detail.dart';

class DictionaryAlphabetsScreen extends StatefulWidget {
  final String? alphabet;
  const DictionaryAlphabetsScreen({Key? key, this.alphabet}) : super(key: key);

  @override
  State<DictionaryAlphabetsScreen> createState() =>
      _DictionaryAlphabetsScreenState();
}

class _DictionaryAlphabetsScreenState extends State<DictionaryAlphabetsScreen> {
  final DictionaryRepository _dictionaryRepo = DictionaryRepository();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alphabet ?? ''),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(14, 17, 17, 1),
      ),
      body: FutureBuilder<List<DictionaryModel>>(
        future: _dictionaryRepo.getAllDictionaryAlphabets(
            alphabet: widget.alphabet ?? ''),
        builder: (BuildContext context,
            AsyncSnapshot<List<DictionaryModel>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
              for (DictionaryModel item in snapshot.data ?? [])
                Container(
                  width: size.width,
                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (builder) {
                                  return DictionaryDetailScreen(
                                    id: item.id,
                                    isSetHistory: true,
                                  );
                                }));
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Iconsax.text),
                              title: Text(
                                item.title ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                ),
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Mohon Tunggu...'),
              )
            ];
          }
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }
}
