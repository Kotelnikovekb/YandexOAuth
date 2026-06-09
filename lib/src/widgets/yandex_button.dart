// Keep MaterialStateProperty for Flutter 3.3 compatibility.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

const Color _yandexRed = Color(0xFFFC3F1D);
const Color _yandexBlack = Color(0xFF000000);
const Color _lightAdditionalBackground = Color(0xFFF2F3F5);
const Color _darkAdditionalBackground = Color(0xFF2B2D33);
const Color _disabledBackground = Color(0xFFB3B3B3);
const double _sourceLogoSize = 44;
const double _defaultButtonAspectRatio = 260 / 56;

enum YandexButtonSize {
  xs(36),
  s(40),
  m(44),
  l(48),
  xl(52),
  xxl(56);

  const YandexButtonSize(this.height);

  final double height;
}

enum YandexButtonType {
  main,
  additional,
  icon,
  iconBg,
}

enum YandexButtonTheme {
  light,
  dark,
}

enum YandexButtonIconType {
  ya,
  yaEng,
}

enum YandexButtonIconStyle {
  square,
  rounded,
  circle,
}

class YandexButton extends StatelessWidget {
  const YandexButton({
    super.key,
    required this.onPressed,
    this.type = YandexButtonType.main,
    this.theme,
    this.size = YandexButtonSize.xxl,
    this.iconType = YandexButtonIconType.ya,
    this.iconStyle = YandexButtonIconStyle.circle,
    this.text = 'Войти с Яндекс ID',
    this.avatar,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor = _disabledBackground,
    this.borderRadius = 0,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  const YandexButton.main({
    super.key,
    required this.onPressed,
    this.theme,
    this.size = YandexButtonSize.xxl,
    this.iconType = YandexButtonIconType.ya,
    this.iconStyle = YandexButtonIconStyle.circle,
    this.text = 'Войти с Яндекс ID',
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor = _disabledBackground,
    this.borderRadius = 0,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  })  : type = YandexButtonType.main,
        avatar = null;

  const YandexButton.additional({
    super.key,
    required this.onPressed,
    this.theme,
    this.size = YandexButtonSize.m,
    this.iconType = YandexButtonIconType.ya,
    this.iconStyle = YandexButtonIconStyle.circle,
    this.text = 'Войти с Яндекс ID',
    this.avatar,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor = _disabledBackground,
    this.borderRadius = 0,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  }) : type = YandexButtonType.additional;

  const YandexButton.icon({
    super.key,
    required this.onPressed,
    this.type = YandexButtonType.iconBg,
    this.theme,
    this.size = YandexButtonSize.m,
    this.iconType = YandexButtonIconType.ya,
    this.iconStyle = YandexButtonIconStyle.rounded,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor = _disabledBackground,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  })  : text = null,
        avatar = null,
        width = null,
        borderRadius = null;

  const YandexButton.iconBg({
    super.key,
    required this.onPressed,
    this.theme,
    this.size = YandexButtonSize.m,
    this.iconType = YandexButtonIconType.ya,
    this.iconStyle = YandexButtonIconStyle.rounded,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor = _disabledBackground,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  })  : type = YandexButtonType.iconBg,
        text = null,
        avatar = null,
        width = null,
        borderRadius = null;

  const YandexButton.iconOnly({
    super.key,
    required this.onPressed,
    this.theme,
    this.size = YandexButtonSize.m,
    this.iconType = YandexButtonIconType.ya,
    this.iconStyle = YandexButtonIconStyle.circle,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor = _disabledBackground,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  })  : type = YandexButtonType.icon,
        text = null,
        avatar = null,
        width = null,
        borderRadius = null;

  final VoidCallback? onPressed;
  final YandexButtonType type;
  final YandexButtonTheme? theme;
  final YandexButtonSize size;
  final YandexButtonIconType iconType;
  final YandexButtonIconStyle iconStyle;
  final String? text;
  final ImageProvider? avatar;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color disabledBackgroundColor;
  final double? borderRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? _themeFromContext(context);
    final colors = _YandexButtonColors.resolve(
      type: type,
      theme: effectiveTheme,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
    );
    final buttonSize = size.height;
    final isIconOnly = type == YandexButtonType.icon ||
        type == YandexButtonType.iconBg ||
        text == null;
    final effectiveWidth = isIconOnly
        ? buttonSize
        : width ?? buttonSize * _defaultButtonAspectRatio;
    final effectiveBorderRadius =
        isIconOnly ? _iconRadius(buttonSize) : borderRadius ?? 0;

    return SizedBox(
      width: effectiveWidth,
      height: buttonSize,
      child: Semantics(
        button: true,
        label: semanticLabel ?? text ?? 'Yandex',
        child: TextButton(
          onPressed: onPressed,
          focusNode: focusNode,
          autofocus: autofocus,
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            minimumSize: MaterialStateProperty.all(Size.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
              ),
            ),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return colors.disabledBackground;
              }
              return colors.background;
            }),
            foregroundColor: MaterialStateProperty.all(colors.foreground),
            overlayColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return colors.foreground.withOpacity(0.12);
              }
              if (states.contains(MaterialState.hovered)) {
                return colors.foreground.withOpacity(0.08);
              }
              if (states.contains(MaterialState.focused)) {
                return colors.foreground.withOpacity(0.10);
              }
              return null;
            }),
          ),
          child: isIconOnly
              ? _YandexIconButtonContent(
                  type: type,
                  size: buttonSize,
                  iconType: iconType,
                  iconStyle: iconStyle,
                  colors: colors,
                  enabled: onPressed != null,
                )
              : _YandexButtonContent(
                  type: type,
                  size: buttonSize,
                  text: text!,
                  iconType: iconType,
                  avatar: avatar,
                  colors: colors,
                ),
        ),
      ),
    );
  }

  YandexButtonTheme _themeFromContext(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? YandexButtonTheme.dark
        : YandexButtonTheme.light;
  }

  double _iconRadius(double buttonSize) {
    switch (iconStyle) {
      case YandexButtonIconStyle.square:
        return 0;
      case YandexButtonIconStyle.rounded:
        return buttonSize * 12 / _sourceLogoSize;
      case YandexButtonIconStyle.circle:
        return buttonSize / 2;
    }
  }
}

