import 'package:flutter/material.dart';

/// Hand-written localizations — no `intl`/ARB codegen step, so this
/// compiles and works immediately without running `flutter gen-l10n`.
///
/// Covers every screen in the app (auth, home, routing, notifications,
/// profile, the admin placeholder, and the shell's bottom nav). Three
/// deliberate exceptions, each noted at its own call site too:
///  - `SeasonMode.label` (Summer/Winter/Auto) stays English — too many
///    call sites across features to safely convert in this pass.
///  - Engine/API-computed strings (`RouteResult.tip`, `.windLabel`,
///    `GuidanceInstruction.text`, `WeatherSnapshot.condition`) stay as
///    the domain/data layer produces them — these are generated content,
///    not UI copy, and localizing them means restructuring those layers
///    to return structured data instead of pre-formatted strings.
///  - The debug-only campus map tool (`campus_debug_map_page.dart`,
///    gated behind `kDebugMode`) wasn't touched — not user-facing.
///
/// Arabic (`ar`) gets automatic RTL layout for free once this delegate
/// plus the `flutter_localizations` SDK delegates are registered on
/// `MaterialApp` — Flutter mirrors `Scaffold`/`AppBar`/etc. on its own
/// for any locale it knows is right-to-left.
class AppLocalizations {
  AppLocalizations(this.locale) : _values = locale.languageCode == 'ar' ? _ar : _en;

  final Locale locale;
  final Map<String, String> _values;

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  String _s(String key) => _values[key] ?? key;

  bool get isRtl => locale.languageCode == 'ar';

  // ---------------------------------------------------------------
  // Shell / bottom nav
  // ---------------------------------------------------------------
  String get navHome => _s('navHome');
  String get navRoutes => _s('navRoutes');
  String get navAlerts => _s('navAlerts');
  String get navProfile => _s('navProfile');

  // ---------------------------------------------------------------
  // Auth: welcome
  // ---------------------------------------------------------------
  String get kkuBadge => _s('kkuBadge');
  String get campusNavigationSystem => _s('campusNavigationSystem');
  String get featureWeatherRouting => _s('featureWeatherRouting');
  String get featureSmartNavigation => _s('featureSmartNavigation');
  String get featureComfortPaths => _s('featureComfortPaths');
  String get loginToYourAccount => _s('loginToYourAccount');
  String get createNewAccount => _s('createNewAccount');
  String get byContinuingYouAgree => _s('byContinuingYouAgree');
  String get termsOfService => _s('termsOfService');

  // Auth: login
  String get welcomeBack => _s('welcomeBack');
  String get signInToContinue => _s('signInToContinue');
  String get studentIdNumber => _s('studentIdNumber');
  String get studentIdHint => _s('studentIdHint');
  String get enterYourPassword => _s('enterYourPassword');
  String get forgotPasswordQ => _s('forgotPasswordQ');
  String get login => _s('login');
  String get dontHaveAccount => _s('dontHaveAccount');
  String get register => _s('register');

  // Auth: password field / strength
  String get passwordLabel => _s('passwordLabel');
  String get passwordStrengthWeak => _s('passwordStrengthWeak');
  String get passwordStrengthFair => _s('passwordStrengthFair');
  String get passwordStrengthGood => _s('passwordStrengthGood');
  String get passwordStrengthStrong => _s('passwordStrengthStrong');

  // Auth: register
  String get createAccount => _s('createAccount');
  String get joinMasarFree => _s('joinMasarFree');
  String get fullNameLabel => _s('fullNameLabel');
  String get fullNameHint => _s('fullNameHint');
  String get emailLabel => _s('emailLabel');
  String get emailHint => _s('emailHint');
  String get createStrongPassword => _s('createStrongPassword');
  String get collegeMajorLabel => _s('collegeMajorLabel');
  String get selectYourCollege => _s('selectYourCollege');
  String get alreadyHaveAccount => _s('alreadyHaveAccount');
  List<String> get colleges => isRtl
      ? const [
          'كلية علوم وهندسة الحاسب',
          'كلية الهندسة',
          'كلية الطب',
          'كلية إدارة الأعمال',
          'كلية العلوم',
          'كلية التربية',
        ]
      : const [
          'College of Computer Science',
          'College of Engineering',
          'College of Medicine',
          'College of Business',
          'College of Science',
          'College of Education',
        ];

  // Auth: forgot password
  String get resetPassword => _s('resetPassword');
  String get resetPasswordSubtitle => _s('resetPasswordSubtitle');
  String get forgotPasswordBody => _s('forgotPasswordBody');
  String get sendResetLink => _s('sendResetLink');
  String get checkYourEmail => _s('checkYourEmail');
  String get forgotPasswordSuccessBody => _s('forgotPasswordSuccessBody');
  String get backToLogin => _s('backToLogin');

  // ---------------------------------------------------------------
  // Home
  // ---------------------------------------------------------------
  String get couldNotLoadHome => _s('couldNotLoadHome');
  String get quickActions => _s('quickActions');
  String get findRoute => _s('findRoute');
  String get seasonModeAction => _s('seasonModeAction');
  String get myProfile => _s('myProfile');
  String get recentRoutes => _s('recentRoutes');
  String get seeAll => _s('seeAll');
  String get noRoutesYet => _s('noRoutesYet');
  String get goodMorning => _s('goodMorning');
  String get goodAfternoon => _s('goodAfternoon');
  String get goodEvening => _s('goodEvening');
  String get findBestRoute => _s('findBestRoute');
  String get comfortWeatherAware => _s('comfortWeatherAware');
  String minWalkLabel(int n) => isRtl ? '$n دقيقة مشيًا' : '$n min walk';
  String timeAgoMinutes(int n) => isRtl ? 'قبل $n د' : '${n}m ago';
  String timeAgoHours(int n) => isRtl ? 'قبل $n س' : '${n}h ago';
  String get yesterday => _s('yesterday');
  String timeAgoDays(int n) => isRtl ? 'قبل $n يوم' : '${n}d ago';
  String get summerBadge => _s('summerBadge');
  String get winterBadge => _s('winterBadge');
  String get summerModeActive => _s('summerModeActive');
  String get summerModeDesc => _s('summerModeDesc');
  String get nowLabel => _s('nowLabel');
  String feelsLike(int n) => isRtl ? 'الإحساس $n°' : 'Feels $n°';
  String get heatAlertBadge => _s('heatAlertBadge');

