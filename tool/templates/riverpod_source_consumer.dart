// Version: 3.0.0

import 'dart:async';

import 'package:flutter/widgets.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/src/internals.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension type SourceWidgetRef._(_SourceConsumerStatefulElement _element)
    implements SourceRef, WidgetRef {}

class SourceConsumer extends SourceConsumerStatefulWidget {
  final Widget Function(BuildContext context, SourceWidgetRef ref, Widget? child) builder;
  final Widget? child;

  const SourceConsumer({super.key, required this.builder, this.child});

  Widget build(BuildContext context, SourceWidgetRef ref) => builder(context, ref, child);

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState() => _SourceConsumerState();
}

abstract class SourceConsumerWidget extends SourceConsumerStatefulWidget {
  const SourceConsumerWidget({super.key});

  Widget build(BuildContext context, SourceWidgetRef ref);

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState() => _SourceConsumerState();
}

class _SourceConsumerState extends SourceConsumerState<SourceConsumerWidget> {
  @override
  Widget build(BuildContext context) => widget.build(context, ref);
}

abstract class SourceConsumerStatefulWidget extends ConsumerStatefulWidget {
  const SourceConsumerStatefulWidget({super.key});

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState();

  @override
  // ignore: invalid_use_of_internal_member
  ConsumerStatefulElement createElement() => _SourceConsumerStatefulElement(this);
}

abstract class SourceConsumerState<T extends SourceConsumerStatefulWidget>
    extends ConsumerState<T> {
  @override
  // ignore: overridden_fields
  late final SourceWidgetRef ref = SourceWidgetRef._(context as _SourceConsumerStatefulElement);
}

// ignore: invalid_use_of_internal_member
final class _SourceConsumerStatefulElement extends ConsumerStatefulElement
    with SourceStatefulElementMixin {
  _SourceConsumerStatefulElement(SourceConsumerStatefulWidget super.widget);
}

extension SourceStateNotifierExtension<T> on StateNotifier<T> {
  Source<T> get source => _NotifierStateSource(this);

  Source<R> select<R>(R Function(T state) selector) => source.select(selector);
  Source<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      source.selectWith(arg, selector);
}

final class _NotifierStateSource<T> extends Source<T> {
  final StateNotifier<T> _notifier;

  _NotifierStateSource(this._notifier);

  @override
  SourceSubscription<T> listen(SourceListener<T> onChange) {
    T? current;
    final listenerRemover = _notifier.addListener(fireImmediately: true, (next) {
      final previous = current;
      current = next;
      if (previous != null) {
        Zone.current.runBinaryGuarded(onChange, previous, next);
      }
    });
    return _NotifierStateSourceSubscription(() => current as T, listenerRemover);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _NotifierStateSource<T> &&
          runtimeType == other.runtimeType &&
          _notifier == other._notifier;

  @override
  int get hashCode => _notifier.hashCode;
}

final class _NotifierStateSourceSubscription<T> extends SourceSubscriptionBase<T> {
  final T Function() _reader;
  final void Function() _listenerRemover;

  _NotifierStateSourceSubscription(this._reader, this._listenerRemover);

  @override
  T onRead() => _reader();

  @override
  void onCancel() => _listenerRemover();
}
