import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:payutc/src/api/assos_utc.dart';
import 'package:payutc/src/api/cas.dart';
import 'package:payutc/src/api/gescotiz.dart';
import 'package:payutc/src/api/ginger.dart';
import 'package:payutc/src/api/nemopay.dart';
import 'package:payutc/src/env.dart';
import 'package:payutc/src/models/ginger_user_infos.dart';
import 'package:payutc/src/models/nemopay_app_properties.dart';
import 'package:payutc/src/models/transfert.dart';
import 'package:payutc/src/models/user_data.dart';
import 'package:payutc/src/models/wallet.dart';
import 'package:payutc/src/services/history.dart';
import 'package:payutc/src/services/storage.dart';
import 'package:payutc/src/services/wallet.dart';

class AppService extends ChangeNotifier {
  static AppService? _instance;

  static AppService get instance {
    _instance ??= AppService();
    return _instance!;
  }

  late StorageService storageService;
  late HistoryService historyService;
  late final CasApi _casApi;
  late NemoPayApi nemoPayApi;
  late WalletService walletService;
  GesCotizApi? _gesCotizApi;

  AppService(
      {CasApi? casApi, NemoPayApi? nemoPayApi, StorageService? storageService})
      : _casApi = casApi ?? CasApi(),
        nemoPayApi = nemoPayApi ?? NemoPayApi(),
        storageService = storageService ?? StorageService() {
    historyService = HistoryService(this);
    walletService = WalletService(this);
  }

  Future<Map?> payMembership() async {
    return _gesCotizApi!.payMembership();
  }

  Future<bool> checkMembership() async {
    return _gesCotizApi!.checkMembership();
  }

  String? userName;

  bool get isConnected => storageService.haveToken && userName != null;

  Future<bool> get isFirstConnect =>
      storageService.haveAccount.then((value) => !value);

  late NemoPayAppProperties appProperties;

  Wallet? get userWallet => walletService.data;

  double get userAmount =>
      (historyService.history?.credit?.toDouble() ?? 0) / 100;

  Locale get currentLocale => storageService.locale;

  Brightness get brightness => Brightness.light;

  Owner get user => userWallet!.user;

  List<Semester> semesters = [];

  Future<bool> initApp() async {
    await storageService.init();
    UserData? d = (await storageService.userData);
    if (await isFirstConnect || d == null) return false;
    userName = await (d.isCas ? _casConnect() : _classicConnect());
    _gesCotizApi = GesCotizApi(nemoPayApi, userName!);
    appProperties = await nemoPayApi.getAppProperties();
    await walletService.forceLoad();
    await historyService.forceLoadHistory();
    semesters = await AssosUTC.getSemesters();
    //get ginger user infos
    try {
      await gingerUserInfos;
    } catch (_) {}
    //tryUpdateWidget
    _updateWidget();
    return true;
  }

  void setLocale(Locale locale) {
    storageService.locale = locale;
    notifyListeners();
  }

  Future<bool> connectUser(String user, String password,
      [bool casConnect = true]) async {
    await storageService.init();
    if (casConnect) {
      storageService.ticket = await _casApi.connectUser(user, password);
    } else {
      storageService.ticket = await nemoPayApi.connectUser(user, password);
    }
    await storageService.user(UserData.create(user, password, casConnect));
    return initApp();
  }

  String translateMoney(num num) {
    return "${num.toDouble().toStringAsFixed(2)}${appProperties.config?.currencySymbol}";
  }

  Future<void> refreshContent() async {
    await historyService.forceLoadHistory();
    await walletService.forceLoad();
    try {
      _gingerUserInfos = await getUserInfos();
    } catch (_) {}
    _updateWidget();
  }

  String generateShareLink() {
    final user = {
      "email": userWallet!.user.email!,
      "name": _generateUserName(userWallet!.user),
      "id": userWallet!.user.id!,
    };
    return "payutc://share.payutc.fr/transfert/${base64Encode(jsonEncode(user).codeUnits)}";
  }

  Future<bool> makeTransfert(Transfert transfert) async {
    bool res = await walletService.makeTransfert(transfert);

    return res;
  }

  _generateUserName(Owner user) {
    return "${user.firstName} ${user.lastName!.toUpperCase()} (${user.username})";
  }

  GingerUserInfos? _gingerUserInfos;

  Future<GingerUserInfos> get gingerUserInfos async {
    _gingerUserInfos ??= await getUserInfos();
    return _gingerUserInfos!;
  }

  Future<GingerUserInfos> getUserInfos() {
    // ignore: deprecated_member_use_from_same_package
    return Ginger.getUserInfos(userName!, gingerKey).then((value) {
      return value;
    });
  }

  Future<bool> changeBadgeState(bool value) => nemoPayApi.setBadgeState(value);

  Future<String> _casConnect() async {
    String ticket = "";
    try {
      ticket = await _casApi.reConnectUser(storageService.ticket);
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          UserData? d = await storageService.userData;
          if (d == null) rethrow;
          bool e = await connectUser(d.user, d.secret, d.isCas);
          if (e) {
            return _casConnect();
          }
        }
      }
    }
    return await nemoPayApi.connectCas(ticket);
  }

  Future<String> _classicConnect() async {
    UserData user = (await storageService.userData)!;
    try {
      return await nemoPayApi.connectUser(user.user, user.secret);
    } catch (e) {
      throw 'cas/bad-credentials';
    }
  }

  void _updateWidget() async {
    try {
      await HomeWidget.saveWidgetData<int>(
          'payutc_amount_value', walletService.data?.credit.toInt() ?? 0);
      await HomeWidget.saveWidgetData<String>('payutc_reload_time',
          "A jour le ${DateTime.now().day.toString().padLeft(2, "0")}/${DateTime.now().month.toString().padLeft(2, "0")} à ${DateTime.now().hour.toString().padLeft(2, "0")}:${DateTime.now().minute.toString().padLeft(2, "0")}");
      await HomeWidget.updateWidget(
          name: 'AmountWidget', iOSName: 'AppWidgetProvider');
    } catch (_) {}
  }
}
