import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/auth/auth_gateway.dart';
import 'package:virtuomate_flutter/auth/firebase_auth_gateway.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/data/api_app_repository.dart';
import 'package:virtuomate_flutter/data/app_repository.dart';
import 'package:virtuomate_flutter/data/firebase_app_repository.dart';
import 'package:virtuomate_flutter/external/api_subscription_gateway.dart';
import 'package:virtuomate_flutter/external/subscription_gateway.dart';
import 'package:virtuomate_flutter/firebase/firebase_bootstrap.dart';
import 'package:virtuomate_flutter/intelligence/api_coach_engine.dart';
import 'package:virtuomate_flutter/intelligence/coach_engine.dart';
import 'package:virtuomate_flutter/network/api_client.dart';
import 'package:virtuomate_flutter/services/admin_api_service.dart';
import 'package:virtuomate_flutter/services/app_service.dart';
import 'package:virtuomate_flutter/services/profile_sync_service.dart';
import 'package:virtuomate_flutter/core/neural_connectivity.dart';
import 'package:virtuomate_flutter/services/neural_connectivity_service.dart';
import 'package:virtuomate_flutter/services/startup_health.dart';
import 'package:virtuomate_flutter/services/storage_service.dart';
import 'package:virtuomate_flutter/services/video_cv_render_service.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/screens/admin_screens.dart';
import 'package:virtuomate_flutter/ui/screens/achievements_screen.dart';
import 'package:virtuomate_flutter/ui/screens/analytics_screen.dart';
import 'package:virtuomate_flutter/ui/screens/auth_screens.dart';
import 'package:virtuomate_flutter/ui/screens/avatar_screen.dart';
import 'package:virtuomate_flutter/ui/screens/coach_chat_screen.dart';
import 'package:virtuomate_flutter/ui/screens/dashboard_screen.dart';
import 'package:virtuomate_flutter/ui/screens/feedback_screen.dart';
import 'package:virtuomate_flutter/ui/screens/interview_screen.dart';
import 'package:virtuomate_flutter/ui/screens/presentation_screen.dart';
import 'package:virtuomate_flutter/ui/screens/premium_screen.dart';
import 'package:virtuomate_flutter/ui/screens/role_play_screen.dart';
import 'package:virtuomate_flutter/ui/screens/session_screen.dart';
import 'package:virtuomate_flutter/ui/screens/settings_screen.dart';
import 'package:virtuomate_flutter/ui/screens/user_config_screen.dart';
import 'package:virtuomate_flutter/ui/screens/video_cv_preview_screen.dart';
import 'package:virtuomate_flutter/ui/screens/video_cv_wizard_screen.dart';
import 'package:virtuomate_flutter/ui/screens/voice_active_screen.dart';
import 'package:virtuomate_flutter/ui/screens/voice_session_screen.dart';
import 'package:virtuomate_flutter/ui/virtuomate_runtime.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';







class VirtuoMateRoot extends StatefulWidget {
  const VirtuoMateRoot({super.key});

  @override
  State<VirtuoMateRoot> createState() => _VirtuoMateRootState();
}

class _VirtuoMateRootState extends State<VirtuoMateRoot> {
  late Future<_Deps> _depsFuture;

  @override
  void initState() {
    super.initState();
    _depsFuture = _buildDeps();
  }

  void _retryBootstrap() {
    setState(() => _depsFuture = _buildDeps());
  }

