// ignore_for_file: deprecated_member_use

import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor connect(String dbName) {
  // Use WebDatabase with sql.js backend (loaded via CDN in index.html)
  // This provides SQLite functionality on web browsers
  return WebDatabase(dbName, logStatements: true);
}
