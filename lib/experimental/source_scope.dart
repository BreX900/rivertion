import 'package:flutter/cupertino.dart';
import 'package:rivertion/rivertion.dart';
import 'package:rivertion/src/internals/source_listenable_extension.dart';

extension WatchSourceBuildContextExtension on BuildContext {
  T watch<T>(Source<T> source) => SourceScope._watch<T>(this, source.listenable);
}

class SourceScope extends InheritedWidget {
  const SourceScope({super.key, required super.child});

  static T _watch<T>(BuildContext context, SourceListenable<T> source) {
    final element =
        context.getElementForInheritedWidgetOfExactType<SourceScope>()! as _SourceScopeElementV2;
    context.dependOnInheritedElement(element, aspect: source);
    return element._dependencies[source]!.subscription.read();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  @override
  InheritedElement createElement() => _SourceScopeElementV2(this);
}

class _SourceScopeElementV2 extends InheritedElement {
  var _dependencies = <SourceListenable<Object?>, _SourcePointer>{};
  var _dirty = <Element>{};

  _SourceScopeElementV2(super.widget);

  @override
  void updateDependencies(Element dependent, covariant SourceListenable<Object?>? aspect) {
    setDependencies(dependent, {
      ...?(getDependencies(dependent) as Set<SourceListenable<Object?>>?),
      ?aspect,
    });
    if (aspect == null) return;

    final pointer = _dependencies.putIfAbsent(aspect, () {
      return _SourcePointer(aspect.listen((_, _) => _handleUpdate(dependent)));
    });
    pointer.dependents.add(dependent);
  }

  @override
  void removeDependent(Element dependent) {
    final aspects = getDependencies(dependent) as Set<SourceListenable<Object?>>?;
    if (aspects != null) {
      for (final source in aspects) {
        final pointer = _dependencies[source];
        if (pointer == null) continue;
        if (!pointer.dependents.remove(dependent)) continue;
        if (pointer.dependents.isNotEmpty) continue;
        _dependencies.remove(source);
      }
    }
    super.removeDependent(dependent);
  }

  @override
  void unmount() {
    for (final pointer in _dependencies.values) {
      pointer.subscription.cancel();
    }
    _dependencies = const {};
    _dirty = const {};
    super.unmount();
  }

  @override
  Widget build() {
    for (final element in _dirty) {
      notifyDependent(widget as InheritedWidget, element);
    }
    _dirty.clear();
    return super.build();
  }

  void _handleUpdate(Element dependent) {
    _dirty.add(dependent);
    markNeedsBuild();
  }
}

class _SourcePointer<T> {
  final SourceSubscription<T> subscription;
  final dependents = <Element>{};

  _SourcePointer(this.subscription);

  @override
  String toString() => 'SourcePointer(${dependents.length})';
}
