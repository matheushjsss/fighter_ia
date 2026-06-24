class NewsModel {
  final String title;
  final String description;
  final String url;
  final String image;
  final DateTime? publishedAt;

  NewsModel(this.title, this.description, this.url, this.image,
      {this.publishedAt});

  /// Tempo relativo curto, ex.: "há 2h", "há 3d".
  String get timeAgo {
    if (publishedAt == null) return '';
    final diff = DateTime.now().difference(publishedAt!);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }
}
