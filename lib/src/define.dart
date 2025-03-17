import 'extension.dart';

enum RelayMode {
  Unknown,
  ChatCompletions,
  Completions,
  Embeddings,
  Moderations,
  ImagesGenerations,
  Edits,
  AudioSpeech,
  AudioTranscription,
  AudioTranslation,
}

Map<String, RelayMode> pathRelayModeMap = {
  "/v1/chat/completions": RelayMode.ChatCompletions,
  "/v1/completions": RelayMode.Completions,
  "/v1/embeddings": RelayMode.Embeddings,
  "/v1/moderations": RelayMode.Moderations,
  "/v1/images/generations": RelayMode.ImagesGenerations,
  "/v1/edits": RelayMode.Edits,
  "/v1/audio/speech": RelayMode.AudioSpeech,
  "/v1/audio/transcriptions": RelayMode.AudioTranscription,
  "/v1/audio/translations": RelayMode.AudioTranslation,
};

RelayMode getByPath(String path) {
  for (var entry in pathRelayModeMap.entries) {
    if(path.hasPrefix(entry.key)) return entry.value;
  }
  return RelayMode.Unknown;
}