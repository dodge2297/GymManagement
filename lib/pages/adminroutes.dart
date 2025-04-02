import 'package:flutter/material.dart';
import 'package:gym_track/pages/adminpage.dart';
import 'package:gym_track/pages/adminNotificationsPage.dart';
import 'package:gym_track/pages/adminUserDetailsPage.dart';
import 'package:gym_track/pages/adminUserListPage.dart';
import 'package:gym_track/pages/adminUserManagementPage.dart';

class AdminRoutes {
  static const String adminHome = '/admin';
  static const String adminNotifications = '/admin/notifications';
  static const String adminUserManagement = '/admin/user_management';
  static const String adminUserDetails = '/admin/user_details';
  static const String adminUserList = '/admin/user_list';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminPage());
      case adminNotifications:
        return MaterialPageRoute(
            builder: (_) => const AdminNotificationsPage());
      case adminUserManagement:
        final isAdmin = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => AdminUserManagementPage(isAdmin: isAdmin),
        );
      case adminUserDetails:
        if (settings.arguments is String) {
          return MaterialPageRoute(
            builder: (_) =>
                AdminUserDetailsPage(userId: settings.arguments as String),
          );
        }
        return _errorRoute('Error: No user ID provided');
      case adminUserList:
        return MaterialPageRoute(builder: (_) => const AdminUserListPage());
      default:
        return _errorRoute('Admin Page Not Found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute([String message = 'Admin Page Not Found']) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(message, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
