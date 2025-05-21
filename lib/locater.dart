
import 'package:get_it/get_it.dart';
import 'package:l8fe/services/fire_api.dart';
import 'package:l8fe/services/test_api.dart';
import 'package:l8fe/view_models/crud_view_model.dart';
import 'package:l8fe/view_models/test_crud_model.dart';



GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => Api('users'));
  locator.registerLazySingleton(() => CRUDModel()) ;
  locator.registerLazySingleton(() => TestApi('tests'));
  locator.registerLazySingleton(() => TestCRUDModel());

}