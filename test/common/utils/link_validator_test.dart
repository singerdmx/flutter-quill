import 'package:flutter_quill/src/common/utils/link_validator.dart';
import 'package:test/test.dart';

const _validTesingLinks = [
  'http://google.com',
  'https://www.google.com',
  'http://beginner.example.edu/#act',
  'http://beginner.example.edu#act',
  'https://birth.example.net/beds/ants.php#bait',
  'http://example.com/babies',
  'https://www.example.com/',
  'https://attack.example.edu/?acoustics=blade&bed=bed',
  'https://attack.example.edu?acoustics=blade&bed=bed',
  'http://basketball.example.com/',
  'https://birthday.example.com/birthday',
  'http://www.example.com/',
  'https://example.com/addition/action',
  'http://example.com/',
  'https://bite.example.net/#adjustment',
  'https://bite.example.net#adjustment',
  'http://www.example.net/badge.php?bedroom=anger',
  'https://brass.example.com/?anger=branch&actor=amusement#adjustment',
  'https://brass.example.com?anger=branch&actor=amusement#adjustment',
  'http://www.example.com/?action=birds&brass=apparatus',
  'http://www.example.com?action=birds&brass=apparatus',
  'https://example.net/',
  'mailto:test@example.com',
  'tel:+1234567890',
  'sms:+1234567890',
  'callto:+1234567890',
  'wtai://wp/mc;1234567890',
  'market://details?id=com.example.app',
  'geopoint:37.7749,-122.4194',
  'ymsgr:sendIM?user=testuser',
  'msnim:chat?contact=testuser',
  'gtalk://talk.google.com/talk?jid=testuser@gmail.com',
  'skype:live:testuser?chat',
  'sip:username@domain.com',
  'whatsapp://send?phone=+1234567890',
];

void main() {
  test('validate correctly', () {
    for (final validLink in _validTesingLinks) {
      expect(LinkValidator.validate(validLink), true,
          reason: 'Expected the link `$validLink` to be valid.');
    }
  });

  test('returns false when link is empty', () {
    expect(LinkValidator.validate(''), false);
    expect(LinkValidator.validate('   '), false);
  });

  test('calls customValidateLink and returns the result when not null', () {
    var customCallbackCalled = false;
    var mockResult = false;

    bool testCallback(link) {
      customCallbackCalled = true;
      return mockResult;
    }

    expect(LinkValidator.validate('example', customValidateLink: testCallback),
        mockResult);
    expect(customCallbackCalled, true);

    mockResult = true;
    expect(LinkValidator.validate('example', customValidateLink: testCallback),
        mockResult);
  });

  test('supports legacyRegex when not null', () {
    final exampleRegex = RegExp(r'\d{3}'); // Matches a 3-digit number
    expect(LinkValidator.validate('link', legacyRegex: exampleRegex), false);
    expect(LinkValidator.validate('412', legacyRegex: exampleRegex), true);
  });

  test('supports legacyAddationalLinkPrefixes', () {
    expect(
        LinkValidator.validate('app://example',
            legacyAddationalLinkPrefixes: ['app://']),
        true);
  });

  test('default linkPrefixes', () {
    expect(LinkValidator.linkPrefixes, [
      'mailto:',
      'tel:',
      'sms:',
      'callto:',
      'wtai:',
      'market:',
      'geopoint:',
      'ymsgr:',
      'msnim:',
      'gtalk:',
      'skype:',
      'sip:',
      'whatsapp:',
      'http://',
      'https://'
    ]);
  });
}
