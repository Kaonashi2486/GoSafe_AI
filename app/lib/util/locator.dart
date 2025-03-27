import 'package:get_it/get_it.dart';
import 'package:hacknova/model/user_model.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register your classes here
  locator.registerLazySingleton(() => UserDataService());
}
