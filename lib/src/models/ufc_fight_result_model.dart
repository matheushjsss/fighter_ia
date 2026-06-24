class UfcFightResultModel {
  final bool hasResult;
  final String winnerName;
  final String winnerCorner; // 'red' | 'blue' | ''
  final String method;
  final String methodDetail;
  final int? roundEnd;
  final String timeEnd;
  final bool draw;
  final bool noContest;

  UfcFightResultModel({
    required this.hasResult,
    required this.winnerName,
    required this.winnerCorner,
    required this.method,
    required this.methodDetail,
    required this.roundEnd,
    required this.timeEnd,
    required this.draw,
    required this.noContest,
  });

  factory UfcFightResultModel.fromJson(Map<String, dynamic> json) {
    return UfcFightResultModel(
      hasResult: json['has_result'] == true,
      winnerName: (json['winner_name'] ?? '').toString(),
      winnerCorner: (json['winner_corner'] ?? '').toString(),
      method: (json['method'] ?? '').toString(),
      methodDetail: (json['method_detail'] ?? '').toString(),
      roundEnd: json['round_end'] as int?,
      timeEnd: (json['time_end'] ?? '').toString(),
      draw: json['draw'] == true,
      noContest: json['no_contest'] == true,
    );
  }
}
