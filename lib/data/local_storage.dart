class Movie {
  final String name;
  final String slug;
  final String thumbUrl;

  Movie({required this.name, required this.slug, required this.thumbUrl});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      name: json['name'],
      slug: json['slug'],
      thumbUrl: "https://img.phim.live/uploads/movies/" + json['thumb_url'],
    );
  }
}