  // ---------------------------------------------------------------
  // Routing: Select Route
  // ---------------------------------------------------------------
  String get couldNotLoadCampusMap => _s('couldNotLoadCampusMap');
  String get selectRoute => _s('selectRoute');
  String get chooseStartDestination => _s('chooseStartDestination');
  String get sameStartDestError => _s('sameStartDestError');
  String get navigationModeLabel => _s('navigationModeLabel');
  String get optimizeForLabel => _s('optimizeForLabel');
  String get startingPoint => _s('startingPoint');
  String get chooseStartingPoint => _s('chooseStartingPoint');
  String get destinationLabel => _s('destinationLabel');
  String get chooseDestination => _s('chooseDestination');
  String get swapPoints => _s('swapPoints');
  String get shadedPaths => _s('shadedPaths');
  String get sunExposedPaths => _s('sunExposedPaths');
  String get weatherAdaptive => _s('weatherAdaptive');
  String get goalComfort => _s('goalComfort');
  String get goalShortest => _s('goalShortest');
  String get goalBalanced => _s('goalBalanced');

  // Routing: Best Route Found
  String get bestRouteFound => _s('bestRouteFound');
  String optimizedForComfort(String seasonWord) =>
      isRtl ? 'مُحسَّن لراحة $seasonWord' : 'Optimized for $seasonWord comfort';
  String get seasonWordSummer => _s('seasonWordSummer');
  String get seasonWordWinter => _s('seasonWordWinter');
  String get seasonWordToday => _s('seasonWordToday');
  String get seasonWordCurrent => _s('seasonWordCurrent');
  String get recommendedRoute => _s('recommendedRoute');
  String get fromLabel => _s('fromLabel');
  String get toLabel => _s('toLabel');
  String get distanceLabel => _s('distanceLabel');
  String get estTimeLabel => _s('estTimeLabel');
  String get comfortLabel => _s('comfortLabel');
  String get comfortAnalysis => _s('comfortAnalysis');
  String get shadeLabel => _s('shadeLabel');
  String get sunLabel => _s('sunLabel');
  String get windLabel => _s('windLabel');
  String get alternativeRoutes => _s('alternativeRoutes');
  String get viewRoute => _s('viewRoute');
  String get detailsLabel => _s('detailsLabel');
  String get shortestPathLabel => _s('shortestPathLabel');
  String get balancedRouteLabel => _s('balancedRouteLabel');
  String altRouteSummary(int distM, int min, int shade) =>
      isRtl ? '$distM م · $min د · $shade٪ ظل' : '$distM m · $min min · $shade% shade';
  String get fastBadge => _s('fastBadge');
  String get balancedBadge => _s('balancedBadge');

  // Routing: comfort band (Route Details gauge)
  String get comfortExcellent => _s('comfortExcellent');
  String get comfortExcellentShort => _s('comfortExcellentShort');
  String get comfortGood => _s('comfortGood');
  String get comfortGoodShort => _s('comfortGoodShort');
  String get comfortFair => _s('comfortFair');
  String get comfortFairShort => _s('comfortFairShort');
  String get comfortLow => _s('comfortLow');
  String get comfortLowShort => _s('comfortLowShort');
  String comfortDescGreatShade(String seasonWord) => isRtl
      ? 'يوفر هذا المسار تغطية ظل ممتازة مع أقل تعرض للشمس — مثالي للتنقل في $seasonWord داخل الجامعة.'
      : 'This route offers excellent shade coverage with minimal sun exposure — ideal for $seasonWord navigation at KKU.';
  String get comfortDescSolidShade => _s('comfortDescSolidShade');
  String get comfortDescLimitedShade => _s('comfortDescLimitedShade');

  // Routing: weather impact classifiers
  String get tempCold => _s('tempCold');
  String get tempColdDetail => _s('tempColdDetail');
  String get tempMild => _s('tempMild');
  String get tempMildDetail => _s('tempMildDetail');
  String get tempWarm => _s('tempWarm');
  String get tempWarmDetail => _s('tempWarmDetail');
  String get tempHot => _s('tempHot');
  String get tempHotDetail => _s('tempHotDetail');
  String get tempVeryHot => _s('tempVeryHot');
  String get tempVeryHotDetail => _s('tempVeryHotDetail');
  String get uvLow => _s('uvLow');
  String get uvLowDetail => _s('uvLowDetail');
  String get uvModerate => _s('uvModerate');
  String get uvModerateDetail => _s('uvModerateDetail');
  String get uvHigh => _s('uvHigh');
  String get uvHighDetail => _s('uvHighDetail');
  String get uvVeryHigh => _s('uvVeryHigh');
  String get uvVeryHighDetail => _s('uvVeryHighDetail');
  String get uvExtreme => _s('uvExtreme');
  String get uvExtremeDetail => _s('uvExtremeDetail');
  String get heatSafeLow => _s('heatSafeLow');
  String get heatSafeLowDetail => _s('heatSafeLowDetail');
  String get heatSafeModerate => _s('heatSafeModerate');
  String get heatSafeModerateDetail => _s('heatSafeModerateDetail');
  String get heatSafeHigh => _s('heatSafeHigh');
  String get heatSafeHighDetail => _s('heatSafeHighDetail');
  String get heatSafeExtreme => _s('heatSafeExtreme');
  String get heatSafeExtremeDetail => _s('heatSafeExtremeDetail');
  String get heatTipLow => _s('heatTipLow');
  String get heatTipModerate => _s('heatTipModerate');
  String get heatTipHigh => _s('heatTipHigh');
  String get heatTipExtreme => _s('heatTipExtreme');
  String get windCalm => _s('windCalm');
  String get windLightBreeze => _s('windLightBreeze');
  String get windBreezy => _s('windBreezy');
  String get windStrong => _s('windStrong');
  String get uvIndexLabel => _s('uvIndexLabel');
  String get notAvailable => _s('notAvailable');
  String get windSpeedLabel => _s('windSpeedLabel');
  String get heatSafetyLabel => _s('heatSafetyLabel');

