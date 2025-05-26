class NumbersUtil {
  static String formatSeconds(int? seconds) {
    if(seconds == null) return '-';
    if (seconds < 60) {
      return '$seconds${'s'}';
    }
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (remainingSeconds == 0) {
      return '$minutes${'m'}';
    }
    
    return '$minutes${'m'} $remainingSeconds${'s'}';
  }
}