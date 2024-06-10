import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ditto_plugin/ditto_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DittoPlugin', () {
    final dittoPlugin = DittoPlugin();
    const collectionName = 'test_collection';
    const documentId = 'test_document_id';

    setUp(() async {
      await dittoPlugin.initializeDitto('e39d315c-64ff-49bb-8954-a2690cc23f6c',
          'e1896c94-7851-46cc-a4d3-4a04042fbd39');
    });

    // testWidgets('setupWithDocument and verify data',
    //     (WidgetTester tester) async {
    //   // Gọi setupWithDocument
    //   final documentData = await dittoPlugin.setupWithDocument(collectionName, documentId);

    //   // Kiểm tra dữ liệu document
    //   expect(documentData, isNotNull); 
    //   if (documentData != null) { // Kiểm tra null trước khi truy cập key
    //     expect(documentData['key1'], 'value1');
    //     expect(documentData['key2'], 123);
    //   }
    // });
  });
}