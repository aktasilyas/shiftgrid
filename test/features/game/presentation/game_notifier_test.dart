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
    test('starts playing with full lives and the demo board', () {
      final container = makeContainer();
      final state = container.read(gameProvider);
      expect(state.status, GameStatus.playing);
      expect(state.lives, state.maxLives);
      expect(state.board.arrowCount, 5);
    });

    test('demo board is solvable in the intended order -> won', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);

      const solution = [
        Position(2, 2),
        Position(2, 4),
        Position(0, 4),
        Position(4, 0),
        Position(0, 0),
      ];

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

      // Firing (0,0) down is blocked by the arrow at (4,0).
      final result = notifier.peek(const Position(0, 0));
      expect(result.didCollide, isTrue);
      notifier.applyResult(result);

      final state = container.read(gameProvider);
      expect(state.lives, state.maxLives - 1);
      expect(state.board.arrowCount, 5);
      expect(state.status, GameStatus.playing);
    });

    test('reset restores full lives and the board', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.applyResult(notifier.peek(const Position(0, 0)));
      notifier.reset();

      final state = container.read(gameProvider);
      expect(state.lives, state.maxLives);
      expect(state.moves, 0);
      expect(state.board.arrowCount, 5);
    });
  });
}