class _YandexButtonColors {
  const _YandexButtonColors({
    required this.background,
    required this.foreground,
    required this.logoBackground,
    required this.logoForeground,
    required this.disabledBackground,
  });

  factory _YandexButtonColors.resolve({
    required YandexButtonType type,
    required YandexButtonTheme theme,
    required Color? backgroundColor,
    required Color? foregroundColor,
    required Color disabledBackgroundColor,
  }) {
    final isDark = theme == YandexButtonTheme.dark;
    final defaultForeground = isDark ? Colors.white : _yandexBlack;

    switch (type) {
      case YandexButtonType.main:
        return _YandexButtonColors(
          background: backgroundColor ?? (isDark ? Colors.white : _yandexBlack),
          foreground: foregroundColor ?? (isDark ? _yandexBlack : Colors.white),
          logoBackground: _yandexRed,
          logoForeground: Colors.white,
          disabledBackground: disabledBackgroundColor,
        );
      case YandexButtonType.additional:
        return _YandexButtonColors(
          background: backgroundColor ??
              (isDark ? _darkAdditionalBackground : _lightAdditionalBackground),
          foreground: foregroundColor ?? defaultForeground,
          logoBackground: _yandexRed,
          logoForeground: Colors.white,
          disabledBackground: disabledBackgroundColor,
        );
      case YandexButtonType.icon:
        return _YandexButtonColors(
          background: backgroundColor ?? Colors.transparent,
          foreground: foregroundColor ?? defaultForeground,
          logoBackground: Colors.transparent,
          logoForeground: foregroundColor ?? defaultForeground,
          disabledBackground: backgroundColor ?? Colors.transparent,
        );
      case YandexButtonType.iconBg:
        return _YandexButtonColors(
          background: backgroundColor ?? _yandexRed,
          foreground: foregroundColor ?? Colors.white,
          logoBackground: backgroundColor ?? _yandexRed,
          logoForeground: foregroundColor ?? Colors.white,
          disabledBackground: disabledBackgroundColor,
        );
    }
  }

