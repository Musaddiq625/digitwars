import 'package:digitwars_io/src/game/score_controller.dart';
import 'package:digitwars_io/src/utils/constants.dart';
import 'package:digitwars_io/src/utils/numbers_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScoreDialog extends StatelessWidget {
  const ScoreDialog({super.key});

  String _formatEndType(EndType type) {
    switch (type) {
      case EndType.victory:
        return 'Victory';
      case EndType.defeat:
        return 'Defeat';
      case EndType.timeEnded:
        return 'Time Ended';
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ScoreController.scoreHistory;
    final getHighestScore = ScoreController.getHighestScore();

    Widget mobileView() {
      return SizedBox(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                history
                    .map(
                      (score) => ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Score: ${score.score}'),
                            Text(
                              _formatEndType(score.endType),
                              style: TextStyle(
                                color:
                                    score.endType == EndType.victory
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text('Mode: ${score.gameMode.name}'),
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 016,
                            ).copyWith(bottom: 10),
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Elapsed (s): ${NumbersUtil.formatSeconds(score.elapsedTime)}',
                                ),
                                Text(
                                  'Remaining (s): ${NumbersUtil.formatSeconds(score.remainingTime)}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          ),
        ),
      );
    }

    Widget webTableView() {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.width * 0.6,
        ),
        child: IntrinsicHeight(
          child: SingleChildScrollView(
            child: DataTable(
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
                  label: Text('Remaining (s)', textAlign: TextAlign.center),
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
                            DataCell(Center(child: Text('${score.score}'))),
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
                                                score.endType == EndType.victory
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  NumbersUtil.formatSeconds(score.elapsedTime),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  NumbersUtil.formatSeconds(
                                    score.remainingTime,
                                  ),
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
      );
    }

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('${kIsWeb ? 'Score ' : ''}History'),
          if (getHighestScore != null)
            // trophy emoji with score
            Text(
              '🏆 Highest Score: $getHighestScore',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width:
              history.isEmpty
                  ? 320
                  : kIsWeb
                  ? 640
                  : MediaQuery.of(context).size.width * 0.6,
          child:
              history.isEmpty
                  ? const Text('No score history yet')
                  : kIsWeb
                  ? webTableView()
                  : mobileView(),
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
