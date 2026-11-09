/// Clock provider abstraction for isolating current date/time in business logic and unit tests.
///
/// Pure Dart — no Flutter framework dependencies.
typedef KhatmaClock = DateTime Function();

/// Default system clock provider returning [DateTime.now].
DateTime defaultKhatmaClock() => DateTime.now();

