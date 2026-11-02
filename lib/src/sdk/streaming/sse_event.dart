/// A decoded server-sent event frame.
///
/// [eventName] preserves the upstream `event:` field. [data] is the JSON
/// object from the corresponding `data:` field, without protocol conversion.
class LiteOneApiSseEvent {
  final String? eventName;
  final String? id;
  final Map<String, dynamic> data;

  const LiteOneApiSseEvent({required this.data, this.eventName, this.id});
}
