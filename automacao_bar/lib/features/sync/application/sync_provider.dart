import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';

class SyncState {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncedTime;
  final int pendingCount;

  const SyncState({
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncedTime,
    required this.pendingCount,
  });

  SyncState copyWith({
    bool? isOnline,
    bool? isSyncing,
    DateTime? lastSyncedTime,
    int? pendingCount,
  }) {
    return SyncState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedTime: lastSyncedTime ?? this.lastSyncedTime,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncState &&
          runtimeType == other.runtimeType &&
          isOnline == other.isOnline &&
          isSyncing == other.isSyncing &&
          lastSyncedTime == other.lastSyncedTime &&
          pendingCount == other.pendingCount;

  @override
  int get hashCode =>
      isOnline.hashCode ^
      isSyncing.hashCode ^
      lastSyncedTime.hashCode ^
      pendingCount.hashCode;
}

class SyncNotifier extends Notifier<SyncState> {
  Timer? _syncTimer;

  @override
  SyncState build() {
    _startTimer();
    ref.onDispose(() {
      _syncTimer?.cancel();
    });

    // Listen to the pending sync events stream reactively to trigger sync logic
    ref.listen(pendingSyncEventsProvider, (previous, next) {
      final events = next.value;
      if (events != null) {
        if (state.pendingCount != events.length) {
          state = state.copyWith(pendingCount: events.length);
        }
        if (events.isNotEmpty && state.isOnline && !state.isSyncing) {
          _runSyncCycle();
        }
      }
    });

    // Fetch initial state safely
    final initialEvents = ref.read(pendingSyncEventsProvider).value;
    if (initialEvents != null && initialEvents.isNotEmpty) {
      Future.microtask(() => _runSyncCycle());
    }

    return SyncState(
      isOnline: true,
      isSyncing: false,
      lastSyncedTime: null,
      pendingCount: initialEvents?.length ?? 0,
    );
  }

  void _startTimer() {
    _syncTimer?.cancel();
    // Run sync check every 30 seconds as a fallback/retry mechanism
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _runSyncCycle();
    });
  }

  Future<void> checkPendingCount() async {
    try {
      final dao = ref.read(ordersDaoProvider);
      final events = await dao.getPendingSyncEvents();
      if (state.pendingCount != events.length) {
        state = state.copyWith(pendingCount: events.length);
      }
    } catch (e) {
      debugPrint('Error checking pending sync count: $e');
    }
  }

  Future<void> toggleConnectivity() async {
    final newOnline = !state.isOnline;
    state = state.copyWith(isOnline: newOnline);
    if (newOnline) {
      _runSyncCycle();
    }
  }

  Future<void> triggerManualSync() async {
    if (!state.isOnline) return;
    await _runSyncCycle();
  }

  Future<void> _runSyncCycle() async {
    if (!state.isOnline || state.isSyncing) return;

    await checkPendingCount();
    if (state.pendingCount == 0) return;

    state = state.copyWith(isSyncing: true);

    // Get the pending events
    final dao = ref.read(ordersDaoProvider);
    final events = await dao.getPendingSyncEvents();
    final ids = events.map((e) => e.id).toList();

    // Simulate network call latency of 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!state.isOnline) {
      // If user toggled offline during sync, abort
      state = state.copyWith(isSyncing: false);
      return;
    }

    try {
      // Update local orders/items in database to synced and delete from outbox
      await dao.removeSyncedEvents(ids);
      
      // Update state
      state = state.copyWith(
        isSyncing: false,
        lastSyncedTime: DateTime.now(),
        pendingCount: 0,
      );
    } catch (e) {
      debugPrint('Error during sync: $e');
      state = state.copyWith(isSyncing: false);
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(() {
  return SyncNotifier();
});
