import 'dart:convert';

/// A codec for encoding and decoding objects for navigation
///
/// This is used to pass state objects between screens during navigation
/// via GoRouter's extra parameter.
class NavigationStateCodec extends Codec<Object?, Object?> {
  @override
  Converter<Object?, Object?> get decoder => _NavigationStateDecoder();

  @override
  Converter<Object?, Object?> get encoder => _NavigationStateEncoder();

  /// Encodes a map of state data into a JSON string
  ///
  /// This allows complex state objects to be passed via navigation parameters
  ///
  /// @param data The map of state data to encode
  /// @return A JSON string representation of the data
  static String encodeMap(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      // Fallback to empty state if encoding fails
      return '{}';
    }
  }

  /// Decodes a JSON string into a map of state data
  ///
  /// @param jsonString The JSON string to decode
  /// @return A map representing the state
  static Map<String, dynamic> decodeString(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Return empty map if decoding fails
      return {};
    }
  }
}

/// Encoder for state objects
class _NavigationStateEncoder extends Converter<Object?, Object?> {
  @override
  Object? convert(Object? input) {
    if (input is Map<String, dynamic>) {
      return NavigationStateCodec.encodeMap(input);
    }
    return input;
  }
}

/// Decoder for state objects
class _NavigationStateDecoder extends Converter<Object?, Object?> {
  @override
  Object? convert(Object? input) {
    if (input is String) {
      return NavigationStateCodec.decodeString(input);
    }
    return input;
  }
} 