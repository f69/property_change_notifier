import 'package:flutter/widgets.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class Observer<T extends PropertyChangeNotifier<S>, S extends Object> extends StatefulWidget {
  static Type _typeOf<T>() => T;

  static T of<T extends PropertyChangeNotifier<S>, S extends Object>(BuildContext context, {Iterable<S> properties, bool listen = true}) {
    assert (listen || properties == null, "No need to provide properties if you're not going to listen to them.");

    if (!listen) {
      final type = _typeOf<ObservedModel<T, S>>();
      return (context.ancestorWidgetOfExactType(type) as ObservedModel).model;
    }

    if (properties == null) {
      return InheritedModel.inheritFrom<ObservedModel<T, S>>(context).model;
    }

    ObservedModel widget;
    for (final property in properties) {
      widget = InheritedModel.inheritFrom<ObservedModel<T, S>>(context, aspect: property);
    }
    return widget.model;
  }

  const Observer({Key key, this.model, this.child}) : super(key: key);

  final Widget child;
  final T model;

  @override
  _ObserverState createState() => _ObserverState<T, S>();
}

class _ObserverState<T extends PropertyChangeNotifier<S>, S extends Object> extends State<Observer> {
  S _changedProperty;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_listener);
  }

  @override
  void dispose() {
    widget.model.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObservedModel<T, S>(
      model: widget.model,
      changedProperty: _changedProperty,
      child: widget.child,
    );
  }

  void _listener(S property) {
    setState(() {
      _changedProperty = property;
    });
  }
}

class ObservedModel<T extends PropertyChangeNotifier<S>, S extends Object> extends InheritedModel<String> {
  final T model;
  final S changedProperty;

  ObservedModel({
    Key key,
    this.model,
    this.changedProperty,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ObservedModel oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(ObservedModel oldWidget, Set<String> aspects) {
    return aspects.contains(this.changedProperty);
  }
}