  Future<_Deps> _buildDeps() async {
    if (!AppConfig.useFirebase) {
      return _Deps(
        authGateway: InMemoryAuthGateway(),
        repository: InMemoryAppRepository(),
        firebaseEnabled: false,
        useBackendApi: false,
        coachEngine: MockCoachEngine(),
        subscriptionGateway: DemoSubscriptionGateway(),
        apiClient: null,
        onExportData: null,
        onDeleteAccount: null,
      );
    }

    try {
      await initFirebase();
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      if (AppConfig.useBackendApi) {
        final apiClient = ApiClient(
          baseUrl: AppConfig.backendBaseUrl,
          tokenProvider: () async => auth.currentUser?.getIdToken(),
        );
        NeuralConnectivityStatus? neuralStatus;
        String? bootstrapWarning;
        try {
          neuralStatus = await verifyBackendHealth(apiClient);
        } catch (e) {
          bootstrapWarning = e.toString().replaceFirst('Exception: ', '');
          neuralStatus = NeuralConnectivityStatus(
            percent: 0,
            full: false,
            mode: 'api-unreachable',
            layers: const [],
            errorMessage: bootstrapWarning,
            lastChecked: DateTime.now(),
          );
        }
        final apiRepo = ApiAppRepository(apiClient);
        return _Deps(
          authGateway: FirebaseAuthGateway(auth, demoApiClient: apiClient),
          repository: apiRepo,
          firebaseEnabled: true,
          useBackendApi: true,
          coachEngine: ApiCoachEngine(apiClient),
          subscriptionGateway: ApiSubscriptionGateway(apiClient),
          apiClient: apiClient,
          initialNeuralStatus: neuralStatus,
          bootstrapWarning: bootstrapWarning,
          onExportData: () => apiClient.postJson('/user/export', {}),
          onDeleteAccount: () async {
            final response = await apiClient.deleteJson('/user');
            return response['deleted'] == true;
          },
        );
      }

      final fbRepo = FirebaseAppRepository(firestore: firestore, auth: auth);
      return _Deps(
        authGateway: FirebaseAuthGateway(auth),
        repository: fbRepo,
        firebaseEnabled: true,
        useBackendApi: false,
        coachEngine: MockCoachEngine(),
        subscriptionGateway: DemoSubscriptionGateway(),
        apiClient: null,
        onExportData: null,
        onDeleteAccount: null,
        firebaseRepository: fbRepo,
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (kReleaseMode) {
        throw Exception(
          'VirtuoMate could not start cloud services: $msg\n'
          'Enable Email/Password + Google in Firebase Console (see USER_START.md).',
        );
      }
      return _Deps(
        authGateway: InMemoryAuthGateway(),
        repository: InMemoryAppRepository(),
        firebaseEnabled: false,
        useBackendApi: false,
        coachEngine: MockCoachEngine(),
        subscriptionGateway: DemoSubscriptionGateway(),
        apiClient: null,
        onExportData: null,
        onDeleteAccount: null,
        bootstrapWarning: 'Firebase failed to start: $msg',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Deps>(
      future: _depsFuture,
      builder: (context, snap) {
        if (snap.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 48, color: Colors.orange),
                      const SizedBox(height: 16),
                      const Text(
                        'VirtuoMate could not start',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${snap.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _retryBootstrap,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Starting VirtuoMate…'),
                  ],
                ),
              ),
            ),
          );
        }

        final deps = snap.data!;
        final service = AppService(
          authGateway: deps.authGateway,
          repository: deps.repository,
          coachEngine: deps.coachEngine,
          subscriptionGateway: deps.subscriptionGateway,
          neuralConnectivity: deps.apiClient != null
              ? NeuralConnectivityService(deps.apiClient!)
              : null,
          initialNeuralStatus: deps.initialNeuralStatus,
        );
        final controller = VirtuoMateController(
          service: service,
          firebaseAuthReady: deps.firebaseEnabled,
          bootstrapWarning: deps.bootstrapWarning,
          adminApi: deps.apiClient != null
              ? AdminApiService(deps.apiClient!)
              : null,
          storage: deps.apiClient != null
              ? StorageService(deps.apiClient)
              : null,
          videoCvRender: deps.apiClient != null
              ? VideoCvRenderService(deps.apiClient!)
              : null,
          onExportData: deps.onExportData,
          onDeleteAccount: deps.onDeleteAccount,
        );

        if (deps.firebaseEnabled) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              try {
                await service.bootstrapUserProfile();
                controller.applyStoredPreferences();
                controller.refreshData();
                if (!deps.useBackendApi && deps.firebaseRepository != null) {
                  controller.startRealtimeSync();
                }
              } catch (_) {}
            }
          });
        }

        return VirtuoMateScope(
          notifier: controller,
          child: _ProfileSyncHost(
            service: service,
            useBackendApi: deps.useBackendApi,
            onRefresh: controller.refreshData,
            child: VirtuoMateApp(
              firebaseEnabled: deps.firebaseEnabled,
              useBackendApi: deps.useBackendApi,
              bootstrapWarning: deps.bootstrapWarning,
            ),
          ),
        );
      },
    );
  }
}

class VirtuoMateApp extends StatelessWidget {
  const VirtuoMateApp({
    required this.firebaseEnabled,
    this.useBackendApi = false,
    this.bootstrapWarning,
    super.key,
  });

