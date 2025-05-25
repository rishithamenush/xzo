import 'package:flutter/material.dart';
import '../../view/view_layer.dart';
import '../../view/screens/admin_screens/workout_schedules_screen.dart';

// Class responsible for generating routes in the application
class MyRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initRoute:
        {
          return _route(SplashScreen());
        }


      case signIn:
        {
          return _route(LogIn());
        }

      case deleteUserPage:
        {
          return _route(DeleteUser());
        }

      case personalDetilsScreen:
        {
          return _route(PersonalDetailsScreen());
        }


      case notificationPage:
        {
          return _route(NotificationPage());
        }

      case changeInfo:
        {
          return _route(ChangeInfo());
        }

      case signUp:
        {
          return _route(SingUp());
        }

      case bottomNavRoute:
        {
          return _route(CustomeBottomNavBar());
        }

      case requestToBeExpertRoute:
        {
          return _route(const RequestToBeExpert());
        }
      //admin routes
      case signInAdminRoute:
        {
          return _route(const AdminSignIn());
        }
      case homeAdminRoute:
        {
          return _route(const AdminHomePage());
        }
      case requestsAdminRoute:
        {
          return _route(const RequestScreen());
        }
      case allReportsAdminRoute:
        {
          return _route(const ReportsScreen());
        }

      case workoutSchedulesAdminRoute:
        {
          return _route(WorkoutSchedulesScreen());
        }
      default:
        {
          final arg = settings.name as String;
          return _route(UndefineRoute(routeName: arg));
        }
    }
  }

// Helper method to create a MaterialPageRoute
  static MaterialPageRoute _route(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}

// Widget to display an undefined route error
class UndefineRoute extends StatelessWidget {
  const UndefineRoute({Key? key, required this.routeName}) : super(key: key);
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'This $routeName is Undefine Route',
        ),
      ),
    );
  }
}
