import 'package:flutter/material.dart';

extension WhenExtension<DATA> on AsyncSnapshot<DATA> {
  T when<T>({
    required T Function(DATA data) onSuccess,
    required T Function(Object error) onError,
    required T Function() onLoading,
  }) {
    final currentData = data;
    if (currentData != null) {
      return onSuccess(currentData);
    } else if (hasError) {
      return onError(error!);
    } else {
      return onLoading();
    }
  }
}
