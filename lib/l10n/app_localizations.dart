import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
    Locale('pt')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Viora'**
  String get appTitle;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Viora'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In en, this message translates to:
  /// **'Mission system to transform your journey'**
  String get onboardingPage1Description;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Custom Missions'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Description.
  ///
  /// In en, this message translates to:
  /// **'Unique challenges for your growth'**
  String get onboardingPage2Description;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In en, this message translates to:
  /// **'Visualize your evolution in real time'**
  String get onboardingPage3Description;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start'**
  String get startButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'General Preferences'**
  String get generalPreferencesTitle;

  /// No description provided for @notificationsSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSettingTitle;

  /// No description provided for @notificationsSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts and updates'**
  String get notificationsSettingSubtitle;

  /// No description provided for @darkModeSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeSettingTitle;

  /// No description provided for @darkModeSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle between light and dark theme'**
  String get darkModeSettingSubtitle;

  /// No description provided for @accessibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilityTitle;

  /// No description provided for @fontSizeSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSizeSettingTitle;

  /// No description provided for @fontSizeSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust the text size'**
  String get fontSizeSettingSubtitle;

  /// No description provided for @languageSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// No description provided for @languageSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the application language'**
  String get languageSettingSubtitle;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @profileSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSettingTitle;

  /// No description provided for @profileSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal information'**
  String get profileSettingSubtitle;

  /// No description provided for @privacySettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySettingTitle;

  /// No description provided for @privacySettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure your privacy preferences'**
  String get privacySettingSubtitle;

  /// No description provided for @logoutSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutSettingTitle;

  /// No description provided for @logoutSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get logoutSettingSubtitle;

  /// No description provided for @mainScreenStatusTab.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get mainScreenStatusTab;

  /// No description provided for @mainScreenMissionsTab.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get mainScreenMissionsTab;

  /// No description provided for @mainScreenSettingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get mainScreenSettingsTab;

  /// No description provided for @statusScreenWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Viora'**
  String get statusScreenWelcomeTitle;

  /// No description provided for @statusScreenWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get ready for an epic space journey!'**
  String get statusScreenWelcomeSubtitle;

  /// No description provided for @playButton.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get playButton;

  /// No description provided for @characterStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Character Status'**
  String get characterStatusTitle;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// No description provided for @experienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experienceLabel;

  /// No description provided for @missionsCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Missions Completed'**
  String get missionsCompletedLabel;

  /// No description provided for @maxScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Score'**
  String get maxScoreLabel;

  /// No description provided for @missionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get missionsTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get filterInProgress;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @missionCardTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get missionCardTitlePrefix;

  /// No description provided for @missionCardDescriptionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Description of mission'**
  String get missionCardDescriptionPrefix;

  /// No description provided for @missionCardXP.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get missionCardXP;

  /// No description provided for @missionCardViewDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get missionCardViewDetailsButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Viora'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginRegisterButton;

  /// No description provided for @loginForgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPasswordButton;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginPasswordLength;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get loginError;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get registerNameLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get registerLoginButton;

  /// No description provided for @registerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get registerNameRequired;

  /// No description provided for @registerNameLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get registerNameLength;

  /// No description provided for @registerEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get registerEmailRequired;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get registerEmailInvalid;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get registerPasswordRequired;

  /// No description provided for @registerPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get registerPasswordLength;

  /// No description provided for @registerConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get registerConfirmPasswordRequired;

  /// No description provided for @registerPasswordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get registerPasswordsDontMatch;

  /// No description provided for @registerError.
  ///
  /// In en, this message translates to:
  /// **'Error creating account. Please try again.'**
  String get registerError;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive password reset instructions'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get forgotPasswordButton;

  /// No description provided for @forgotPasswordBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackButton;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get forgotPasswordEmailInvalid;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recovery email sent!'**
  String get forgotPasswordSuccess;

  /// No description provided for @forgotPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Error sending recovery email'**
  String get forgotPasswordError;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you instructions to reset your password.'**
  String get forgotPasswordDescription;

  /// No description provided for @profileChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get profileChangeAvatar;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveButton;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdateSuccess;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get profileNameRequired;

  /// No description provided for @profileNameLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get profileNameLength;

  /// No description provided for @profileEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get profileEmailRequired;

  /// No description provided for @profileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get profileEmailInvalid;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get profileUpdateError;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below'**
  String get resetPasswordDescription;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get resetPasswordError;

  /// No description provided for @resetPasswordSamePassword.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get resetPasswordSamePassword;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
