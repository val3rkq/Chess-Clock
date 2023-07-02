String formatMMSS(int seconds) {
  seconds = (seconds % 3600).truncate();
  final minutes = (seconds / 60).truncate();

  final minutesStr = (minutes).toString().padLeft(2, '0');
  final secondsStr = (seconds % 60).toString().padLeft(2, '0');

  return '$minutesStr:$secondsStr';
}

int formatToSeconds(String formattedTime) {
  String minutes = formattedTime.split(':')[0];
  String seconds = formattedTime.split(':')[1];
  int result = 0;
  if (seconds[0] == '0') {
    seconds = seconds[1];
  }
  result += int.parse(seconds);

  if (minutes[0] == '0') {
    minutes = minutes[1];
  }
  result += int.parse(minutes) * 60;
  return result;
}

