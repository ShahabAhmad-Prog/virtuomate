import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/core/neural_connectivity.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';

/// Live Intelligence Engine stack status (from GET /health → neuralConnectivity).
class NeuralConnectivityCard extends StatelessWidget {
  const NeuralConnectivityCard({
    required this.status,
    super.key,
    this.compact = false,
    this.onRefresh,
    this.refreshing = false,
  });

  final NeuralConnectivityStatus status;
  final bool compact;
  final VoidCallback? onRefresh;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactBar(status: status);
    }

    return VCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status.full ? Icons.hub : Icons.hub_outlined,
                size: 18,
                color: status.full ? VirtuoMvpColors.green : VirtuoMvpColors.cyan,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status.headline,
                  style: const TextStyle(
                    color: VirtuoMvpColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  tooltip: 'Refresh neural status',
                  onPressed: refreshing ? null : onRefresh,
                  icon: refreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 20, color: VirtuoMvpColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status.modeLabel,
            style: const TextStyle(
              color: VirtuoMvpColors.cyan,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (status.errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              status.errorMessage!,
              style: TextStyle(
                color: VirtuoMvpColors.amber.withValues(alpha: 0.95),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _CompactBar(status: status),
          if (status.layers.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...status.layers.map(_layerRow),
          ],
          if (status.lastChecked != null) ...[
            const SizedBox(height: 10),
            Text(
              'Checked ${_formatTime(status.lastChecked!)}',
              style: const TextStyle(
                color: VirtuoMvpColors.textFaint,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _layerRow(NeuralLayerStatus layer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            layer.ok ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 16,
            color: layer.ok ? VirtuoMvpColors.green : VirtuoMvpColors.textFaint,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layer.label,
                  style: TextStyle(
                    color: layer.ok ? VirtuoMvpColors.text : VirtuoMvpColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (layer.detail.isNotEmpty)
                  Text(
                    layer.detail,
                    style: const TextStyle(
                      color: VirtuoMvpColors.textFaint,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _CompactBar extends StatelessWidget {
  const _CompactBar({required this.status});

  final NeuralConnectivityStatus status;

  @override
  Widget build(BuildContext context) {
    final filledSegments = (status.percent / 10).round().clamp(0, 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(10, (i) {
            final on = i < filledSegments;
            return Container(
              width: 16,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: on
                    ? (status.full
                        ? VirtuoMvpColors.green
                        : (i.isEven ? VirtuoMvpColors.cyan : VirtuoMvpColors.purple))
                    : const Color.fromRGBO(255, 255, 255, 0.08),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '${status.percent}% connected',
          style: const TextStyle(
            color: VirtuoMvpColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
