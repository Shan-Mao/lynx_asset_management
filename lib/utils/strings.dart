import '../lang/en.dart';
import '../lang/zh.dart';

/// Lightweight i18n backed by per-language map files under [lang/].
///
/// Call [S.setLanguage] whenever the user changes locale, then rebuild
/// the widget tree (e.g. via `MaterialApp.locale`).
class S {
  S._();

  static String _lang = 'zh';
  static Map<String, String> _map = zhStrings;

  static void setLanguage(String lang) {
    if (_lang == lang) return;
    _lang = lang;
    _map = lang == 'zh' ? zhStrings : enStrings;
  }

  static String get currentLanguage => _lang;

  // -- helper ---------------------------------------------------------------
  static String t(String key, [Map<String, String>? args]) {
    var s = _map[key] ?? key;
    if (args != null) {
      for (final e in args.entries) {
        s = s.replaceAll('{${e.key}}', e.value);
      }
    }
    return s;
  }

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------
  static String get tabAssets => t('tab_assets');
  static String get tabProfile => t('tab_profile');

  static String get homeImport => t('home_import');
  static String get homeExport => t('home_export');
  static String get homeAddAsset => t('home_add_asset');
  static String get homeNoAssetsTitle => t('home_no_assets_title');
  static String get homeNoAssetsHint => t('home_no_assets_hint');
  static String get homeSummaryAssets => t('home_summary_assets');
  static String get homeSummaryValue => t('home_summary_value');
  static String get homeSummaryDaily => t('home_summary_daily');
  static String get homeExportEmpty => t('home_export_empty');
  static String get homeExportFailed => t('home_export_failed');
  static String get homeExportDialogTitle => t('home_export_dialog_title');
  static String homeExportedTo(String path) => '${t('home_exported_to')} $path';
  static String get homeImportReadError => t('home_import_read_error');
  static String homeImportCount(int count) => t('home_import_count', {'count': count.toString()});
  static String get homeImportParseError => t('home_import_parse_error');

  static String get formTitleAdd => t('form_title_add');
  static String get formTitleEdit => t('form_title_edit');
  static String get formNameLabel => t('form_name_label');
  static String get formNameHint => t('form_name_hint');
  static String get formNameRequired => t('form_name_required');
  static String get formPriceLabel => t('form_price_label');
  static String get formPriceRequired => t('form_price_required');
  static String get formPriceInvalid => t('form_price_invalid');
  static String get formAdditionalCost => t('form_additional_cost');
  static String get formPurchaseDate => t('form_purchase_date');
  static String get formExpiryDate => t('form_expiry_date');
  static String get formExpiryNotSet => t('form_expiry_not_set');
  static String get formCategoryLabel => t('form_category_label');
  static String get formCategoryHint => t('form_category_hint');
  static String get formTagsLabel => t('form_tags_label');
  static String get formAdditionalItemsLabel => t('form_additional_items_label');
  static String get formChipHint => t('form_chip_hint');
  static String get formExcludeTotal => t('form_exclude_total');
  static String get formExcludeTotalSub => t('form_exclude_total_sub');
  static String get formExcludeDaily => t('form_exclude_daily');
  static String get formExcludeDailySub => t('form_exclude_daily_sub');
  static String get formRetired => t('form_retired');
  static String get formRetiredSub => t('form_retired_sub');
  static String get formSold => t('form_sold');
  static String get formSoldSub => t('form_sold_sub');
  static String get formNotesLabel => t('form_notes_label');
  static String get formNotesHint => t('form_notes_hint');
  static String get formSave => t('form_save');
  static String get formAdd => t('form_add');

  static String get detailNotFound => t('detail_not_found');
  static String get detailEdit => t('detail_edit');
  static String get detailDelete => t('detail_delete');
  static String get detailDeleteTitle => t('detail_delete_title');
  static String detailDeleteConfirm(String name) => t('detail_delete_confirm', {'name': name});
  static String get detailCancel => t('detail_cancel');
  static String get detailDailyCost => t('detail_daily_cost');
  static String get detailPerDay => t('detail_per_day');
  static String get detailBasicInfo => t('detail_basic_info');
  static String get detailName => t('detail_name');
  static String get detailPrice => t('detail_price');
  static String get detailAdditionalCost => t('detail_additional_cost');
  static String get detailTotalCost => t('detail_total_cost');
  static String get detailPurchaseDate => t('detail_purchase_date');
  static String get detailDaysOwned => t('detail_days_owned');
  static String detailDays(int days) => t('detail_days', {'days': days.toString()});
  static String get detailStatus => t('detail_status');
  static String get detailStatusNormal => t('detail_status_normal');
  static String get detailStatusRetired => t('detail_status_retired');
  static String get detailStatusSold => t('detail_status_sold');
  static String get detailExcludedTotal => t('detail_excluded_total');
  static String get detailExcludedDaily => t('detail_excluded_daily');
  static String get detailClassification => t('detail_classification');
  static String get detailCategory => t('detail_category');
  static String get detailTags => t('detail_tags');
  static String get detailAdditionalItems => t('detail_additional_items');
  static String get detailNotes => t('detail_notes');

