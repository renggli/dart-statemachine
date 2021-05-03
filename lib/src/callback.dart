/// A callback with no argument.
typedef Callback0 = void Function();

/// A callback with one argument.
typedef Callback1<T> = void Function(T value);

/// A provider of one value.
typedef Provider<T> = T Function();
