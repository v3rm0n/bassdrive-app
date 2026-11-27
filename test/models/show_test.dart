import 'package:bassdrive_radio/models/show.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('archive shows skip folders and text files but keep extensionless audio',
      () {
    final filenames = ['2006/', 'test.txt', 'Mix.mp3', 'Extensionless mix'];
    final show = Show.fromJson({
      'name': 'Show',
      'episodes': [
        for (final filename in filenames)
          {
            'name': filename,
            'show': 'Show',
            'url': 'http://archives.bassdrivearchive.com/Show/$filename',
            'encodedUrl':
                'http://archives.bassdrivearchive.com/Show/${Uri.encodeFull(filename)}',
          },
      ],
    });

    expect(
      show.episodes.map((episode) => episode.name),
      ['Mix.mp3', 'Extensionless mix'],
    );
  });
}
