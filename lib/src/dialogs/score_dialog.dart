import 'package:digitwars_io/src/game/score_controller.dart';
import 'package:digitwars_io/src/utils/constants.dart';
import 'package:flutter/material.dart';

class ScoreDialog extends StatelessWidget {
  const ScoreDialog({super.key});

  String _formatEndType(EndType type) {
    switch (type) {
      case EndType.win:
        return 'Win';
      case EndType.lose:
        return 'Lose';
      case EndType.timeEnded:
        return 'Time Ended';
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ScoreController.scoreHistory;
    final getHighestScore = ScoreController.getHighestScore();
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Score History'),
          if (getHighestScore != null)
            // trophy emoji with score
            Text(
              '🏆 Highest score: $getHighestScore',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: history.isEmpty ? 320 : 610,
          child:
              history.isEmpty
                  ? const Text('No score history yet')
                  : DataTable(
                    columns: const [
                      DataColumn(
                        label: Center(
                          child: Text('Score', textAlign: TextAlign.center),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text('End Type', textAlign: TextAlign.center),
                        ),
                      ),
                      DataColumn(
                        label: Text('Elapsed (s)', textAlign: TextAlign.center),
                      ),
                      DataColumn(
                        label: Text(
                          'Remaining (s)',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text('Game Mode', textAlign: TextAlign.center),
                      ),
                    ],
                    rows:
                        history
                            .map(
                              (score) => DataRow(
                                cells: [
                                  DataCell(
                                    Center(child: Text('${score.score}')),
                                  ),
                                  DataCell(
                                    Center(
                                      child:
                                          score.gameMode.name ==
                                                  initialItemsList.last.name
                                              ? const Text('-')
                                              : Text(
                                                _formatEndType(score.endType),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      score.endType ==
                                                              EndType.win
                                                          ? Colors.green
                                                          : Colors.red,
                                                ),
                                              ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        '${score.elapsedTime ?? "-"}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        score.gameMode.name ==
                                                initialItemsList.last.name
                                            ? '-'
                                            : '${score.remainingTime ?? "-"}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        score.gameMode.name,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                  ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