  static String get profileTitle => t('profile_title');
  static String get profileSettings => t('profile_settings');
  static String get profileAbout => t('profile_about');
  static String get profileThemeTooltip => t('profile_theme_tooltip');

  static String get settingsPersonalization => t('settings_personalization');
  static String get settingsExport => t('settings_export');
  static String get settingsImport => t('settings_import');
  static String get settingsTheme => t('settings_theme');
  static String get settingsLanguage => t('settings_language');
  static String get settingsLayout => t('settings_layout');
  static String get settingsHideRetired => t('settings_hide_retired');
  static String get settingsHideSold => t('settings_hide_sold');

  static String get layoutList => t('layout_list');
  static String get layoutGrid => t('layout_grid');
  static String get layoutAspect => t('layout_aspect');
  static String get layoutColumnsPortrait => t('layout_columns_portrait');
  static String get layoutColumnsLandscape => t('layout_columns_landscape');

  static String get personalizationDevice => t('personalization_device');
  static String get personalizationSaveFormat => t('personalization_save_format');
  static String get personalizationPreview => t('personalization_preview');
  static String get personalizationAndroid => t('personalization_android');
  static String get personalizationWeb => t('personalization_web');

  static String get saveFormatTitle => t('save_format_title');
  static String get saveFormatNaming => t('save_format_naming');
  static String get saveFormatNamingHint => t('save_format_naming_hint');
  static String get saveFormatNamingPreview => t('save_format_naming_preview');
  static String get saveFormatNamingPreviewHint => t('save_format_naming_preview_hint');
  static String get saveFormatInsertDate => t('save_format_insert_date');
  static String get saveFormatInsertUser => t('save_format_insert_user');
  static String get saveFormatDefaultUser => t('save_format_default_user');
  static String get saveFormatContentRules => t('save_format_content_rules');
  static String get saveFormatContentPreview => t('save_format_content_preview');
  static String get saveFormatEncoding => t('save_format_encoding');
  static String get saveFormatSeparator => t('save_format_separator');
  static String get saveFormatFields => t('save_format_fields');
  static String get saveFormatPreviewSample => t('save_format_preview_sample');

  static String fieldName(String key) => t('field_$key');

  static String get themeFollowSystem => t('theme_follow_system');
  static String get themeLight => t('theme_light');
  static String get themeDark => t('theme_dark');
  static String get themeAmoled => t('theme_amoled');
  static String get themeAmoledSub => t('theme_amoled_sub');
  static String get themeDynamicColor => t('theme_dynamic_color');
  static String get themeDynamicColorSub => t('theme_dynamic_color_sub');
  static String get themeSeedColor => t('theme_seed_color');
  static String get themeSave => t('theme_save');

  static String get seedPresets => t('seed_presets');

  static String get aboutDesc => t('about_desc');
  static String get aboutFeatureAsset => t('about_feature_asset');
  static String get aboutFeatureDaily => t('about_feature_daily');
  static String get aboutFeatureImportExport => t('about_feature_import_export');
  static String get aboutFeatureCrossPlatform => t('about_feature_cross_platform');
  static String get aboutFeatureDarkMode => t('about_feature_dark_mode');

  static String get cardSold => t('card_sold');
  static String get cardRetired => t('card_retired');

  static String get timeToday => t('time_today');
  static String timeDaysAgo(int days) => t('time_days_ago', {'days': days.toString()});
  static String timeMonthsAgo(int months) => t('time_months_ago', {'months': months.toString()});
  static String timeYearsAgo(int years) => t('time_years_ago', {'years': years.toString()});
  static String timeYearsMonthsAgo(int years, int months) =>
      t('time_years_months_ago', {'years': years.toString(), 'months': months.toString()});
}
