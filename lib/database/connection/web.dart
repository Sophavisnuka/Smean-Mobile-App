import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor connect(String dbName) {
  return LazyDatabase(() async {
    // Use the simple helper method that handles everything
    final db = await WasmDatabase.open(
      databaseName: dbName,
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    return db.resolvedExecutor;
  });
}
