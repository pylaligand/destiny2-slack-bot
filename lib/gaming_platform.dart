// Copyright (c) 2017 P.Y. Laligand

enum GamingPlatform {
  xbox,
  pc,
  playstation,
  unknown,
}

GamingPlatform stringToGamingPlatform(String platform) {
  switch (platform) {
    case 'xb':
      return GamingPlatform.xbox;
    case 'pc':
      return GamingPlatform.pc;
    case 'ps':
      return GamingPlatform.playstation;
    default:
      return GamingPlatform.unknown;
  }
}

bool isValidGamingPlatform(String platform) {
  return stringToGamingPlatform(platform) != GamingPlatform.unknown;
}
