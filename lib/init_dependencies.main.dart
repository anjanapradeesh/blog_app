part of 'init_dependencies.dart';
final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

 serviceLocator.registerLazySingleton<SupabaseClient>(
    () => supabase.client,
  );


  

  final appDir = await getApplicationDocumentsDirectory();

Hive.init(appDir.path);

final blogBox = await Hive.openBox('blogs');

serviceLocator.registerLazySingleton<Box>(
  () => blogBox,
);


  serviceLocator.registerFactory(() => InternetConnection());
  //core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(serviceLocator()),
  );
  _initAuth();
  _initBlog();
}

  


void _initAuth() {
  //datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
  () {
    print("Supabase registered: ${serviceLocator.isRegistered<SupabaseClient>()}");
    return AuthRemoteDataSourceImpl(
      serviceLocator<SupabaseClient>(),
    );
  },
)
    //repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    //usecases
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    //bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initBlog() {
  //datasource
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
  () {
    print("Supabase registered: ${serviceLocator.isRegistered<SupabaseClient>()}");
    return BlogRemoteDataSourceImpl(
      serviceLocator<SupabaseClient>(),
    );
  },
)
    ..registerFactory<BlogLocalDataSource>(
      () => BlogLocalDataSourceImpl(
      serviceLocator(),
      ),
      )
    //repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    //usecases
    ..registerFactory(() => UploadBlog(
      serviceLocator()))
    //bloc
    ..registerFactory(() => GetAllBlogs(serviceLocator()))
    ..registerLazySingleton(
      () =>
          BlogBloc(uploadBlog: serviceLocator(), getAllBlogs: serviceLocator()),
    );
}
