import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/position.dart';
import 'package:shiftgrid/features/game/presentation/providers/game_notifier.dart';
import 'package:shiftgrid/features/game/presentation/providers/game_state.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('GameNotifier', () {
    test('starts playing with full lives and a generated board', () {
      final container = makeContainer();
      final state = container.read(gameProvider);
      expect(state.status, GameStatus.playing);
      expect(state.lives, state.maxLives);
      expect(state.board.arrowCount, greaterThan(0));
    });

    test('playing the guaranteed solution clears the board -> won', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);
      final solution = notifier.solution;

      for (final pos in solution) {
        final result = notifier.peek(pos);
        expect(result.didEscape, isTrue, reason: 'expected $pos to escape');
        notifier.applyResult(result);
      }

      final state = container.read(gameProvider);
      expect(state.status, GameStatus.won);
      expect(state.board.isCleared, isTrue);
      expect(state.moves, solution.length);
    });

    test('a blocked shot costs a life without changing the board', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);
      final board = container.read(gameProvider).board;

      Position? blocked;
      for (final arrow in board.arrows) {
        if (notifier.peek(arrow.position).didCollide) {
          blocked = arrow.position;
          break;
        }
      }
      expect(blocked, isNotNull, reason: 'expected at least one blocked arrow');

      final result = notifier.peek(blocked!);
      notifier.applyResult(result);

      final state = container.read(gameProvider);
      expect(state.lives, state.maxLives - 1);
      expect(state.board.arrowCount, board.arrowCount);
      expect(state.status, GameStatus.playing);
    });

    test('reset restores full lives and the same level', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);
      final startCount = container.read(gameProvider).board.arrowCount;

      final first = notifier.solution.first;
      notifier.applyResult(notifier.peek(first));
      notifier.reset();

      final state = container.read(gameProvider);
      expect(state.lives, state.maxLives);
      expect(state.moves, 0);
      expect(state.board.arrowCount, startCount);
    });

    test('newGame loads a different level and stays playable', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.newGame(seed: 42);
      final state = container.read(gameProvider);

      expect(state.status, GameStatus.playing);
      expect(state.board.arrowCount, greaterThan(0));
      expect(notifier.solution.length, state.board.arrowCount);
    });
  });
}
