import 'package:flutter/widgets.dart';
import 'package:rivertion/src/internals.dart';

extension WatchSourceBuildContextExtension on BuildContext {
  T watch<T>(Source<T> source) => SourceScope._stateOf<T>(this, source.listenable);
}

class SourceScope extends StatefulWidget {
  final Widget child;

  const SourceScope({super.key, required this.child});

  static T _stateOf<T>(BuildContext context, SourceListenable<Object?> source) {
    final widget = InheritedModel.inheritFrom<_UncontrolledSourceScope>(context, aspect: source)!;
    return widget.states[source] as T;
  }

  @override
  State<SourceScope> createState() => _SourceScopeState();
}

class _SourceScopeState extends State<SourceScope> {
  var _dependencies = <SourceListenable<Object?>, _SourcePointer>{};
  var _states = <SourceListenable<Object?>, Object?>{};

  @override
  void dispose() {
    _states = const {};
    for (final pointer in _dependencies.values) {
      pointer._subscription.cancel();
    }
    _dependencies = const {};
    super.dispose();
  }

  void addDependency(SourceListenable<Object?> source, Element dependent) {
    final pointer = _dependencies.putIfAbsent(source, () {
      final subscription = source.listen((_, state) {
        setState(() => _states = {..._states, source: state});
      });
      _states[source] = subscription.read();
      return _SourcePointer(subscription);
    });
    pointer._dependents.add(dependent);
  }

  void removeDependency(SourceListenable<Object?> source, Element dependent) {
    final pointer = _dependencies[source];
    if (pointer == null) return;

    pointer._dependents.remove(dependent);
    _mayClear(source);
  }

  void _mayClear(SourceListenable<Object?> source) {
    if (_dependencies[source]?._dependents.isNotEmpty ?? false) return;

    _dependencies.remove(source)?._subscription.cancel();
    _states.remove(source);
  }

  @override
  Widget build(BuildContext context) =>
      _UncontrolledSourceScope(state: this, states: _states, child: widget.child);
}

class _SourcePointer {
  final Set<Element> _dependents = <Element>{};
  final SourceSubscription<Object?> _subscription;

  _SourcePointer(this._subscription);
}

class _UncontrolledSourceScope extends InheritedModel<SourceListenable<Object?>> {
  final _SourceScopeState state;
  final Map<SourceListenable<Object?>, Object?> states;

  const _UncontrolledSourceScope({required this.state, required this.states, required super.child});

  @override
  bool updateShouldNotify(covariant _UncontrolledSourceScope oldWidget) =>
      state != oldWidget.state || states != oldWidget.states;

  @override
  bool updateShouldNotifyDependent(
    covariant _UncontrolledSourceScope oldWidget,
    Set<SourceListenable<Object?>> dependencies,
  ) {
    for (final source in dependencies) {
      if (states[source] != oldWidget.states[source]) return true;
    }
    return false;
  }

  @override
  InheritedModelElement<SourceListenable<Object?>> createElement() => _SourceScopeElement(this);
}

class _SourceScopeElement extends InheritedModelElement<SourceListenable<Object?>> {
  _SourceScopeElement(super.widget);

  _SourceScopeState get state => (super.widget as _UncontrolledSourceScope).state;

  @override
  void updateDependencies(Element dependent, covariant SourceListenable<Object?>? aspect) {
    super.updateDependencies(dependent, aspect);
    if (aspect == null) return;

    state.addDependency(aspect, dependent);
  }

  @override
  void removeDependent(Element dependent) {
    final aspect = getDependencies(dependent) as Set<SourceListenable<Object?>>?;

    if (aspect != null) {
      for (final target in aspect) {
        state.removeDependency(target, dependent);
      }
    }

    super.removeDependent(dependent);
  }
}
