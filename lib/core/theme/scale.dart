/// Design tokens: spacing, radius, sizing, button heights, durations and fonts.
class Insets {
  Insets._();

  static const double i1 = 1;
  static const double i2 = 2;
  static const double i3 = 3;
  static const double i4 = 4;
  static const double i5 = 5;
  static const double i6 = 6;
  static const double i8 = 8;
  static const double i10 = 10;
  static const double i12 = 12;
  static const double i13 = 13;
  static const double i15 = 15;
  static const double i16 = 16;
  static const double i18 = 18;
  static const double i20 = 20;
  static const double i24 = 24;
  static const double i25 = 25;
  static const double i30 = 30;
  static const double i40 = 40;
  static const double i55 = 55;
  static const double i60 = 60;
}

class AppRadius {
  AppRadius._();

  static const double r6 = 6;
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r14 = 14;
  static const double r16 = 16;
  static const double r24 = 24;
}

class Sizes {
  Sizes._();

  static const double s1 = 1;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s36 = 36;
  static const double s40 = 40;
  static const double s44 = 44;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s60 = 60;
  static const double s64 = 64;
  static const double s72 = 72;
  static const double s80 = 80;
  static const double s90 = 90;
  static const double s100 = 100;
  static const double s120 = 120;
  static const double s140 = 140;
  static const double s160 = 160;
  static const double s180 = 180;
  static const double s200 = 200;
  static const double s240 = 240;
  static const double s280 = 280;
  static const double s320 = 320;
  static const double s360 = 360;
  static const double s400 = 400;
  static const double s600 = 600;
}

class FontSizes {
  FontSizes._();

  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
}

class ButtonHeight {
  ButtonHeight._();

  static const double h50 = 50;
}

class CustomDurations {
  CustomDurations._();

  static const Duration fastest = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 700);
  static const Duration slower = Duration(milliseconds: 1000);
  static const Duration slowest = Duration(milliseconds: 5000);
}

class Fonts {
  Fonts._();

  // No bundled font asset yet: this name is unresolved so Flutter falls back
  // to the platform default font family. Swap in a real "Inter" (or a
  // rounder/playful) font by adding font assets + a `fonts:` entry later.
  static const String inter = 'Inter';
}