  final bool firebaseEnabled;
  final bool useBackendApi;
  final String? bootstrapWarning;

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    final baseTheme = ThemeData(
      colorSchemeSeed: Colors.indigo,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    final darkBase = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: VirtuoMvpColors.bg0,
      colorScheme: ColorScheme.fromSeed(
        seedColor: VirtuoMvpColors.purple,
        brightness: Brightness.dark,
        surface: VirtuoMvpColors.bg1,
      ),
    );
    return VirtuoMateRuntime(
      firebaseEnabled: firebaseEnabled,
      useBackendApi: useBackendApi,
      bootstrapWarning: bootstrapWarning,
      child: MaterialApp(
      title: 'VirtuoMate',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      locale: c.locale,
      supportedLocales: const [Locale('en'), Locale('ur')],
      theme: c.highContrast
          ? baseTheme.copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.black,
                brightness: Brightness.light,
                contrastLevel: 1,
              ),
            )
          : baseTheme,
      darkTheme: c.highContrast
          ? darkBase.copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: VirtuoMvpColors.cyan,
                brightness: Brightness.dark,
                contrastLevel: 1,
              ),
            )
          : darkBase,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(c.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (_) => WelcomeScreen(
              firebaseEnabled: firebaseEnabled,
              useBackendApi: useBackendApi,
            ),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => RegisterScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.avatar: (_) => const AvatarScreen(),
        AppRoutes.session: (_) => const SessionScreen(),
        AppRoutes.coachChat: (_) => const CoachChatScreen(),
        AppRoutes.voiceSession: (_) => const VoiceSessionScreen(),
        AppRoutes.voiceActive: (_) => const VoiceActiveScreen(),
        AppRoutes.interview: (_) => const InterviewScreen(),
        AppRoutes.presentation: (_) => const PresentationScreen(),
        AppRoutes.rolePlay: (_) => const RolePlayScreen(),
        AppRoutes.videoCv: (_) => const VideoCvWizardScreen(),
        AppRoutes.videoCvPreview: (_) => const VideoCvPreviewScreen(),
        AppRoutes.feedback: (_) => const FeedbackScreen(),
        AppRoutes.premium: (_) => const PremiumScreen(),
        AppRoutes.analytics: (_) => const AnalyticsScreen(),
        AppRoutes.achievements: (_) => const AchievementsScreen(),
        AppRoutes.userConfig: (_) => const UserConfigScreen(),
        AppRoutes.adminUsers: (_) => const AdminUserManagementScreen(),
        AppRoutes.adminTrainingAnalytics: (_) =>
            const AdminTrainingAnalyticsScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    ),
    );
  }
}


class _ProfileSyncHost extends StatefulWidget {
  const _ProfileSyncHost({
    required this.service,
    required this.useBackendApi,
    required this.onRefresh,
    required this.child,
  });

  final AppService service;
  final bool useBackendApi;
  final VoidCallback onRefresh;
  final Widget child;

  @override
  State<_ProfileSyncHost> createState() => _ProfileSyncHostState();
}

class _ProfileSyncHostState extends State<_ProfileSyncHost> {
  ProfileSyncService? _sync;

  @override
  void initState() {
    super.initState();
    if (widget.useBackendApi) {
      _sync = ProfileSyncService(widget.service)..start(widget.onRefresh);
    }
  }

  @override
  void dispose() {
    _sync?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _Deps {
  const _Deps({
    required this.authGateway,
    required this.repository,
    required this.firebaseEnabled,
    required this.useBackendApi,
    required this.coachEngine,
    required this.subscriptionGateway,
    required this.apiClient,
    required this.onExportData,
    required this.onDeleteAccount,
    this.firebaseRepository,
    this.initialNeuralStatus,
    this.bootstrapWarning,
  });

  final AuthGateway authGateway;
  final AppRepository repository;
  final bool firebaseEnabled;
  final bool useBackendApi;
  final CoachEngine coachEngine;
  final SubscriptionGateway subscriptionGateway;
  final ApiClient? apiClient;
  final FirebaseAppRepository? firebaseRepository;
  final Future<Map<String, dynamic>> Function()? onExportData;
  final Future<bool> Function()? onDeleteAccount;
  final NeuralConnectivityStatus? initialNeuralStatus;
  final String? bootstrapWarning;
}


