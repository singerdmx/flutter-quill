@internal
library;

import 'package:meta/meta.dart';

/// {@template link_validation_callback}
/// A callback to validate whether the [link] is valid.
///
/// The [link] is passed to the callback, which should return `true` if valid,
/// or `false` otherwise.
///
/// Example:
///
/// ```dart
/// validateLink: (link) {
///   if (link.startsWith('ws')) {
///     return true; // WebSocket links are considered valid
///   }
///   final regex = RegExp(r'^(http|https)://[a-zA-Z0-9.-]+');
///   return regex.hasMatch(link);
/// }
/// ```
///
/// Return `null` to fallback to the default handling:
///
/// ```dart
/// validateLink: (link) {
///   if (link.startsWith('custom')) {
///     return true;
///   }
///   return null;
/// }
/// ```
///
/// Another example to allow inserting any link:
///
/// ```dart
/// validateLink: (link) {
///   // Treats all links as valid. When launching the URL,
///   // `https://` is prefixed if the link is incomplete (e.g., `google.com` → `https://google.com`)
///   // however this happens only within the editor level and the
///   // the URL will be stored as:
///   // {insert: ..., attributes: {link: google.com}}
///   return true;
/// }
/// ```
///
/// NOTE: The link will always be considered invalid if empty, and this callback will
/// not be called.
///
/// {@endtemplate}
typedef LinkValidationCallback = bool? Function(String link);

abstract final class LinkValidator {
  static const linkPrefixes = [
    'mailto:', // email
    'tel:', // telephone
    'sms:', // SMS
    'callto:',
    'wtai:',
    'market:',
    'geopoint:',
    'ymsgr:',
    'msnim:',
    'gtalk:', // Google Talk
    'skype:',
    'sip:', // Lync
    'whatsapp:',
    'http://',
    'https://'
  ];

  static bool validate(
    String link, {
    LinkValidationCallback? customValidateLink,
    RegExp? legacyRegex,
    List<String>? legacyAddationalLinkPrefixes,
  }) {
    if (link.trim().isEmpty) {
      return false;
    }
    if (customValidateLink != null) {
      final isValid = customValidateLink(link);
      if (isValid != null) {
        return isValid;
      }
    }
    // Implemented for backward compatibility, clients should use validateLink instead.
    // ignore: deprecated_member_use_from_same_package
    final legacyRegexp = legacyRegex;
    if (legacyRegexp?.hasMatch(link) == true) {
      return true;
    }
    // Implemented for backward compatibility, clients should use validateLink instead.
    return (linkPrefixes + (legacyAddationalLinkPrefixes ?? []))
        .any((prefix) => link.startsWith(prefix));
  }
}
