/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsAnimationsGen {
  const $AssetsAnimationsGen();

  /// File path: assets/animations/chat_animation.json
  String get chatAnimation => 'assets/animations/chat_animation.json';

  /// File path: assets/animations/onboarding_animation.json
  String get onboardingAnimation =>
      'assets/animations/onboarding_animation.json';

  /// File path: assets/animations/sms_animation.json
  String get smsAnimation => 'assets/animations/sms_animation.json';

  /// List of all assets
  List<String> get values => [chatAnimation, onboardingAnimation, smsAnimation];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/chat.svg
  String get chat => 'assets/images/chat.svg';

  /// File path: assets/images/flutter.png
  AssetGenImage get flutter => const AssetGenImage('assets/images/flutter.png');

  /// File path: assets/images/onboarding_top_corner.png
  AssetGenImage get onboardingTopCorner =>
      const AssetGenImage('assets/images/onboarding_top_corner.png');

  /// File path: assets/images/stream_logo.png
  AssetGenImage get streamLogo =>
      const AssetGenImage('assets/images/stream_logo.png');

  /// File path: assets/images/user.png
  AssetGenImage get user => const AssetGenImage('assets/images/user.png');

  /// List of all assets
  List<dynamic> get values => [
    chat,
    flutter,
    onboardingTopCorner,
    streamLogo,
    user,
  ];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const $AssetsAnimationsGen animations = $AssetsAnimationsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();

  /// List of all assets
  static List<String> get values => [aEnv];
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
