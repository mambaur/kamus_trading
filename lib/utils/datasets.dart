import 'package:flutter/foundation.dart';
import 'package:kamus_investasi/databases/dictionaries/dictionary_repository.dart';
import 'package:kamus_investasi/utils/json_configuration.dart';

class DataSets {
  final DictionaryRepository _dictionaryRepo = DictionaryRepository();

  Future<bool> initDictionaries() async {
    int totalDictionary = await _dictionaryRepo.count();
    if (kDebugMode) print("Total dictionary = $totalDictionary");
    // print(dictionariesJson['data'].length);
    if (totalDictionary != 273) {
      await _dictionaryRepo.deleteAll();

      Map<String, dynamic> dictionariesJson =
          await JsonConfiguration.parseJsonFromAssets(
              'assets/datasets/dictionaries.json');
      for (var i = 0; i < dictionariesJson['data'].length; i++) {
        if (kDebugMode) {
          print("$i ${dictionariesJson['data'][i]['title']}");
        }
        await _dictionaryRepo.insert({
          'alphabet': dictionariesJson['data'][i]['alphabet'],
          'title': dictionariesJson['data'][i]['title'],
          'full_title': dictionariesJson['data'][i]['full_title'],
          'description': dictionariesJson['data'][i]['description'],
          'category': dictionariesJson['data'][i]['category'],
          'created_at': dictionariesJson['data'][i]['created_at'],
          'updated_at': dictionariesJson['data'][i]['updated_at'],
        });
      }
      return false;
    }
    return false;
  }
}
