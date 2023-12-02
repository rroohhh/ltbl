extension BroadcastToSingleStream<T> on Stream<T> {
  Stream<T> toSingleStream() async* {
    await for (final item in this) {
      yield item;
    }
  }
}
