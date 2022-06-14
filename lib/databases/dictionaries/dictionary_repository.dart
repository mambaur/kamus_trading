import 'package:kamus_investasi/databases/database_instance.dart';
import 'package:kamus_investasi/models/dictionary_model.dart';
import 'package:sqflite/sqflite.dart';

class DictionaryRepository {
  // reference to our single class that manages the database
  final dbInstance = DatabaseInstance();

  Future<List<DictionaryModel>> all({int? limit, int? page}) async {
    // Setup pagination
    limit ??= 10;
    int offset = (limit * (page ?? 1)) - limit;

    Database db = await dbInstance.database;
    final data = await db.rawQuery(
        'SELECT * FROM ${dbInstance.dictionaryTable} ORDER BY ${dbInstance.dictionaryTable}.${dbInstance.dictionaryTitle} DESC LIMIT $limit OFFSET $offset',
        []);

    List<DictionaryModel> listDictionaries = [];
    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        DictionaryModel dictionaryModel = DictionaryModel(
          id: int.parse(data[i]['id'].toString()),
          title: data[i]['title'].toString(),
          fullTitle: data[i]['full_title'].toString(),
          description: data[i]['description'].toString(),
          alphabet: data[i]['alphabet'].toString(),
          category: data[i]['category'].toString(),
          createdAt: data[i]['created_at'].toString(),
          updatedAt: data[i]['updated_at'].toString(),
        );
        listDictionaries.add(dictionaryModel);
      }
    }

    return listDictionaries;
  }
}