  // Routing: Route Details page chrome
  String get routeDetailsTitle => _s('routeDetailsTitle');
  String get totalDistance => _s('totalDistance');
  String get outdoorWalkingPath => _s('outdoorWalkingPath');
  String get estimatedTimeLabel => _s('estimatedTimeLabel');
  String get atNormalWalkingPace => _s('atNormalWalkingPace');
  String get comfortScoreLabel => _s('comfortScoreLabel');
  String get shadedCoverage => _s('shadedCoverage');
  String get directSun => _s('directSun');
  String get breezeLabel => _s('breezeLabel');
  String get accessibleLabel => _s('accessibleLabel');
  String get weatherImpactLabel => _s('weatherImpactLabel');
  String get startNavigation => _s('startNavigation');

  // Routing: Route Guide (turn-by-turn)
  String get navigatingEllipsis => _s('navigatingEllipsis');
  String get navigatingLabel => _s('navigatingLabel');
  String get yourDestinationFallback => _s('yourDestinationFallback');
  String arrivedAt(String name) => isRtl ? 'لقد وصلت إلى $name!' : "You've arrived at $name!";
  String get maneuverStart => _s('maneuverStart');
  String get maneuverTurnLeft => _s('maneuverTurnLeft');
  String get maneuverTurnRight => _s('maneuverTurnRight');
  String get maneuverContinueStraight => _s('maneuverContinueStraight');
  String get maneuverArrived => _s('maneuverArrived');
  String legDistanceAhead(int n) => isRtl ? '$n م للأمام' : '$n m ahead';
  String stepOfTotal(int step, int total) => isRtl ? 'الخطوة $step من $total' : 'STEP $step OF $total';

  // ---------------------------------------------------------------
  // Notifications / Alerts
  // ---------------------------------------------------------------
  String get notificationsTitle => _s('notificationsTitle');
  String unreadAlertsCount(int n) {
    if (isRtl) return '$n تنبيهات غير مقروءة';
    return '$n unread alert${n == 1 ? '' : 's'}';
  }

  String get markAllAsRead => _s('markAllAsRead');
  String get allCaughtUp => _s('allCaughtUp');
  String get categoryHeatAlert => _s('categoryHeatAlert');
  String get categoryRouteUpdate => _s('categoryRouteUpdate');
  String get categorySystem => _s('categorySystem');
  String get categoryWeather => _s('categoryWeather');
  String get categorySavedRoute => _s('categorySavedRoute');
  String get categoryNewFeature => _s('categoryNewFeature');
  String get justNow => _s('justNow');
  String get seed1Title => _s('seed1Title');
  String get seed1Msg => _s('seed1Msg');
  String get seed2Title => _s('seed2Title');
  String get seed2Msg => _s('seed2Msg');
  String get seed3Title => _s('seed3Title');
  String get seed3Msg => _s('seed3Msg');
  String get seed4Title => _s('seed4Title');
  String get seed4Msg => _s('seed4Msg');
  String get seed5Title => _s('seed5Title');
  String get seed5Msg => _s('seed5Msg');
  String get seed6Title => _s('seed6Title');
  String get seed6Msg => _s('seed6Msg');

  // ---------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------
  String get statRoutes => _s('statRoutes');
  String get statKmWalked => _s('statKmWalked');
  String get statSaved => _s('statSaved');
  String get couldNotLoadProfile => _s('couldNotLoadProfile');
  String get universityEmail => _s('universityEmail');
  String get verified => _s('verified');
  String get sectionAccount => _s('sectionAccount');
  String get personalInformation => _s('personalInformation');
  String get personalInformationSubtitle => _s('personalInformationSubtitle');
  String get academicDetails => _s('academicDetails');
  String get academicDetailsSubtitle => _s('academicDetailsSubtitle');
  String get sectionNavigation => _s('sectionNavigation');
  String get seasonPreferences => _s('seasonPreferences');
  String seasonModeActive(String modeLabel) => isRtl ? 'وضع $modeLabel نشط' : '$modeLabel Mode active';
  String get sectionApp => _s('sectionApp');
  String get notificationSettings => _s('notificationSettings');
  String get notificationSettingsSubtitle => _s('notificationSettingsSubtitle');
  String get appSettings => _s('appSettings');
  String get appSettingsSubtitle => _s('appSettingsSubtitle');
  String get helpSupport => _s('helpSupport');
  String get helpSupportSubtitle => _s('helpSupportSubtitle');
  String get logout => _s('logout');
  String get fullName => _s('fullName');
  String get phoneOptional => _s('phoneOptional');
  String get save => _s('save');
  String get collegeMajor => _s('collegeMajor');
  String get year => _s('year');
  List<String> get academicYears => isRtl
      ? const ['السنة الأولى', 'السنة الثانية', 'السنة الثالثة', 'السنة الرابعة', 'السنة الخامسة فأكثر']
      : const ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5+'];
  String get appSettingsTitle => _s('appSettingsTitle');
  String get sectionLanguageVoice => _s('sectionLanguageVoice');
  String get appLanguage => _s('appLanguage');
  String get voiceGuidance => _s('voiceGuidance');
  String get voiceGuidanceOn => _s('voiceGuidanceOn');
  String get voiceGuidanceOff => _s('voiceGuidanceOff');
  String get sectionAppearance => _s('sectionAppearance');
  String get theme => _s('theme');
  String get themeSystem => _s('themeSystem');
  String get themeLight => _s('themeLight');
  String get themeDark => _s('themeDark');

