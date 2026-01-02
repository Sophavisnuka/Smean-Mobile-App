import 'package:drift/drift.dart';

// Conditional imports - automatically picks the right one!
import 'web.dart' if (dart.library.io) 'native.dart' as impl;

QueryExecutor connect(String dbName) {
  return impl.connect(dbName);
}
