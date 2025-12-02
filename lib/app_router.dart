import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/main_shell.dart';

// Feature Screens
import 'features/home/presentation/pages/home_page.dart';
import 'features/orders/presentation/pages/shipping_orders_page.dart';
import 'features/orders/presentation/pages/pickup_orders_page.dart';
import 'features/orders/presentation/pages/order_details_page.dart';
import 'features/orders/domain/models/order_model.dart';
import 'features/orders/presentation/pages/orders_list_page.dart';
import 'features/gallery/gallery_screen.dart';
import 'features/gallery/album_screen.dart';
import 'features/encargo/encargo_home.dart';
import 'features/encargo/arreglo/arreglo_screen.dart';
import 'features/encargo/entrega/entrega_screen.dart';
import 'features/encargo/pago/pago_exitoso_screen.dart';
import 'features/encargo/pago/pago_screen.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';
import 'features/home/presentation/pages/welcome_page.dart';

import 'features/drafts/presentation/pages/drafts_page.dart';
import 'features/catalogs/presentation/pages/catalogs_page.dart';
import 'features/statistics/presentation/pages/statistics_page.dart';
import 'features/settings/presentation/pages/profile_page.dart';
import 'features/settings/presentation/pages/perfil_general_screen.dart';
import 'features/settings/presentation/pages/informacion_personal_screen.dart';
import 'features/settings/presentation/pages/direcciones_guardadas_screen.dart';

// New Customer Tracking Module
import 'features/customer_tracking/presentation/screens/customer_tracking_screen.dart';
import 'features/customer_tracking/presentation/screens/event_form_screen.dart';
import 'features/customer_tracking/domain/customer_event.dart';

// New Module
import 'modules/seguimiento_inteligente/seguimiento_inteligente_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // Routes that are outside of the shell
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomePage()),
    GoRoute(
      path: '/email-verification',
      builder: (context, state) {
        final email = state.extra as String? ?? 'no-email@example.com';
        return EmailVerificationPage(email: email);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
      routes: [
        GoRoute(
          path: 'informacion-personal',
          builder: (context, state) => const InformacionPersonalScreen(),
        ),
        GoRoute(
          path: 'direcciones-guardadas',
          builder: (context, state) => const DireccionesGuardadasScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/shipping-orders',
      builder: (context, state) => const ShippingOrdersPage(),
    ),
    GoRoute(
      path: '/pickup-orders',
      builder: (context, state) => const PickupOrdersPage(),
    ),
    GoRoute(
      path: '/order-details',
      builder: (context, state) {
        final order = state.extra as OrderModel;
        return OrderDetailsPage(order: order);
      },
    ),
    GoRoute(path: '/drafts', builder: (context, state) => const DraftsPage()),
    GoRoute(
      path: '/catalogs',
      builder: (context, state) => const CatalogsPage(),
    ),
    GoRoute(
      path: '/intelligent-tracking',
      builder: (context, state) => const SeguimientoInteligenteView(),
    ),
    GoRoute(
      path: '/encargo',
      builder: (context, state) => const EncargoHomeScreen(),
      routes: [
        GoRoute(
          path: 'arreglo',
          builder: (context, state) => const ArregloScreen(),
        ),
        GoRoute(
          path: 'entrega',
          builder: (context, state) => const EntregaScreen(),
        ),
        GoRoute(path: 'pago', builder: (context, state) => const PagoScreen()),
        GoRoute(
          path: 'pago-exitoso',
          builder: (context, state) {
            final deliveryType = state.extra as String?;
            return PagoExitosoScreen(deliveryType: deliveryType);
          },
        ),
      ],
    ),

    // Shell route for main app navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch for Home/Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Branch for Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersListPage(),
            ),
          ],
        ),
        // Branch for Customer Tracking
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer-tracking',
              builder: (context, state) => const CustomerTrackingScreen(),
              routes: [
                GoRoute(
                  path: 'add-event',
                  builder: (context, state) => const EventFormScreen(),
                ),
                GoRoute(
                  path: 'edit-event',
                  builder: (context, state) {
                    final event = state.extra as CustomerEvent?;
                    return EventFormScreen(event: event);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch for Gallery
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/gallery',
              builder: (context, state) => const GalleryScreen(),
              routes: [
                GoRoute(
                  path: 'album/:id',
                  builder: (context, state) {
                    final albumId = state.pathParameters['id']!;
                    return AlbumScreen(albumId: albumId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch for Statistics
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistics',
              builder: (context, state) => const StatisticsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Error: Ruta no encontrada ${state.error}')),
  ),
);
