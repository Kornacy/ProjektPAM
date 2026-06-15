import 'package:city_issues/services/offline/connectivity_service.dart';
import 'package:city_issues/services/offline/offline_sync_service.dart';
import 'package:flutter/material.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    ConnectivityService.instance.addListener(_refreshPendingCount);
    _refreshPendingCount();
  }

  @override
  void dispose() {
    ConnectivityService.instance.removeListener(_refreshPendingCount);
    super.dispose();
  }

  Future<void> _refreshPendingCount() async {
    final count = await OfflineSyncService.instance.pendingCount();
    if (mounted) {
      setState(() => _pendingCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ConnectivityService.instance,
        OfflineSyncService.instance,
      ]),
      builder: (context, _) {
        final isOnline = ConnectivityService.instance.isOnline;
        if (isOnline && _pendingCount == 0) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final background = isOnline
            ? theme.colorScheme.tertiaryContainer
            : theme.colorScheme.errorContainer;
        final foreground = isOnline
            ? theme.colorScheme.onTertiaryContainer
            : theme.colorScheme.onErrorContainer;

        final message = isOnline
            ? 'Synchronizacja oczekujących zmian ($_pendingCount)...'
            : 'Tryb offline — wyświetlane są zapisane dane';

        return Material(
          color: background,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  isOnline
                      ? Icons.cloud_sync_outlined
                      : Icons.cloud_off_outlined,
                  color: foreground,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
