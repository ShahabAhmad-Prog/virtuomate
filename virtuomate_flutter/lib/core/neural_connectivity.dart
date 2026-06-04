/// Live status of the VirtuoMate Intelligence Engine stack (from GET /health).
class NeuralLayerStatus {
  const NeuralLayerStatus({
    required this.id,
    required this.label,
    required this.ok,
    this.detail = '',
  });

  final String id;
  final String label;
  final bool ok;
  final String detail;

  factory NeuralLayerStatus.fromJson(Map<String, dynamic> json) {
    return NeuralLayerStatus(
      id: (json['id'] as String?) ?? 'layer',
      label: (json['label'] as String?) ?? 'Layer',
      ok: json['ok'] == true,
      detail: (json['detail'] as String?) ?? '',
    );
  }
}

class NeuralConnectivityStatus {
  const NeuralConnectivityStatus({
    required this.percent,
    required this.full,
    required this.mode,
    required this.layers,
    this.intelligenceEngineUrl,
    this.lastChecked,
    this.errorMessage,
  });

  final int percent;
  final bool full;
  final String mode;
  final List<NeuralLayerStatus> layers;
  final String? intelligenceEngineUrl;
  final DateTime? lastChecked;
  final String? errorMessage;

  static const offline = NeuralConnectivityStatus(
    percent: 0,
    full: false,
    mode: 'offline',
    layers: [],
    errorMessage: 'Not connected to cloud API',
  );

  static NeuralConnectivityStatus localMode() {
    return NeuralConnectivityStatus(
      percent: 100,
      full: true,
      mode: 'local-dev',
      lastChecked: DateTime.now(),
      layers: const [
        NeuralLayerStatus(
          id: 'local',
          label: 'Local coach',
          ok: true,
          detail: 'In-memory mode — enable Firebase for full neural stack',
        ),
      ],
    );
  }

  factory NeuralConnectivityStatus.fromHealthJson(Map<String, dynamic> json) {
    final neural = json['neuralConnectivity'] as Map<String, dynamic>?;
    if (neural != null) {
      final layersRaw = neural['layers'] as List? ?? const [];
      return NeuralConnectivityStatus(
        percent: (neural['percent'] as num?)?.toInt() ?? 0,
        full: neural['full'] == true,
        mode: (neural['mode'] as String?) ?? 'unknown',
        intelligenceEngineUrl: neural['intelligenceEngineUrl'] as String? ??
            json['intelligenceEngineUrl'] as String?,
        lastChecked: DateTime.now(),
        layers: layersRaw
            .whereType<Map>()
            .map((e) => NeuralLayerStatus.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }

    return _legacyFromHealth(json);
  }

  static NeuralConnectivityStatus _legacyFromHealth(Map<String, dynamic> json) {
    final url = json['intelligenceEngineUrl'] as String?;
    final engine = json['intelligenceEngine'];
    var percent = 25;
    final layers = <NeuralLayerStatus>[
      const NeuralLayerStatus(
        id: 'cloud_api',
        label: 'Cloud API',
        ok: true,
        detail: 'VirtuoMate API reachable',
      ),
    ];

    if (url != null && url.isNotEmpty) {
      percent += 25;
      layers.add(
        NeuralLayerStatus(
          id: 'engine_link',
          label: 'Engine link',
          ok: true,
          detail: url,
        ),
      );
    } else {
      layers.add(
        const NeuralLayerStatus(
          id: 'engine_link',
          label: 'Engine link',
          ok: false,
          detail: 'INTELLIGENCE_ENGINE_URL not configured',
        ),
      );
    }

    if (engine is Map<String, dynamic>) {
      if (engine['status'] == 'ok' || engine['engine'] == 'virtuomate-intelligence') {
        if (engine['neural_checkpoint'] == true) {
          percent += 25;
          layers.add(
            const NeuralLayerStatus(
              id: 'neural_model',
              label: 'Neural model',
              ok: true,
              detail: 'DeBERTa checkpoint loaded',
            ),
          );
        } else {
          layers.add(
            const NeuralLayerStatus(
              id: 'neural_model',
              label: 'Neural model',
              ok: false,
              detail: 'Linguistic engine only',
            ),
          );
        }
        if (engine['whisper'] == true) {
          percent += 25;
          layers.add(
            const NeuralLayerStatus(
              id: 'speech_ai',
              label: 'Speech AI',
              ok: true,
              detail: 'Whisper available',
            ),
          );
        } else {
          layers.add(
            const NeuralLayerStatus(
              id: 'speech_ai',
              label: 'Speech AI',
              ok: false,
              detail: 'Text analysis only',
            ),
          );
        }
      } else {
        layers.add(
          NeuralLayerStatus(
            id: 'engine',
            label: 'Intelligence Engine',
            ok: false,
            detail: engine['error']?.toString() ?? 'Unreachable',
          ),
        );
      }
    }

    return NeuralConnectivityStatus(
      percent: percent.clamp(0, 100),
      full: percent >= 100,
      mode: percent >= 100 ? 'neural-full' : 'partial',
      intelligenceEngineUrl: url,
      lastChecked: DateTime.now(),
      layers: layers,
    );
  }

  String get headline {
    if (full) return '100% Neural connectivity';
    if (percent >= 75) return '$percent% Neural connectivity';
    if (percent >= 50) return '$percent% · Partial neural link';
    if (percent >= 25) return '$percent% · Cloud only';
    return 'Neural offline';
  }

  String get modeLabel {
    switch (mode) {
      case 'neural-full':
        return 'Full Intelligence Engine';
      case 'neural-partial':
        return 'Neural + linguistic';
      case 'linguistic-remote':
        return 'Linguistic (remote)';
      case 'engine-unreachable':
        return 'Engine unreachable';
      case 'local-dev':
        return 'Local development';
      case 'local-only':
        return 'Local fallback';
      default:
        return mode;
    }
  }
}
