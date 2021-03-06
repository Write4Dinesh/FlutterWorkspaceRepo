import 'package:flutfire/data/acc_data_store.dart';
import 'package:flutfire/utils/acc_app_constants.dart' as AppConstants;

class AccBusinessCardDataHelper {
  static loadBusinessCardByKey(String key) async {
    List<String> keyList = await loadAllKeys();
    if (keyList != null && keyList.isNotEmpty) {
      if (keyList.contains(key)) {
        String card = await AccDataStore.instance.loadStringByKey(key);
        return card;
      }
    }
    return null;
  }

  static saveBusinessCard(String cardKey, List<String> cardFields) async {
    // merge all the fields into a single line.
    if (cardKey.isNotEmpty && cardFields.isNotEmpty) {
      String bCard = '';
      for (int i = 0; i < cardFields.length; i++) {
        bCard = bCard + AppConstants.CARD_FIELD_SEPARATOR + cardFields[i];
      }

      //save business card
      bool bcSaveSuccessful =
          await AccDataStore.instance.saveStringByKey(cardKey, bCard);

      //Save the cardKey separately
      if (bcSaveSuccessful) {
        //fetch key list from store
        String keyList = await AccDataStore.instance
            .loadStringByKey(AppConstants.LIST_OF_KEYS);

        //append the new 'cardKey' to the end of the list.
        if (keyList == null || keyList.isEmpty) {
          keyList = cardKey;
        } else if (!keyList.contains(cardKey)) {
          keyList = keyList + AppConstants.KeySeparator + cardKey;
        }

        //store updated key list
        bool keyListUpdated = await AccDataStore.instance
            .saveStringByKey(AppConstants.LIST_OF_KEYS, keyList);
        return keyListUpdated;
      }
    }
    return false;
  }

  static loadAllKeys() async {
    String keyList =
        await AccDataStore.instance.loadStringByKey(AppConstants.LIST_OF_KEYS);
    List<String> keys = keyList.split(AppConstants.KeySeparator);
    if(keyList!=null && keyList.isNotEmpty){
      keyList.trim();
    }
    if(keys!=null && keys.contains("")){
      keys.remove("");
    }
    return keys;
  }

  static getKeysStringFromList(List<String> keyList) {
    String keyLine = "";
    for (int i = 0; i < keyList.length; i++) {
      keyLine = i == 0
          ? keyList[i]
          : keyLine + AppConstants.KeySeparator + keyList[i];
    }
    return keyLine;
  }

  static removeBusinessCardByKey(String key) async {
    if (key.isEmpty) {
      return false;
    }
    List<String> keys = await loadAllKeys();
    if (keys.isNotEmpty && keys.contains(key)) {
      // Remove the business card first
      bool successful = await AccDataStore.instance.removeStringByKey(key);
      if (successful) {
        while (keys.contains(key))
          keys.remove(key); //remove all occurrences of this key
        // Remove the keys next
        bool removed = await AccDataStore.instance.saveStringByKey(
            AppConstants.LIST_OF_KEYS, getKeysStringFromList(keys));
        return removed;
      }
    }
    return false;
  }
}
