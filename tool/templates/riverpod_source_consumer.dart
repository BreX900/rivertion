// Version: 4.0.0

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
  SourceListenable<T> get source => _StateNotifierSourceListenable(this);
}

final class _StateNotifierSourceListenable<T> extends SourceListenable<T> {
  final StateNotifier<T> _notifier;

  _StateNotifierSourceListenable(this._notifier);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    return SourceSubscription.viaAdapter(listener, (context) {
      return _notifier.addListener(fireImmediately: true, (next) {
        context.state = next;
      });
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _StateNotifierSourceListenable<T> &&
          runtimeType == other.runtimeType &&
          identical(_notifier, other._notifier);

  @override
  int get hashCode => _notifier.hashCode;
}