  final Color background;
  final Color foreground;
  final Color logoBackground;
  final Color logoForeground;
  final Color disabledBackground;
}

class _YandexButtonContent extends StatelessWidget {
  const _YandexButtonContent({
    required this.type,
    required this.size,
    required this.text,
    required this.iconType,
    required this.avatar,
    required this.colors,
  });

  final YandexButtonType type;
  final double size;
  final String text;
  final YandexButtonIconType iconType;
  final ImageProvider? avatar;
  final _YandexButtonColors colors;

  @override
  Widget build(BuildContext context) {
    final scale = size / 56;
    final logoSize = 24 * scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _YandexLogoIcon(
            size: logoSize,
            iconType: iconType,
            iconStyle: YandexButtonIconStyle.circle,
            backgroundColor: colors.logoBackground,
            logoColor: colors.logoForeground,
          ),
          SizedBox(width: 12 * scale),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
          if (type == YandexButtonType.additional && avatar != null) ...[
            SizedBox(width: 12 * scale),
            _YandexAvatar(size: logoSize, image: avatar!),
          ],
        ],
      ),
    );
  }
}

class _YandexIconButtonContent extends StatelessWidget {
  const _YandexIconButtonContent({
    required this.type,
    required this.size,
    required this.iconType,
    required this.iconStyle,
    required this.colors,
    required this.enabled,
  });

  final YandexButtonType type;
  final double size;
  final YandexButtonIconType iconType;
  final YandexButtonIconStyle iconStyle;
  final _YandexButtonColors colors;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final logoSize = type == YandexButtonType.icon ? size * 0.64 : size;

    return _YandexLogoIcon(
      size: logoSize,
      iconType: iconType,
      iconStyle: type == YandexButtonType.icon
          ? YandexButtonIconStyle.circle
          : iconStyle,
      backgroundColor:
          enabled ? colors.logoBackground : colors.disabledBackground,
      logoColor: colors.logoForeground,
    );
  }
}

class _YandexAvatar extends StatelessWidget {
  const _YandexAvatar({required this.size, required this.image});

  final double size;
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: image, fit: BoxFit.cover),
      ),
    );
  }
}

class _YandexLogoIcon extends StatelessWidget {
  const _YandexLogoIcon({
    required this.size,
    required this.iconType,
    required this.iconStyle,
    required this.backgroundColor,
    required this.logoColor,
  });

  final double size;
  final YandexButtonIconType iconType;
  final YandexButtonIconStyle iconStyle;
  final Color backgroundColor;
  final Color logoColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _YandexLogoPainter(
          iconType: iconType,
          iconStyle: iconStyle,
          backgroundColor: backgroundColor,
          logoColor: logoColor,
        ),
      ),
    );
  }
}

class _YandexLogoPainter extends CustomPainter {
  const _YandexLogoPainter({
    required this.iconType,
    required this.iconStyle,
    required this.backgroundColor,
    required this.logoColor,
  });

  final YandexButtonIconType iconType;
  final YandexButtonIconStyle iconStyle;
  final Color backgroundColor;
  final Color logoColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _sourceLogoSize;
    canvas.save();
    canvas.scale(scale, scale);

    final backgroundPaint = Paint()..color = backgroundColor;
    final logoPaint = Paint()
      ..color = logoColor
      ..style = PaintingStyle.fill;

