// Mocks generated by Mockito 5.4.4 from annotations
// in dima_project/test/widget/pages/settings_page_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:ui' as _i5;

import 'package:dima_project/services/fcm_settings_service.dart' as _i6;
import 'package:dima_project/theme/theme_provider.dart' as _i3;
import 'package:flutter/material.dart' as _i4;
import 'package:logger/logger.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeLogger_0 extends _i1.SmartFake implements _i2.Logger {
  _FakeLogger_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ThemeProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockThemeProvider extends _i1.Mock implements _i3.ThemeProvider {
  MockThemeProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Logger get logger => (super.noSuchMethod(
        Invocation.getter(#logger),
        returnValue: _FakeLogger_0(
          this,
          Invocation.getter(#logger),
        ),
      ) as _i2.Logger);

  @override
  _i4.ThemeMode get themeMode => (super.noSuchMethod(
        Invocation.getter(#themeMode),
        returnValue: _i4.ThemeMode.system,
      ) as _i4.ThemeMode);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  void setThemeMode(_i4.ThemeMode? themeMode) => super.noSuchMethod(
        Invocation.method(
          #setThemeMode,
          [themeMode],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void loadThemeMode() => super.noSuchMethod(
        Invocation.method(
          #loadThemeMode,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addListener(_i5.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i5.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [FCMSettingsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockFCMSettingsService extends _i1.Mock
    implements _i6.FCMSettingsService {
  MockFCMSettingsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<bool> isPushNotificationsEnabled() => (super.noSuchMethod(
        Invocation.method(
          #isPushNotificationsEnabled,
          [],
        ),
        returnValue: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<void> setPushNotificationsEnabled(bool? enabled) =>
      (super.noSuchMethod(
        Invocation.method(
          #setPushNotificationsEnabled,
          [enabled],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}
