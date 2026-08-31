import '../models/konversi_result.dart';

class KonversiService {
  static final Map<double, double> _faktorKonversiMap = {
    3: 0.40,
    7: 0.65,
    14: 0.88,
    21: 0.95,
    28: 1.00,
    29: 1.0032,
    30: 1.0065,
    31: 1.0097,
    32: 1.0129,
    33: 1.0161,
    34: 1.0194,
    35: 1.0226,
    36: 1.0258,
    37: 1.0290,
    38: 1.0323,
    39: 1.0355,
    40: 1.0387,
    41: 1.0419,
    42: 1.0452,
    43: 1.0484,
    44: 1.0516,
    45: 1.0548,
    46: 1.0581,
    47: 1.0613,
    48: 1.0645,
    49: 1.0677,
    50: 1.0710,
    51: 1.0742,
    52: 1.0774,
    53: 1.0806,
    54: 1.0839,
    55: 1.0871,
    56: 1.0903,
    57: 1.0935,
    58: 1.0968,
    59: 1.1000,
    60: 1.1032,
    61: 1.1065,
    62: 1.1097,
    63: 1.1129,
    64: 1.1161,
    65: 1.1194,
    66: 1.1226,
    67: 1.1258,
    68: 1.1290,
    69: 1.1323,
    70: 1.1355,
    71: 1.1387,
    72: 1.1419,
    73: 1.1452,
    74: 1.1484,
    75: 1.1516,
    76: 1.1548,
    77: 1.1581,
    78: 1.1613,
    79: 1.1645,
    80: 1.1677,
    81: 1.1710,
    82: 1.1742,
    83: 1.1774,
    84: 1.1806,
    85: 1.1839,
    86: 1.1871,
    87: 1.1903,
    88: 1.1935,
    89: 1.1968,
    90: 1.2000,
    91: 1.2006,
    92: 1.2011,
    93: 1.2016,
    94: 1.2022,
    95: 1.2027,
    96: 1.2033,
    97: 1.2038,
    98: 1.2044,
    99: 1.2049,
    100: 1.2055,
    101: 1.2060,
    102: 1.2065,
    103: 1.2071,
    104: 1.2076,
    105: 1.2082,
    106: 1.2087,
    107: 1.2093,
    108: 1.2098,
    109: 1.2104,
    110: 1.2109,
    111: 1.2115,
    112: 1.2120,
    113: 1.2126,
    114: 1.2131,
    115: 1.2136,
    116: 1.2142,
    117: 1.2147,
    118: 1.2153,
    119: 1.2158,
    120: 1.2164,
    121: 1.2169,
    122: 1.2175,
    123: 1.2180,
    124: 1.2186,
    125: 1.2191,
    126: 1.2196,
    127: 1.2202,
    128: 1.2207,
    129: 1.2213,
    130: 1.2218,
    131: 1.2224,
    132: 1.2229,
    133: 1.2235,
    134: 1.2240,
    135: 1.2246,
    136: 1.2251,
    137: 1.2256,
    138: 1.2262,
    139: 1.2267,
    140: 1.2273,
    141: 1.2278,
    142: 1.2284,
    143: 1.2289,
    144: 1.2295,
    145: 1.2300,
    146: 1.2306,
    147: 1.2311,
    148: 1.2316,
    149: 1.2322,
    150: 1.2327,
    151: 1.2333,
    152: 1.2338,
    153: 1.2344,
    154: 1.2349,
    155: 1.2355,
    156: 1.2360,
    157: 1.2365,
    158: 1.2371,
    159: 1.2376,
    160: 1.2382,
    161: 1.2387,
    162: 1.2393,
    163: 1.2398,
    164: 1.2404,
    165: 1.2409,
    166: 1.2415,
    167: 1.2420,
    168: 1.2425,
    169: 1.2431,
    170: 1.2436,
    171: 1.2442,
    172: 1.2447,
    173: 1.2453,
    174: 1.2458,
    175: 1.2464,
    176: 1.2469,
    177: 1.2475,
    178: 1.2480,
    179: 1.2485,
    180: 1.2491,
    181: 1.2496,
    182: 1.2502,
    183: 1.2507,
    184: 1.2513,
    185: 1.2518,
    186: 1.2524,
    187: 1.2529,
    188: 1.2535,
    189: 1.2540,
    190: 1.2545,
    191: 1.2551,
    192: 1.2556,
    193: 1.2562,
    194: 1.2567,
    195: 1.2573,
    196: 1.2578,
    197: 1.2584,
    198: 1.2589,
    199: 1.2595,
    200: 1.2600,
    201: 1.2605,
    202: 1.2611,
    203: 1.2616,
    204: 1.2622,
    205: 1.2627,
    206: 1.2633,
    207: 1.2638,
    208: 1.2644,
    209: 1.2649,
    210: 1.2655,
    211: 1.2660,
    212: 1.2665,
    213: 1.2671,
    214: 1.2676,
    215: 1.2682,
    216: 1.2687,
    217: 1.2693,
    218: 1.2698,
    219: 1.2704,
    220: 1.2709,
    221: 1.2715,
    222: 1.2720,
    223: 1.2725,
    224: 1.2731,
    225: 1.2736,
    226: 1.2742,
    227: 1.2747,
    228: 1.2753,
    229: 1.2758,
    230: 1.2764,
    231: 1.2769,
    232: 1.2775,
    233: 1.2780,
    234: 1.2785,
    235: 1.2791,
    236: 1.2796,
    237: 1.2802,
    238: 1.2807,
    239: 1.2813,
    240: 1.2818,
    241: 1.2824,
    242: 1.2829,
    243: 1.2835,
    244: 1.2840,
    245: 1.2845,
    246: 1.2851,
    247: 1.2856,
    248: 1.2862,
    249: 1.2867,
    250: 1.2873,
    251: 1.2878,
    252: 1.2884,
    253: 1.2889,
    254: 1.2895,
    255: 1.2900,
    256: 1.2905,
    257: 1.2911,
    258: 1.2916,
    259: 1.2922,
    260: 1.2927,
    261: 1.2933,
    262: 1.2938,
    263: 1.2944,
    264: 1.2949,
    265: 1.2955,
    266: 1.2960,
    267: 1.2965,
    268: 1.2971,
    269: 1.2976,
    270: 1.2982,
    271: 1.2987,
    272: 1.2993,
    273: 1.2998,
    274: 1.3004,
    275: 1.3009,
    276: 1.3015,
    277: 1.3020,
    278: 1.3025,
    279: 1.3031,
    280: 1.3036,
    281: 1.3042,
    282: 1.3047,
    283: 1.3053,
    284: 1.3058,
    285: 1.3064,
    286: 1.3069,
    287: 1.3075,
    288: 1.3080,
    289: 1.3085,
    290: 1.3091,
    291: 1.3096,
    292: 1.3102,
    293: 1.3107,
    294: 1.3113,
    295: 1.3118,
    296: 1.3124,
    297: 1.3129,
    298: 1.3135,
    299: 1.3140,
    300: 1.3145,
    301: 1.3151,
    302: 1.3156,
    303: 1.3162,
    304: 1.3167,
    305: 1.3173,
    306: 1.3178,
    307: 1.3184,
    308: 1.3189,
    309: 1.3195,
    310: 1.3200,
    311: 1.3205,
    312: 1.3211,
    313: 1.3216,
    314: 1.3222,
    315: 1.3227,
    316: 1.3233,
    317: 1.3238,
    318: 1.3244,
    319: 1.3249,
    320: 1.3255,
    321: 1.3260,
    322: 1.3265,
    323: 1.3271,
    324: 1.3276,
    325: 1.3282,
    326: 1.3287,
    327: 1.3293,
    328: 1.3298,
    329: 1.3304,
    330: 1.3309,
    331: 1.3315,
    332: 1.3320,
    333: 1.3325,
    334: 1.3331,
    335: 1.3336,
    336: 1.3342,
    337: 1.3347,
    338: 1.3353,
    339: 1.3358,
    340: 1.3364,
    341: 1.3369,
    342: 1.3375,
    343: 1.3380,
    344: 1.3385,
    345: 1.3391,
    346: 1.3396,
    347: 1.3402,
    348: 1.3407,
    349: 1.3413,
    350: 1.3418,
    351: 1.3424,
    352: 1.3429,
    353: 1.3435,
    354: 1.3440,
    355: 1.3445,
    356: 1.3451,
    357: 1.3456,
    358: 1.3462,
    359: 1.3467,
    360: 1.3473,
    361: 1.3478,
    362: 1.3484,
    363: 1.3489,
    364: 1.3495,
    365: 1.3500,
  };

 
  static const double faktorKubusSilinder = 0.83;
  static const double faktorSilinderKubus = 1.20;
 
