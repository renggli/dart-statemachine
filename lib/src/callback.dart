/// A callback with no arguments.
///
/// Used for simple notifications or actions that don't require data, such as
/// `State.onEntry` or `State.onExit`.
typedef Callback0 = void Function();

/// A callback with one argument of type [T].
///
/// Used for actions that process a value, such as `State.onStream` or
/// `State.onFuture`.
typedef Callback1<T> = void Function(T value);

/// A provider of a value of type [T].
///
/// Used to lazily retrieve values, such as streams or futures in
/// `State.onStreamProvider` and `State.onFutureProvider`.
typedef Provider<T> = T Function();
