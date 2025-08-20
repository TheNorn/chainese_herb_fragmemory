class Ebbinghaus {
  static DateTime getNextReviewDate(int reviewCount, DateTime lastStudied) {
    const intervals = [0, 1, 2, 4, 7, 15];
    final days = reviewCount < intervals.length
        ? intervals[reviewCount]
        : intervals.last;
    return lastStudied.add(Duration(days: days));
  }

  static double calculateMastery(int reviewCount, int correctCount) {
    return (correctCount / (reviewCount + 1)).clamp(0.0, 1.0);
  }
}
