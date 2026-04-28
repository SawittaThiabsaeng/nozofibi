import 'package:hive/hive.dart';
import 'app_local_db.dart';

class ConsentStorage {
  static const String _termsKey = 'consent_terms_accepted';
  static const String _promotionKey = 'consent_promotion_accepted';

  static bool hasAcceptedTerms() {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    return box.get(_termsKey) == 'true';
  }

  static Future<void> saveConsent({
    required bool acceptedTerms,
    required bool acceptedPromotion,
  }) async {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    await box.put(_termsKey, acceptedTerms.toString());
    await box.put(_promotionKey, acceptedPromotion.toString());
  }

  static bool hasAcceptedPromotion() {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    return box.get(_promotionKey) == 'true';
  }
}