  // ---------------------------------------------------------------
  // Admin placeholder
  // ---------------------------------------------------------------
  String get adminTitleSuffix => _s('adminTitleSuffix');
  String signedInAsAdmin(String email) => isRtl ? 'مسجّل الدخول كمسؤول ($email)' : 'Signed in as admin ($email)';
  String get signOutForAdmin => _s('signOutForAdmin');
  String get unknownEmail => _s('unknownEmail');

  static const Map<String, String> _en = {
    'navHome': 'Home',
    'navRoutes': 'Routes',
    'navAlerts': 'Alerts',
    'navProfile': 'Profile',
    'kkuBadge': 'KING KHALID UNIVERSITY',
    'campusNavigationSystem': 'Campus Navigation System',
    'featureWeatherRouting': 'Weather\nRouting',
    'featureSmartNavigation': 'Smart\nNavigation',
    'featureComfortPaths': 'Comfort\nPaths',
    'loginToYourAccount': 'Login to Your Account',
    'createNewAccount': 'Create New Account',
    'byContinuingYouAgree': 'By continuing, you agree to our ',
    'termsOfService': 'Terms of Service',
    'welcomeBack': 'Welcome Back',
    'signInToContinue': 'Sign in to continue navigating',
    'studentIdNumber': 'Student ID Number',
    'studentIdHint': 'e.g. 441234567',
    'enterYourPassword': 'Enter your password',
    'forgotPasswordQ': 'Forgot Password?',
    'login': 'Login',
    'dontHaveAccount': "Don't have an account? ",
    'register': 'Register',
    'passwordLabel': 'PASSWORD',
    'passwordStrengthWeak': 'Weak — try a longer password',
    'passwordStrengthFair': 'Fair — add numbers to strengthen',
    'passwordStrengthGood': 'Good — add a symbol for extra strength',
    'passwordStrengthStrong': 'Strong password',
    'createAccount': 'Create Account',
    'joinMasarFree': "Join Masar KKU — it's free",
    'fullNameLabel': 'Full Name',
    'fullNameHint': 'Your full name',
    'emailLabel': 'Email',
    'emailHint': 'name@gmail.com',
    'createStrongPassword': 'Create a strong password',
    'collegeMajorLabel': 'COLLEGE / MAJOR',
    'selectYourCollege': 'Select your college',
    'alreadyHaveAccount': 'Already have an account? ',
    'resetPassword': 'Reset Password',
    'resetPasswordSubtitle': "We'll email you a link to reset it",
    'forgotPasswordBody':
        "Enter the student ID linked to your account and we'll send a password reset link to your university email.",
    'sendResetLink': 'Send Reset Link',
    'checkYourEmail': 'Check your email',
    'forgotPasswordSuccessBody':
        'If an account exists for that student ID, a password reset link has been sent to the university email on file.',
    'backToLogin': 'Back to Login',
    'couldNotLoadHome': 'Could not load the home screen.',
    'quickActions': 'QUICK ACTIONS',
    'findRoute': 'Find Route',
    'seasonModeAction': 'Season Mode',
    'myProfile': 'My Profile',
    'recentRoutes': 'RECENT ROUTES',
    'seeAll': 'See All',
    'noRoutesYet': 'No routes yet — try Find Route above.',
    'goodMorning': 'Good morning',
    'goodAfternoon': 'Good afternoon',
    'goodEvening': 'Good evening',
    'findBestRoute': 'Find Best Route',
    'comfortWeatherAware': 'Comfort-optimized · Weather-aware',
    'yesterday': 'Yesterday',
    'summerBadge': '☀️ Summer',
    'winterBadge': '❄️ Winter',
    'summerModeActive': 'Summer Mode Active',
    'summerModeDesc': 'Routes prefer shaded paths to reduce heat exposure',
    'nowLabel': 'Now',
    'heatAlertBadge': 'Heat Alert',
    'couldNotLoadCampusMap': 'Could not load the campus map.',
    'selectRoute': 'Select Route',
    'chooseStartDestination': 'Choose your start & destination',
    'sameStartDestError': "Starting point and destination can't be the same.",
    'navigationModeLabel': 'NAVIGATION MODE',
    'optimizeForLabel': 'OPTIMIZE FOR',
    'startingPoint': 'Starting Point',
    'chooseStartingPoint': 'Choose starting point',
    'destinationLabel': 'Destination',
    'chooseDestination': 'Choose destination',
    'swapPoints': 'Swap Points',
    'shadedPaths': 'Shaded paths',
    'sunExposedPaths': 'Sun-exposed paths',
    'weatherAdaptive': 'Weather-adaptive',
    'goalComfort': 'Comfort',
    'goalShortest': 'Shortest',
    'goalBalanced': 'Balanced',
    'bestRouteFound': 'Best Route Found!',
    'seasonWordSummer': 'summer',
    'seasonWordWinter': 'winter',
    'seasonWordToday': "today's",
    'seasonWordCurrent': 'current',
    'recommendedRoute': 'RECOMMENDED ROUTE',
    'fromLabel': 'From',
    'toLabel': 'To',
    'distanceLabel': 'Distance',
    'estTimeLabel': 'Est. Time',
    'comfortLabel': 'Comfort',
    'comfortAnalysis': 'COMFORT ANALYSIS',
    'shadeLabel': 'Shade',
    'sunLabel': 'Sun',
    'windLabel': 'Wind',
    'alternativeRoutes': 'ALTERNATIVE ROUTES',
    'viewRoute': 'View Route',
    'detailsLabel': 'Details',
    'shortestPathLabel': 'Shortest Path',
    'balancedRouteLabel': 'Balanced Route',
    'fastBadge': '⚡ Fast',
    'balancedBadge': '⚖️ Balanced',
    'comfortExcellent': 'Excellent Comfort Level',
    'comfortExcellentShort': 'EXCELLENT',
    'comfortGood': 'Good Comfort Level',
    'comfortGoodShort': 'GOOD',
    'comfortFair': 'Fair Comfort Level',
    'comfortFairShort': 'FAIR',
    'comfortLow': 'Low Comfort Level',
    'comfortLowShort': 'LOW',
    'comfortDescSolidShade': 'This route offers solid shade coverage along most of the walk.',
    'comfortDescLimitedShade': 'This route has limited shade coverage — carry water and sun protection.',
    'tempCold': 'Cold',
    'tempColdDetail': 'Low risk',
    'tempMild': 'Mild',
    'tempMildDetail': 'Low risk',
    'tempWarm': 'Warm',
    'tempWarmDetail': 'Moderate risk',
    'tempHot': 'Hot',
    'tempHotDetail': 'High risk',
    'tempVeryHot': 'Very Hot',
    'tempVeryHotDetail': 'Extreme risk',
    'uvLow': 'Low',
    'uvLowDetail': 'Minimal protection needed',
    'uvModerate': 'Moderate',
    'uvModerateDetail': 'Wear sunscreen',
    'uvHigh': 'High',
    'uvHighDetail': 'Seek shade at midday',
    'uvVeryHigh': 'Very High',
    'uvVeryHighDetail': 'Extra protection needed',
    'uvExtreme': 'Extreme',
    'uvExtremeDetail': 'Avoid sun exposure',
    'heatSafeLow': 'Low',
    'heatSafeLowDetail': 'Comfortable conditions',
    'heatSafeModerate': 'Moderate',
    'heatSafeModerateDetail': 'Shade advised',
    'heatSafeHigh': 'High',
    'heatSafeHighDetail': 'Seek shade frequently',
    'heatSafeExtreme': 'Extreme',
    'heatSafeExtremeDetail': 'Avoid prolonged exposure',
    'heatTipLow': 'Conditions are comfortable for walking — no special precautions needed.',
    'heatTipModerate': 'Carry water and avoid prolonged exposure during peak hours (12PM–3PM).',
    'heatTipHigh': 'Carry water, wear sun protection, and take shaded breaks during peak hours (12PM–3PM).',
    'heatTipExtreme': 'Avoid non-essential outdoor walking during peak hours (12PM–3PM) if possible.',
    'windCalm': 'Calm',
    'windLightBreeze': 'Light breeze',
    'windBreezy': 'Breezy',
    'windStrong': 'Strong wind',
    'uvIndexLabel': 'UV Index',
    'notAvailable': 'Not available',
    'windSpeedLabel': 'Wind Speed',
    'heatSafetyLabel': 'Heat Safety',
    'routeDetailsTitle': 'Route Details',
    'totalDistance': 'Total Distance',
    'outdoorWalkingPath': 'Outdoor walking path',
    'estimatedTimeLabel': 'Estimated Time',
    'atNormalWalkingPace': 'At normal walking pace',
    'comfortScoreLabel': 'COMFORT SCORE',
    'shadedCoverage': 'Shaded Coverage',
    'directSun': 'Direct Sun',
    'breezeLabel': 'Breeze',
    'accessibleLabel': 'Accessible',
    'weatherImpactLabel': 'WEATHER IMPACT',
    'startNavigation': 'Start Navigation',
    'navigatingEllipsis': 'Navigating...',
    'navigatingLabel': 'Navigating',
    'yourDestinationFallback': 'your destination',
    'maneuverStart': 'START',
    'maneuverTurnLeft': 'TURN LEFT',
    'maneuverTurnRight': 'TURN RIGHT',
    'maneuverContinueStraight': 'CONTINUE STRAIGHT',
    'maneuverArrived': 'ARRIVED',
    'notificationsTitle': 'Notifications',
    'markAllAsRead': 'Mark All as Read',
    'allCaughtUp': "You're all caught up",
    'categoryHeatAlert': 'Heat Alert',
    'categoryRouteUpdate': 'Route Update',
    'categorySystem': 'System',
    'categoryWeather': 'Weather',
    'categorySavedRoute': 'Saved Route',
    'categoryNewFeature': 'New Feature',
    'justNow': 'Just now',
    'seed1Title': 'Extreme Heat Warning',
    'seed1Msg':
        'Temperature at KKU Campus is now 42°C. Smart Path recommends using shaded routes only. Avoid walking between 12PM–3PM.',
    'seed2Title': 'Route Change: Gate 2 Path',
    'seed2Msg':
        'Construction on the east walkway near Gate 2 is affecting your saved route. A new optimized path has been generated.',
    'seed3Title': 'Season Mode Auto-Updated',
    'seed3Msg':
        'Smart Path detected a temperature rise and switched navigation to Summer Mode automatically for optimal comfort.',
    'seed4Title': 'Partly Cloudy This Afternoon',
    'seed4Msg':
        'Cloud cover expected between 3PM and 6PM. Sun exposure on campus routes will decrease. Winter Mode may become preferable.',
    'seed5Title': 'Reminder: Saved Route',
    'seed5Msg':
        'Your usual route "Gate 1 → CS Building" is ready. Today\'s conditions: 38°C, 72% shade on recommended path.',
    'seed6Title': 'Voice Guidance Now Available',
    'seed6Msg':
        'Smart Path now supports Arabic and English voice-guided navigation. Enable it in Settings → Navigation → Voice Guidance.',
    'statRoutes': 'Routes',
    'statKmWalked': 'km Walked',
    'statSaved': 'Saved',
    'couldNotLoadProfile': 'Could not load your profile.',
    'universityEmail': 'University Email',
    'verified': 'Verified',
    'sectionAccount': 'Account',
    'personalInformation': 'Personal Information',
    'personalInformationSubtitle': 'Name, email, phone',
    'academicDetails': 'Academic Details',
    'academicDetailsSubtitle': 'College, major, year',
    'sectionNavigation': 'Navigation',
    'seasonPreferences': 'Season Preferences',
    'sectionApp': 'App',
    'notificationSettings': 'Notification Settings',
    'notificationSettingsSubtitle': 'Alerts & reminders',
    'appSettings': 'App Settings',
    'appSettingsSubtitle': 'Language, voice, theme',
    'helpSupport': 'Help & Support',
    'helpSupportSubtitle': 'FAQ, contact us',
    'logout': 'Logout',
    'fullName': 'Full name',
    'phoneOptional': 'Phone (optional)',
    'save': 'Save',
    'collegeMajor': 'College / Major',
    'year': 'Year',
    'appSettingsTitle': 'App Settings',
    'sectionLanguageVoice': 'Language & Voice',
    'appLanguage': 'App Language',
    'voiceGuidance': 'Voice Guidance',
    'voiceGuidanceOn': 'Spoken turn-by-turn is on',
    'voiceGuidanceOff': 'Off',
    'sectionAppearance': 'Appearance',
    'theme': 'Theme',
    'themeSystem': 'System',
    'themeLight': 'Light',
    'themeDark': 'Dark',
    'adminTitleSuffix': 'Masar KKU — Admin',
    'signOutForAdmin': 'Sign out for admin',
    'unknownEmail': 'unknown',
  };

