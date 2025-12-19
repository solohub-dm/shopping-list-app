import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/pages/login_page.dart';
import 'package:shopping_list_app/pages/register_page.dart';
import 'package:shopping_list_app/pages/dashboard_page.dart';
import 'package:shopping_list_app/pages/list_detail_page.dart';
import 'package:shopping_list_app/pages/history_page.dart';
import 'package:shopping_list_app/pages/settings_page.dart';
import 'package:shopping_list_app/services/app_store.dart';

class AppRouter {
  static GoRouter getRouter() {
    return GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
        GoRoute(
          path: '/list/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ListDetailPage(listId: id);
          },
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
      redirect: (context, state) {
        final store = Provider.of<AppStore>(context, listen: false);
        final isAuthenticated = store.session.isAuthenticated;
        final isLoginPage = state.matchedLocation == '/login';
        final isRegisterPage = state.matchedLocation == '/register';

        if (!isAuthenticated && !isLoginPage && !isRegisterPage) {
          return '/login';
        }

        if (isAuthenticated && (isLoginPage || isRegisterPage)) {
          return '/';
        }

        return null;
      },
    );
  }
}
