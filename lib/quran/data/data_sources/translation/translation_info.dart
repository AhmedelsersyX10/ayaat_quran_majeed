// ignore_for_file: constant_identifier_names

enum Translation {
  baghawy,
  e3rab,
  katheer,
  qortoby,
  sa3dy,
  tabary,
  waseet,
  ar_ma3any,
  ar_muyassar,
  bn_bengali,
  bs_korkut,
  de_bubenheim,
  en_sahih,
  es_navio,
  fr_hamidullah,
  ha_gumi,
  id_indonesian,
  indonesian,
  it_piccardo,
  ku_asan,
  ml_abdulhameed,
  ms_basmeih,
  nl_siregar,
  pr_tagi,
  pt_elhayek,
  ru_kuliev,
  russian,
  so_abduh,
  sq_nahi,
  sv_bernstrom,
  sw_barwani,
  ta_tamil,
  th_thai,
  tr_diyanet,
  ur_jalandhry,
  uz_sodik,
  zh_jian,
  tafheem,
  tanweer,
}

class TranslationData {
  final String typeText;
  final String typeTextInRelatedLanguage;
  final String typeInNativeLanguage;
  final String url;

  final Translation typeAsEnumValue;

  TranslationData({
    required this.typeText,
    required this.typeTextInRelatedLanguage,
    required this.url,
    required this.typeInNativeLanguage,
    required this.typeAsEnumValue,
  });
}