  static const Map<String, String> _ar = {
    'navHome': 'الرئيسية',
    'navRoutes': 'المسارات',
    'navAlerts': 'التنبيهات',
    'navProfile': 'الملف الشخصي',
    'kkuBadge': 'جامعة الملك خالد',
    'campusNavigationSystem': 'نظام ملاحة الحرم الجامعي',
    'featureWeatherRouting': 'توجيه\nحسب الطقس',
    'featureSmartNavigation': 'ملاحة\nذكية',
    'featureComfortPaths': 'مسارات\nمريحة',
    'loginToYourAccount': 'تسجيل الدخول إلى حسابك',
    'createNewAccount': 'إنشاء حساب جديد',
    'byContinuingYouAgree': 'بالمتابعة، أنت توافق على ',
    'termsOfService': 'شروط الخدمة',
    'welcomeBack': 'مرحبًا بعودتك',
    'signInToContinue': 'سجّل الدخول لمتابعة التنقل',
    'studentIdNumber': 'الرقم الجامعي',
    'studentIdHint': 'مثال: 441234567',
    'enterYourPassword': 'أدخل كلمة المرور',
    'forgotPasswordQ': 'نسيت كلمة المرور؟',
    'login': 'تسجيل الدخول',
    'dontHaveAccount': 'ليس لديك حساب؟ ',
    'register': 'إنشاء حساب',
    'passwordLabel': 'كلمة المرور',
    'passwordStrengthWeak': 'ضعيفة — جرّب كلمة مرور أطول',
    'passwordStrengthFair': 'مقبولة — أضف أرقامًا لتقويتها',
    'passwordStrengthGood': 'جيدة — أضف رمزًا لمزيد من القوة',
    'passwordStrengthStrong': 'كلمة مرور قوية',
    'createAccount': 'إنشاء حساب',
    'joinMasarFree': 'انضم إلى مسار KKU — مجانًا',
    'fullNameLabel': 'الاسم الكامل',
    'fullNameHint': 'اسمك الكامل',
    'emailLabel': 'البريد الإلكتروني',
    'emailHint': 'name@gmail.com',
    'createStrongPassword': 'أنشئ كلمة مرور قوية',
    'collegeMajorLabel': 'الكلية / التخصص',
    'selectYourCollege': 'اختر كليتك',
    'alreadyHaveAccount': 'لديك حساب بالفعل؟ ',
    'resetPassword': 'إعادة تعيين كلمة المرور',
    'resetPasswordSubtitle': 'سنرسل لك رابطًا لإعادة تعيينها عبر البريد',
    'forgotPasswordBody':
        'أدخل الرقم الجامعي المرتبط بحسابك وسنرسل رابط إعادة تعيين كلمة المرور إلى بريدك الجامعي.',
    'sendResetLink': 'إرسال رابط إعادة التعيين',
    'checkYourEmail': 'تحقق من بريدك الإلكتروني',
    'forgotPasswordSuccessBody':
        'إذا كان هناك حساب مرتبط بهذا الرقم الجامعي، فقد تم إرسال رابط إعادة تعيين كلمة المرور إلى البريد الجامعي المسجَّل.',
    'backToLogin': 'العودة لتسجيل الدخول',
    'couldNotLoadHome': 'تعذّر تحميل الشاشة الرئيسية.',
    'quickActions': 'إجراءات سريعة',
    'findRoute': 'ابحث عن مسار',
    'seasonModeAction': 'وضع الموسم',
    'myProfile': 'ملفي الشخصي',
    'recentRoutes': 'المسارات الأخيرة',
    'seeAll': 'عرض الكل',
    'noRoutesYet': 'لا توجد مسارات بعد — جرّب "ابحث عن مسار" أعلاه.',
    'goodMorning': 'صباح الخير',
    'goodAfternoon': 'مساء الخير',
    'goodEvening': 'مساء الخير',
    'findBestRoute': 'ابحث عن أفضل مسار',
    'comfortWeatherAware': 'مُحسَّن للراحة · يراعي الطقس',
    'yesterday': 'أمس',
    'summerBadge': '☀️ صيفي',
    'winterBadge': '❄️ شتوي',
    'summerModeActive': 'الوضع الصيفي نشط',
    'summerModeDesc': 'تُفضّل المسارات الظليلة لتقليل التعرض للحرارة',
    'nowLabel': 'الآن',
    'heatAlertBadge': 'تنبيه حرارة',
    'couldNotLoadCampusMap': 'تعذّر تحميل خريطة الحرم الجامعي.',
    'selectRoute': 'اختيار المسار',
    'chooseStartDestination': 'اختر نقطة البداية والوجهة',
    'sameStartDestError': 'لا يمكن أن تكون نقطة البداية والوجهة نفس المكان.',
    'navigationModeLabel': 'وضع الملاحة',
    'optimizeForLabel': 'التحسين لأجل',
    'startingPoint': 'نقطة البداية',
    'chooseStartingPoint': 'اختر نقطة البداية',
    'destinationLabel': 'الوجهة',
    'chooseDestination': 'اختر الوجهة',
    'swapPoints': 'تبديل النقطتين',
    'shadedPaths': 'مسارات ظليلة',
    'sunExposedPaths': 'مسارات مشمسة',
    'weatherAdaptive': 'يتكيف مع الطقس',
    'goalComfort': 'الراحة',
    'goalShortest': 'الأقصر',
    'goalBalanced': 'متوازن',
    'bestRouteFound': 'تم العثور على أفضل مسار!',
    'seasonWordSummer': 'الصيف',
    'seasonWordWinter': 'الشتاء',
    'seasonWordToday': 'اليوم',
    'seasonWordCurrent': 'الوقت الحالي',
    'recommendedRoute': 'المسار الموصى به',
    'fromLabel': 'من',
    'toLabel': 'إلى',
    'distanceLabel': 'المسافة',
    'estTimeLabel': 'الوقت المتوقع',
    'comfortLabel': 'الراحة',
    'comfortAnalysis': 'تحليل الراحة',
    'shadeLabel': 'الظل',
    'sunLabel': 'الشمس',
    'windLabel': 'الرياح',
    'alternativeRoutes': 'مسارات بديلة',
    'viewRoute': 'عرض المسار',
    'detailsLabel': 'التفاصيل',
    'shortestPathLabel': 'المسار الأقصر',
    'balancedRouteLabel': 'المسار المتوازن',
    'fastBadge': '⚡ سريع',
    'balancedBadge': '⚖️ متوازن',
    'comfortExcellent': 'مستوى راحة ممتاز',
    'comfortExcellentShort': 'ممتاز',
    'comfortGood': 'مستوى راحة جيد',
    'comfortGoodShort': 'جيد',
    'comfortFair': 'مستوى راحة مقبول',
    'comfortFairShort': 'مقبول',
    'comfortLow': 'مستوى راحة منخفض',
    'comfortLowShort': 'منخفض',
    'comfortDescSolidShade': 'يوفر هذا المسار تغطية ظل جيدة على معظم مسافة المشي.',
    'comfortDescLimitedShade': 'تغطية الظل في هذا المسار محدودة — احمل ماءً ووسائل حماية من الشمس.',
    'tempCold': 'بارد',
    'tempColdDetail': 'خطر منخفض',
    'tempMild': 'معتدل',
    'tempMildDetail': 'خطر منخفض',
    'tempWarm': 'دافئ',
    'tempWarmDetail': 'خطر متوسط',
    'tempHot': 'حار',
    'tempHotDetail': 'خطر مرتفع',
    'tempVeryHot': 'حار جدًا',
    'tempVeryHotDetail': 'خطر شديد',
    'uvLow': 'منخفض',
    'uvLowDetail': 'لا حاجة لحماية تُذكر',
    'uvModerate': 'متوسط',
    'uvModerateDetail': 'استخدم واقي الشمس',
    'uvHigh': 'مرتفع',
    'uvHighDetail': 'ابحث عن الظل عند الظهيرة',
    'uvVeryHigh': 'مرتفع جدًا',
    'uvVeryHighDetail': 'حماية إضافية مطلوبة',
    'uvExtreme': 'شديد',
    'uvExtremeDetail': 'تجنّب التعرض للشمس',
    'heatSafeLow': 'منخفض',
    'heatSafeLowDetail': 'ظروف مريحة',
    'heatSafeModerate': 'متوسط',
    'heatSafeModerateDetail': 'يُنصح بالظل',
    'heatSafeHigh': 'مرتفع',
    'heatSafeHighDetail': 'ابحث عن الظل باستمرار',
    'heatSafeExtreme': 'شديد',
    'heatSafeExtremeDetail': 'تجنّب التعرض المطوّل',
    'heatTipLow': 'الأجواء مريحة للمشي — لا حاجة لاحتياطات خاصة.',
    'heatTipModerate': 'احمل ماءً وتجنّب التعرض المطوّل خلال ساعات الذروة (12 ظهرًا–3 عصرًا).',
    'heatTipHigh': 'احمل ماءً، واستخدم وسائل حماية من الشمس، وخذ فترات راحة في الظل خلال ساعات الذروة (12 ظهرًا–3 عصرًا).',
    'heatTipExtreme': 'تجنّب المشي غير الضروري في الخارج خلال ساعات الذروة (12 ظهرًا–3 عصرًا) إن أمكن.',
    'windCalm': 'هادئة',
    'windLightBreeze': 'نسيم خفيف',
    'windBreezy': 'رياح معتدلة',
    'windStrong': 'رياح قوية',
    'uvIndexLabel': 'مؤشر الأشعة فوق البنفسجية',
    'notAvailable': 'غير متاح',
    'windSpeedLabel': 'سرعة الرياح',
    'heatSafetyLabel': 'السلامة الحرارية',
    'routeDetailsTitle': 'تفاصيل المسار',
    'totalDistance': 'المسافة الكلية',
    'outdoorWalkingPath': 'مسار مشي خارجي',
    'estimatedTimeLabel': 'الوقت المتوقع',
    'atNormalWalkingPace': 'بسرعة مشي عادية',
    'comfortScoreLabel': 'درجة الراحة',
    'shadedCoverage': 'تغطية الظل',
    'directSun': 'شمس مباشرة',
    'breezeLabel': 'النسيم',
    'accessibleLabel': 'سهل الوصول',
    'weatherImpactLabel': 'تأثير الطقس',
    'startNavigation': 'بدء الملاحة',
    'navigatingEllipsis': 'جارٍ التنقل...',
    'navigatingLabel': 'جارٍ التنقل',
    'yourDestinationFallback': 'وجهتك',
    'maneuverStart': 'البداية',
    'maneuverTurnLeft': 'انعطف يسارًا',
    'maneuverTurnRight': 'انعطف يمينًا',
    'maneuverContinueStraight': 'استمر مستقيمًا',
    'maneuverArrived': 'وصلت',
    'notificationsTitle': 'الإشعارات',
    'markAllAsRead': 'تعليم الكل كمقروء',
    'allCaughtUp': 'لا جديد لديك',
    'categoryHeatAlert': 'تنبيه حرارة',
    'categoryRouteUpdate': 'تحديث مسار',
    'categorySystem': 'النظام',
    'categoryWeather': 'الطقس',
    'categorySavedRoute': 'مسار محفوظ',
    'categoryNewFeature': 'ميزة جديدة',
    'justNow': 'الآن',
    'seed1Title': 'تحذير من حرارة شديدة',
    'seed1Msg':
        'درجة الحرارة في حرم جامعة الملك خالد الآن 42°م. يوصي مسار الذكي باستخدام المسارات الظليلة فقط. تجنّب المشي بين الساعة 12 ظهرًا و3 عصرًا.',
    'seed2Title': 'تغيير مسار: ممر البوابة 2',
    'seed2Msg': 'أعمال الإنشاء في الممر الشرقي قرب البوابة 2 تؤثر على مسارك المحفوظ. تم إنشاء مسار محسَّن جديد.',
    'seed3Title': 'تحديث تلقائي لوضع الموسم',
    'seed3Msg': 'رصد مسار ارتفاعًا في درجة الحرارة وبدّل الملاحة تلقائيًا إلى الوضع الصيفي لراحة أفضل.',
    'seed4Title': 'غائم جزئيًا بعد الظهر',
    'seed4Msg':
        'يُتوقع تغطية سحابية بين الساعة 3 و6 عصرًا. سينخفض التعرض للشمس في مسارات الحرم الجامعي. قد يكون الوضع الشتوي أفضل.',
    'seed5Title': 'تذكير: مسار محفوظ',
    'seed5Msg': 'مسارك المعتاد "البوابة 1 → مبنى علوم الحاسب" جاهز. أحوال اليوم: 38°م، 72٪ ظل على المسار الموصى به.',
    'seed6Title': 'الإرشاد الصوتي متاح الآن',
    'seed6Msg': 'يدعم مسار الآن الملاحة الصوتية بالعربية والإنجليزية. فعّلها من الإعدادات ← الملاحة ← الإرشاد الصوتي.',
    'statRoutes': 'المسارات',
    'statKmWalked': 'كم تم المشي',
    'statSaved': 'المحفوظة',
    'couldNotLoadProfile': 'تعذّر تحميل ملفك الشخصي.',
    'universityEmail': 'البريد الجامعي',
    'verified': 'موثّق',
    'sectionAccount': 'الحساب',
    'personalInformation': 'المعلومات الشخصية',
    'personalInformationSubtitle': 'الاسم، البريد، الهاتف',
    'academicDetails': 'التفاصيل الأكاديمية',
    'academicDetailsSubtitle': 'الكلية، التخصص، السنة',
    'sectionNavigation': 'الملاحة',
    'seasonPreferences': 'تفضيلات الموسم',
    'sectionApp': 'التطبيق',
    'notificationSettings': 'إعدادات الإشعارات',
    'notificationSettingsSubtitle': 'التنبيهات والتذكيرات',
    'appSettings': 'إعدادات التطبيق',
    'appSettingsSubtitle': 'اللغة، الصوت، المظهر',
    'helpSupport': 'المساعدة والدعم',
    'helpSupportSubtitle': 'الأسئلة الشائعة، تواصل معنا',
    'logout': 'تسجيل الخروج',
    'fullName': 'الاسم الكامل',
    'phoneOptional': 'الهاتف (اختياري)',
    'save': 'حفظ',
    'collegeMajor': 'الكلية / التخصص',
    'year': 'السنة',
    'appSettingsTitle': 'إعدادات التطبيق',
    'sectionLanguageVoice': 'اللغة والصوت',
    'appLanguage': 'لغة التطبيق',
    'voiceGuidance': 'الإرشاد الصوتي',
    'voiceGuidanceOn': 'التوجيه الصوتي خطوة بخطوة مُفعّل',
    'voiceGuidanceOff': 'متوقف',
    'sectionAppearance': 'المظهر',
    'theme': 'السمة',
    'themeSystem': 'النظام',
    'themeLight': 'فاتح',
    'themeDark': 'داكن',
    'adminTitleSuffix': 'مسار KKU — المسؤول',
    'signOutForAdmin': 'تسجيل الخروج من وضع المسؤول',
    'unknownEmail': 'غير معروف',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
