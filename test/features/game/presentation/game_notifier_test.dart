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

    test('undo reverts the last move', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);
      final startCount = container.read(gameProvider).board.arrowCount;

      notifier.applyResult(notifier.peek(notifier.solution.first));
      expect(container.read(gameProvider).moves, 1);
      expect(container.read(gameProvider).board.arrowCount, startCount - 1);

      notifier.undo();
      expect(container.read(gameProvider).moves, 0);
      expect(container.read(gameProvider).board.arrowCount, startCount);
    });

    test('undo with no history is a no-op', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.undo();
      expect(container.read(gameProvider).moves, 0);
    });

    test('hint always returns a currently-escaping arrow', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);

      // Play halfway using the guaranteed solution, checking the hint each step.
      final steps = notifier.solution.length ~/ 2;
      for (var i = 0; i < steps; i++) {
        final hint = notifier.hint();
        expect(hint, isNotNull);
        expect(notifier.peek(hint!).didEscape, isTrue,
            reason: 'hint must be a safe move');
        notifier.applyResult(notifier.peek(notifier.solution[i]));
      }
    });

    test('hint returns null when the board is clear', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);
      for (final pos in notifier.solution) {
        notifier.applyResult(notifier.peek(pos));
      }
      expect(notifier.hint(), isNull);
    });

    test('consecutive escapes build a combo', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);

      for (var i = 0; i < 3; i++) {
        notifier.applyResult(notifier.peek(notifier.hint()!));
      }
      final state = container.read(gameProvider);
      expect(state.combo, 3);
      expect(state.bestCombo, 3);
    });

    test('a combo of the threshold refunds a lost life', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);
      final board = container.read(gameProvider).board;

      // Lose a life on a blocked shot.
      final blocked = board.arrows
          .map((a) => a.position)
          .firstWhere((p) => notifier.peek(p).didCollide);
      notifier.applyResult(notifier.peek(blocked));
      expect(container.read(gameProvider).lives,
          container.read(gameProvider).maxLives - 1);

      // Chain enough escapes to hit the reward threshold.
      for (var i = 0; i < GameNotifier.comboRewardThreshold; i++) {
        notifier.applyResult(notifier.peek(notifier.hint()!));
      }
      final state = container.read(gameProvider);
      expect(state.combo, GameNotifier.comboRewardThreshold);
      expect(state.lives, state.maxLives, reason: 'life should be refunded');
    });
  });
}