  static double getFaktorKonversi(double umurBeton) {
   
    if (_faktorKonversiMap.containsKey(umurBeton)) {
      return _faktorKonversiMap[umurBeton]!;
    }

    
    if (umurBeton < 3) {
      return 0.40;
    }

    
    if (umurBeton >= 365) {
      return 1.35;
    }

    
    List<double> sortedKeys = _faktorKonversiMap.keys.toList()..sort();
    
    for (int i = 0; i < sortedKeys.length - 1; i++) {
      double lower = sortedKeys[i];
      double upper = sortedKeys[i + 1];
      
      if (umurBeton > lower && umurBeton < upper) {
        double lowerFactor = _faktorKonversiMap[lower]!;
        double upperFactor = _faktorKonversiMap[upper]!;
        
        
        double factor = lowerFactor + 
          (upperFactor - lowerFactor) * (umurBeton - lower) / (upper - lower);
        
        return double.parse(factor.toStringAsFixed(4));
      }
    }

    return 1.35;
  }

  
  static KonversiResult hitungKonversi({
    required double umurBeton,
    required double kuatTekanBeton,
    required String jenisBendaUji, 
    required String satuan, 
  }) {
    double faktorKonversi = getFaktorKonversi(umurBeton);
    
    
    double hasilKonversi = kuatTekanBeton / faktorKonversi;
    
   
    double hasilKonversiSilinder;
    double faktorBentuk;
    
    if (jenisBendaUji == 'kubus') {
      
      hasilKonversiSilinder = hasilKonversi * faktorKubusSilinder;
      faktorBentuk = faktorKubusSilinder;
    } else {
    
      hasilKonversiSilinder = hasilKonversi;
      faktorBentuk = 1.0;
    }
    
    String karakteristik = _getKarakteristik(umurBeton);

    return KonversiResult(
      umurBeton: umurBeton,
      faktorKonversi: faktorKonversi,
      kuatTekanBeton: kuatTekanBeton,
      hasilKonversi: hasilKonversi,
      hasilKonversiSilinder: hasilKonversiSilinder,
      faktorBentuk: faktorBentuk,
      karakteristik: karakteristik,
      jenisBendaUji: jenisBendaUji,
      satuan: satuan,
    );
  }

  
  static String _getKarakteristik(double umur) {
    if (umur <= 3) return 'Beton Sangat Muda';
    if (umur <= 7) return 'Beton Muda';
    if (umur <= 14) return 'Beton Sedang';
    if (umur <= 21) return 'Beton Mendekati Matang';
    if (umur <= 28) return 'Beton Matang (28 Hari)';
    if (umur <= 90) return 'Beton Matang Lanjut (29-90 Hari)';
    if (umur <= 180) return 'Beton Dewasa (91-180 Hari)';
    return 'Beton Sangat Dewasa (>180 Hari)';
  }

  
  static List<Map<String, dynamic>> getTabelReferensi() {
    return [
      {'umur': 3, 'faktor': 0.40, 'karakteristik': 'Beton Sangat Muda'},
      {'umur': 7, 'faktor': 0.65, 'karakteristik': 'Beton Muda'},
      {'umur': 14, 'faktor': 0.88, 'karakteristik': 'Beton Sedang'},
      {'umur': 21, 'faktor': 0.95, 'karakteristik': 'Beton Mendekati Matang'},
      {'umur': 28, 'faktor': 1.00, 'karakteristik': 'Beton Matang'},
      {'umur': 90, 'faktor': 1.20, 'karakteristik': 'Beton Matang Lanjut'},
      {'umur': 180, 'faktor': 1.249, 'karakteristik': 'Beton Dewasa'},
      {'umur': 365, 'faktor': 1.35, 'karakteristik': 'Beton Sangat Dewasa'},
    ];
  }
  
 
  static Map<double, double> getTabelLengkap() {
    return Map.from(_faktorKonversiMap);
  }
}