    switch (iconStyle) {
      case YandexButtonIconStyle.square:
        canvas.drawRect(
          const Rect.fromLTWH(0, 0, _sourceLogoSize, _sourceLogoSize),
          backgroundPaint,
        );
        canvas.drawPath(_logoPath(iconType), logoPaint);
        break;
      case YandexButtonIconStyle.rounded:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, _sourceLogoSize, _sourceLogoSize),
            const Radius.circular(12),
          ),
          backgroundPaint,
        );
        canvas.drawPath(_logoPath(iconType), logoPaint);
        break;
      case YandexButtonIconStyle.circle:
        canvas.drawCircle(
          const Offset(_sourceLogoSize / 2, _sourceLogoSize / 2),
          _sourceLogoSize / 2,
          backgroundPaint,
        );
        canvas.drawPath(_logoPath(iconType, circle: true), logoPaint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _YandexLogoPainter oldDelegate) {
    return oldDelegate.iconType != iconType ||
        oldDelegate.iconStyle != iconStyle ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.logoColor != logoColor;
  }
}

Path _logoPath(YandexButtonIconType iconType, {bool circle = false}) {
  switch (iconType) {
    case YandexButtonIconType.ya:
      return circle ? _circleLogoPath() : _standardLogoPath();
    case YandexButtonIconType.yaEng:
      return _englishLogoPath();
  }
}

Path _standardLogoPath() {
  return Path()
    ..moveTo(24.7406, 33.9778)
    ..lineTo(29.0888, 33.9778)
    ..lineTo(29.0888, 9.04445)
    ..lineTo(22.7591, 9.04445)
    ..cubicTo(16.3928, 9.04445, 13.0537, 12.303, 13.0537, 17.1176)
    ..cubicTo(13.0537, 21.2731, 15.2186, 23.6164, 19.0531, 26.1609)
    ..lineTo(21.3831, 27.6987)
    ..lineTo(18.3926, 25.1907)
    ..lineTo(12.4666, 33.9778)
    ..lineTo(17.1817, 33.9778)
    ..lineTo(23.5113, 24.5317)
    ..lineTo(21.3097, 23.0672)
    ..cubicTo(18.6494, 21.2731, 17.3468, 19.8818, 17.3468, 16.8613)
    ..cubicTo(17.3468, 14.2069, 19.2182, 12.4128, 22.7775, 12.4128)
    ..lineTo(24.7222, 12.4128)
    ..lineTo(24.7222, 33.9778)
    ..lineTo(24.7406, 33.9778)
    ..close();
}

Path _englishLogoPath() {
  return Path()
    ..moveTo(22.9515, 24.2897)
    ..cubicTo(24.2907, 27.223, 24.737, 28.2433, 24.737, 31.7665)
    ..lineTo(24.737, 36.4375)
    ..lineTo(19.9544, 36.4375)
    ..lineTo(19.9544, 28.5621)
    ..lineTo(10.9313, 8.9375)
    ..lineTo(15.9211, 8.9375)
    ..lineTo(22.9515, 24.2897)
    ..close()
    ..moveTo(28.8501, 8.9375)
    ..lineTo(22.9994, 22.2332)
    ..lineTo(27.8617, 22.2332)
    ..lineTo(33.7284, 8.9375)
    ..lineTo(28.8501, 8.9375)
    ..close();
}

Path _circleLogoPath() {
  return Path()
    ..moveTo(25.2438, 12.3208)
    ..lineTo(23.0173, 12.3208)
    ..cubicTo(19.2005, 12.3208, 17.292, 14.2292, 17.292, 17.0919)
    ..cubicTo(17.292, 20.2726, 18.5643, 21.863, 21.427, 23.7714)
    ..lineTo(23.6535, 25.3618)
    ..lineTo(17.292, 35.222)
    ..lineTo(12.2029, 35.222)
    ..lineTo(18.2463, 26.316)
    ..cubicTo(14.7475, 23.7714, 12.839, 21.5449, 12.839, 17.41)
    ..cubicTo(12.839, 12.3208, 16.3378, 8.82202, 23.0173, 8.82202)
    ..lineTo(29.6969, 8.82202)
    ..lineTo(29.6969, 35.222)
    ..lineTo(25.2438, 35.222)
    ..lineTo(25.2438, 12.3208)
    ..close();
}
