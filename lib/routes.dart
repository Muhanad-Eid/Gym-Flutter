import 'package:flutter/material.dart';
import 'package:gym/screens/subscriptions.dart';
import 'package:gym/screens/schedule.dart';
import 'package:gym/screens/reservation.dart';
import 'package:gym/screens/reports.dart';
import 'package:gym/screens/trainers.dart';
import 'package:gym/screens/sign_up.dart';
import 'package:gym/screens/forgot_password.dart';
import 'package:gym/screens/home.dart';
import 'package:gym/screens/subscribers.dart';
import 'package:gym/screens/sign_in.dart';

final Map<String, WidgetBuilder> routes = {
  '/sign_in': (context) => const SignIn(),
  '/sign_up': (context) => const SignUp(),
  '/home': (context) => const GymHomePage(),
  '/subscribers': (context) => const SubscribersPage(),
  '/subscriptions': (context) => const SubscriptionsPlansPage(),
  '/schedule': (context) => const SchedulePage(),
  '/reservation': (context) => const ReservationPage(),
  '/reports': (context) => const ReportsPage(),
  '/trainers': (context) => const TrainersPage(),
  '/forgot_password': (context) => const ForgotPassword(),
};
