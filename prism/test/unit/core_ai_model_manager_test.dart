import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/ai/model_manager.dart';

void main() {
  test('ModelCatalogEntry download URL uses repo, branch, and filename', () {
    const entry = ModelCatalogEntry(
      name: 'Test Model',
      repo: 'owner/repo',
      fileName: 'model.gguf',
      sizeBytes: 1024,
      description: 'test',
      branch: 'main',
    );

    expect(
      entry.downloadUrl,
      'https://huggingface.co/owner/repo/resolve/main/model.gguf?download=true',
    );
  });

  test('ModelDownload copyWith updates fields', () {
    const download = ModelDownload(fileName: 'model.gguf');
    final updated = download.copyWith(progress: 0.5);

    expect(updated.progress, 0.5);
    expect(updated.fileName, 'model.gguf');
  });
}
