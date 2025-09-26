import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'K-POP Call'**
  String get appTitle;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Artists tab label
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// Map tab label
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// My page tab label
  ///
  /// In en, this message translates to:
  /// **'My Page'**
  String get myPage;

  /// Popular artists section title
  ///
  /// In en, this message translates to:
  /// **'Popular Artists'**
  String get popularArtists;

  /// Coming soon concerts section title
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Concert map screen title
  ///
  /// In en, this message translates to:
  /// **'Concert Map'**
  String get concertMap;

  /// Artist search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search for artists'**
  String get searchArtists;

  /// Artist or concert search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search for artists or concerts'**
  String get searchArtistsOrConcerts;

  /// About artist section title
  ///
  /// In en, this message translates to:
  /// **'About Artist'**
  String get aboutArtist;

  /// Fans count label
  ///
  /// In en, this message translates to:
  /// **'Fans'**
  String get fans;

  /// Agency label
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agency;

  /// More text button
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Hide text button
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// Concert information section title
  ///
  /// In en, this message translates to:
  /// **'Concert Information'**
  String get concertInformation;

  /// Venue information section title
  ///
  /// In en, this message translates to:
  /// **'Venue Information'**
  String get venueInformation;

  /// Date and time section title
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// Ticket information section title
  ///
  /// In en, this message translates to:
  /// **'Ticket Information'**
  String get ticketInformation;

  /// Description section title
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// All concerts section title
  ///
  /// In en, this message translates to:
  /// **'All Concerts'**
  String get allConcerts;

  /// Login sign up button text
  ///
  /// In en, this message translates to:
  /// **'Login / Sign Up'**
  String get loginSignUp;

  /// Continue with Google button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Continue with Apple button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Email notifications setting
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// App settings section title
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Storage setting
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// Information section title
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// About app menu item
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Privacy policy menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of service menu item
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection.'**
  String get networkError;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'A temporary error occurred. Please try again later.'**
  String get serverError;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please restart the app.'**
  String get unknownError;

  /// No upcoming concerts message
  ///
  /// In en, this message translates to:
  /// **'No upcoming concerts'**
  String get noUpcomingConcerts;

  /// Artist not found message
  ///
  /// In en, this message translates to:
  /// **'Artist information not found'**
  String get artistNotFound;

  /// App info dialog title
  ///
  /// In en, this message translates to:
  /// **'About K-POP Call'**
  String get aboutKpopCall;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// App info description
  ///
  /// In en, this message translates to:
  /// **'K-POP Call is your ultimate destination for K-POP concert information and artist updates. Stay connected with your favorite artists and never miss a concert again.'**
  String get aboutDescription;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Popular artists feature
  ///
  /// In en, this message translates to:
  /// **'Popular Artists'**
  String get popularArtistsFeature;

  /// Concert information feature
  ///
  /// In en, this message translates to:
  /// **'Concert Information'**
  String get concertInformationFeature;

  /// Concert map feature
  ///
  /// In en, this message translates to:
  /// **'Concert Map'**
  String get concertMapFeature;

  /// Notifications feature
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsFeature;

  /// User profile feature
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfileFeature;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
