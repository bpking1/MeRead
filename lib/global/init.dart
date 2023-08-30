import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:meread/global/data_migration/migration.dart';
import 'package:meread/global/global.dart';
import 'package:meread/models/feed.dart';
import 'package:meread/models/post.dart';
import 'package:meread/utils/font_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App 初始化
Future<void> init() async {
  /* Android 平台适配 */
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  /* 初始化全局变量 */
  prefs = await SharedPreferences.getInstance();
  final Directory dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [FeedSchema, PostSchema],
    directory: dir.path,
  );

  /* 读取主题字体 */
  readThemeFont();

  /* 数据库迁移 */
  int dbVersion = prefs.getInt('dbVersion') ?? 0;
  if (dbVersion == 0) {
    await migration();
    await prefs.setInt('dbVersion', 1);
  }
}