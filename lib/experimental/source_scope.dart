import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rivertion/rivertion.dart';
import 'package:rivertion/src/internals/source_listenable_extension.dart';

extension WatchSourceBuildContextExtension on BuildContext {
  T watch<T>(Source<T> source) => SourceScope._watch<T>(this, source.listenable);
}

class SourceScope extends InheritedWidget {
  const SourceScope({super.key, required super.child});

  static T _watch<T>(BuildContext context, SourceListenable<T> source) {
    final element =
        context.getElementForInheritedWidgetOfExactType<SourceScope>()! as _SourceScopeElement;
    context.dependOnInheritedElement(element, aspect: source);
    return element._sourceSubscriptions[source]!.read() as T;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  @override
  InheritedElement createElement() => _SourceScopeElement(this);
}

class _SourceScopeElement extends InheritedElement with _DependenciesContainer {
  _SourceScopeElement(super.widget);

  @override
  void updateDependencies(Element dependent, covariant SourceListenable<Object?>? aspect) {
    if (aspect != null) $updateDependency(dependent, aspect);
  }

  @override
  void removeDependent(Element dependent) {
    super.removeDependent(dependent);
    $removeDependency(dependent);
  }

  @override
  void unmount() {
    $disposeDependencies();
    super.unmount();
  }

  @override
  void debugDeactivated() {
    assert(_sourceSubscriptions.isEmpty);
    assert(_tickerModeListeners.isEmpty);
    assert(_dependencies.isEmpty);
    super.debugDeactivated();
  }

  @override
  Widget build() {
    _dependencies.forEach((dependent, pointer) {
      if (!pointer.dirty) return;
      if (!pointer.tickerModeListenable.value) return;

      pointer.dirty = false;
      notifyDependent(widget as InheritedWidget, dependent);
    });

    return super.build();
  }
}

class _Dependency {
  late ValueListenable<bool> tickerModeListenable;
  final sources = <SourceListenable<Object?>>{};
  bool dirty = false;
}

mixin _DependenciesContainer {
  var _sourceSubscriptions = <SourceListenable<Object?>, SourceSubscription<Object?>>{};
  var _tickerModeListeners = <ValueListenable<bool>, VoidCallback>{};
  var _dependencies = <Element, _Dependency>{};

  void markNeedsBuild();

  void $updateDependency(Element element, SourceListenable<Object?> source) {
    final tickerModeListenable = TickerMode.getNotifier(element);

    _dependencies.putIfAbsent(element, _Dependency.new)
      ..tickerModeListenable = tickerModeListenable
      ..sources.add(source);

    _sourceSubscriptions.putIfAbsent(source, () {
      return source.listen((_, _) => _onSourceEmit(source));
    });

    _tickerModeListeners.putIfAbsent(tickerModeListenable, () {
      void listener() => _onTickerModeChange(tickerModeListenable);
      tickerModeListenable.addListener(listener);
      return listener;
    });
  }

  void $removeDependency(Element element) {
    final dependency = _dependencies.remove(element)!;

    for (final source in dependency.sources) {
      final isFree = _dependencies.values.every((e) => !e.sources.contains(source));
      if (isFree) {
        final subscription = _sourceSubscriptions.remove(source)!;
        subscription.cancel();
      }
    }

    final isTickerModeListenableFree = _dependencies.values.every((e) {
      return e.tickerModeListenable != dependency.tickerModeListenable;
    });
    if (isTickerModeListenableFree) {
      final listener = _tickerModeListeners.remove(dependency.tickerModeListenable)!;
      dependency.tickerModeListenable.removeListener(listener);
    }
  }

  void $disposeDependencies() {
    for (final subscription in _sourceSubscriptions.values) {
      subscription.cancel();
    }
    _sourceSubscriptions = const {};

    _tickerModeListeners.forEach((listenable, listener) {
      listenable.removeListener(listener);
    });
    _tickerModeListeners = const {};

    _dependencies = const {};
  }

  void _onSourceEmit(SourceListenable<Object?> source) {
    var needBuild = false;
    for (final dependency in _dependencies.values) {
      if (!dependency.sources.contains(source)) continue;

      dependency.dirty = true;

      if (dependency.tickerModeListenable.value) needBuild = true;
    }
    if (needBuild) markNeedsBuild();
  }

  void _onTickerModeChange(ValueListenable<bool> listenable) {
    for (final dependency in _dependencies.values) {
      if (dependency.tickerModeListenable != listenable) return;
      if (listenable.value) {}
    }
  }
}
