//
//  EclipticCalendar.swift
//  calendar
//
//  Created by 7080 on 2023/1/13.
//

import Foundation

// MARK: - 常量
struct SOLAR_TERMS_M {
    var time: Date
    var solarTerm: SOLAR_TERMS
}

private let JD2000 = 2451545.0
private let RADIAN_PER_ANGLE = Double.pi / 180.0
private let SOLAR_TERMS_COUNT = 24
private var VARWZDAYTIME: WZDAYTIME = (0, 0, 0, 0, 0, 0.0)
private var SOLAR_TERMS_NAMES = ["春分", "清明", "谷雨", "立夏", "小满", "芒种",
                                 "夏至", "小暑", "大暑", "立秋", "处暑", "白露",
                                 "秋分", "寒露", "霜降", "立冬", "小雪", "大雪",
                                 "冬至", "小寒", "大寒", "立春", "雨水", "惊蛰"]

// 节气定义
enum SOLAR_TERMS: Int {
    /// 春分
    case VERNAL_EQUINOX      = 0
    /// 清明
    case CLEAR_AND_BRIGHT    = 1
    /// 谷雨
    case GRAIN_RAIN          = 2
    /// 立夏
    case SUMMER_BEGINS       = 3
    /// 小满
    case GRAIN_BUDS          = 4
    /// 芒种
    case GRAIN_IN_EAR        = 5
    /// 夏至
    case SUMMER_SOLSTICE     = 6
    /// 小暑
    case SLIGHT_HEAT         = 7
    /// 大暑
    case GREAT_HEAT          = 8
    /// 立秋
    case AUTUMN_BEGINS       = 9
    /// 处暑
    case STOPPING_THE_HEAT   = 10
    /// 白露
    case WHITE_DEWS          = 11
    /// 秋分
    case AUTUMN_EQUINOX      = 12
    /// 寒露
    case COLD_DEWS           = 13
    /// 霜降
    case HOAR_FROST_FALLS    = 14
    /// 立冬
    case WINTER_BEGINS       = 15
    /// 小雪
    case LIGHT_SNOW          = 16
    /// 大雪
    case HEAVY_SNOW          = 17
    /// 冬至
    case WINTER_SOLSTICE     = 18
    /// 小寒
    case SLIGHT_COLD         = 19
    /// 大寒
    case GREAT_COLD          = 20
    /// 立春
    case SPRING_BEGINS       = 21
    /// 雨水
    case THE_RAINS           = 22
    /// 惊蛰
    case INSECTS_AWAKEN      = 23
}

extension SOLAR_TERMS: SOLAR_TERMS_NAME {
    var solarTermsName: String {
        return SOLAR_TERMS_NAMES[self.rawValue]
    }
}

protocol SOLAR_TERMS_NAME {
    var solarTermsName: String { get }
}

private typealias VSOP87_COEFFICIENT = (A: Double, B: Double, C: Double)
/*数据来源是：《天文计算》 附录II*/
// 计算太阳黄经周期项
private let Earth_L0: [VSOP87_COEFFICIENT] = [
        ( 175347046.0 ,   0.0000000 ,   000000.0000000 ) ,
        (   3341656.0 ,   4.6692568 ,     6283.0758500 ) ,
        (     34894.0 ,   4.6261000 ,    12566.1517000 ) ,
        (      3497.0 ,   2.7441000 ,     5753.3849000 ) ,
        (      3418.0 ,   2.8289000 ,        3.5231000 ) ,
        (      3136.0 ,   3.6277000 ,    77713.7715000 ) ,
        (      2676.0 ,   4.4181000 ,     7860.4194000 ) ,
        (      2343.0 ,   6.1352000 ,     3930.2097000 ) ,
        (      1324.0 ,   0.7425000 ,    11506.7698000 ) ,
        (      1273.0 ,   2.0371000 ,      529.6910000 ) ,
        (      1799.0 ,   1.1096000 ,     1577.3435000 ) ,
        (       990.0 ,   5.2330000 ,     5884.9270000 ) ,
        (       902.0 ,   2.0450000 ,       26.2980000 ) ,
        (       857.0 ,   3.5080000 ,      398.1490000 ) ,
        (       780.0 ,   1.1790000 ,     5223.6940000 ) ,
        (       753.0 ,   2.5330000 ,     5507.5530000 ) ,
        (       505.0 ,   4.5830000 ,    18849.2280000 ) ,
        (       492.0 ,   4.2050000 ,      775.5230000 ) ,
        (       357.0 ,   2.9200000 ,   000000.0670000 ) ,
        (       317.0 ,   5.8490000 ,    11790.6290000 ) ,
        (       284.0 ,   1.8990000 ,      796.2980000 ) ,
        (       271.0 ,   0.3150000 ,    10977.0790000 ) ,
        (       243.0 ,   0.3450000 ,     5486.7780000 ) ,
        (       206.0 ,   4.8060000 ,     2544.3140000 ) ,
        (       205.0 ,   1.8690000 ,     5573.1430000 ) ,
        (       202.0 ,   2.4580000 ,     6069.7770000 ) ,
        (       156.0 ,   0.8330000 ,      213.2990000 ) ,
        (       132.0 ,   3.4110000 ,     2942.4630000 ) ,
        (       126.0 ,   1.0830000 ,       20.7750000 ) ,
        (       119.0 ,   0.6450000 ,   000000.9800000 ) ,
        (       107.0 ,   0.6360000 ,     4694.0030000 ) ,
        (       102.0 ,   0.9760000 ,    15720.8390000 ) ,
        (       102.0 ,   4.2670000 ,        7.1140000 ) ,
        (        99.0 ,   6.2100000 ,     2146.1700000 ) ,
        (        98.0 ,   0.6800000 ,      155.4200000 ) ,
        (        86.0 ,   5.9800000 ,   161000.6900000 ) ,
        (        85.0 ,   1.3000000 ,     6275.9600000 ) ,
        (        85.0 ,   3.6700000 ,    71430.7000000 ) ,
        (        80.0 ,   1.8100000 ,    17260.1500000 ) ,
        (        79.0 ,   3.0400000 ,    12036.4600000 ) ,
        (        75.0 ,   1.7600000 ,     5088.6300000 ) ,
        (        74.0 ,   3.5000000 ,     3154.6900000 ) ,
        (        74.0 ,   4.6800000 ,      801.8200000 ) ,
        (        70.0 ,   0.8300000 ,     9437.7600000 ) ,
        (        62.0 ,   3.9800000 ,     8827.3900000 ) ,
        (        61.0 ,   1.8200000 ,     7084.9000000 ) ,
        (        57.0 ,   2.7800000 ,     6286.6000000 ) ,
        (        56.0 ,   4.3900000 ,    14143.5000000 ) ,
        (        56.0 ,   3.4700000 ,     6279.5500000 ) ,
        (        52.0 ,   0.1900000 ,    12139.5500000 ) ,
        (        52.0 ,   1.3300000 ,     1748.0200000 ) ,
        (        51.0 ,   0.2800000 ,     5856.4800000 ) ,
        (        49.0 ,   0.4900000 ,     1194.4500000 ) ,
        (        41.0 ,   5.3700000 ,     8429.2400000 ) ,
        (        41.0 ,   2.4000000 ,    19651.0500000 ) ,
        (        39.0 ,   6.1700000 ,    10447.3900000 ) ,
        (        37.0 ,   6.0400000 ,    10213.2900000 ) ,
        (        37.0 ,   2.5700000 ,     1059.3800000 ) ,
        (        36.0 ,   1.7100000 ,     2352.8700000 ) ,
        (        36.0 ,   1.7800000 ,     6812.7700000 ) ,
        (        33.0 ,   0.5900000 ,    17789.8500000 ) ,
        (        30.0 ,   0.4400000 ,    83996.8500000 ) ,
        (        30.0 ,   2.7400000 ,     1349.8700000 ) ,
        (        25.0 ,   3.1600000 ,     4690.4800000 )
]

private let Earth_L1: [VSOP87_COEFFICIENT] = [
        ( 628331966747.0 , 0.000000 ,   00000.0000000 ) ,
        (       206059.0 , 2.678235 ,    6283.0758500 ) ,
        (         4303.0 , 2.635100 ,   12566.1517000 ) ,
        (          425.0 , 1.590000 ,       3.5230000 ) ,
        (          119.0 , 5.796000 ,      26.2980000 ) ,
        (          109.0 , 2.966000 ,    1577.3440000 ) ,
        (           93.0 , 2.590000 ,   18849.2300000 ) ,
        (           72.0 , 1.140000 ,     529.6900000 ) ,
        (           68.0 , 1.870000 ,     398.1500000 ) ,
        (           67.0 , 4.410000 ,    5507.5500000 ) ,
        (           59.0 , 2.890000 ,    5223.6900000 ) ,
        (           56.0 , 2.170000 ,     155.4200000 ) ,
        (           45.0 , 0.400000 ,     796.3000000 ) ,
        (           36.0 , 0.470000 ,     775.5200000 ) ,
        (           29.0 , 2.650000 ,       7.1100000 ) ,
        (           21.0 , 5.340000 ,   00000.9800000 ) ,
        (           19.0 , 1.850000 ,    5486.7800000 ) ,
        (           19.0 , 4.970000 ,     213.3000000 ) ,
        (           17.0 , 2.990000 ,    6275.9600000 ) ,
        (           16.0 , 0.030000 ,    2544.3100000 ) ,
        (           16.0 , 1.430000 ,    2146.1700000 ) ,
        (           15.0 , 1.210000 ,   10977.0800000 ) ,
        (           12.0 , 2.830000 ,    1748.0200000 ) ,
        (           12.0 , 3.260000 ,    5088.6300000 ) ,
        (           12.0 , 5.270000 ,    1194.4500000 ) ,
        (           12.0 , 2.080000 ,    4694.0000000 ) ,
        (           11.0 , 0.770000 ,     553.5700000 ) ,
        (           10.0 , 1.300000 ,    6286.6000000 ) ,
        (           10.0 , 4.240000 ,    1349.8700000 ) ,
        (            9.0 , 2.700000 ,     242.7300000 ) ,
        (            9.0 , 5.640000 ,     951.7200000 ) ,
        (            8.0 , 5.300000 ,    2352.8700000 ) ,
        (            6.0 , 2.650000 ,    9437.7600000 ) ,
        (            6.0 , 4.670000 ,    4690.4800000 )
]

private let Earth_L2: [VSOP87_COEFFICIENT] = [
        ( 52919.0 ,   0.0000 ,   00000.0000 ) ,
        ( 8720.0  ,   1.0721 ,   6283.0758  ) ,
        (   309.0 ,   0.8670 ,   12566.1520 ) ,
        (    27.0 ,   0.0500 ,       3.5200 ) ,
        (    16.0 ,   5.1900 ,      26.3000 ) ,
        (    16.0 ,   3.6800 ,     155.4200 ) ,
        (    10.0 ,   0.7600 ,   18849.2300 ) ,
        (     9.0 ,   2.0600 ,   77713.7700 ) ,
        (     7.0 ,   0.8300 ,     775.5200 ) ,
        (     5.0 ,   4.6600 ,    1577.3400 ) ,
        (     4.0 ,   1.0300 ,       7.1100 ) ,
        (     4.0 ,   3.4400 ,    5573.1400 ) ,
        (     3.0 ,   5.1400 ,     796.3000 ) ,
        (     3.0 ,   6.0500 ,    5507.5500 ) ,
        (     3.0 ,   1.1900 ,     242.7300 ) ,
        (     3.0 ,   6.1200 ,     529.6900 ) ,
        (     3.0 ,   0.3100 ,     398.1500 ) ,
        (     3.0 ,   2.2800 ,     553.5700 ) ,
        (     2.0 ,   4.3800 ,    5223.6900 ) ,
        (     2.0 ,   3.7500 ,   00000.9800 )
]

private let Earth_L3: [VSOP87_COEFFICIENT] = [
        ( 289.0 ,   5.844 , 6283.076  ) ,
        ( 35.0  ,   0.000 , 00000.000 ) ,
        ( 17.0  ,   5.490 , 12566.150 ) ,
        (   3.0 ,   5.200 ,   155.420 ) ,
        (   1.0 ,   4.720 ,     3.520 ) ,
        (   1.0 ,   5.300 , 18849.230 ) ,
        (   1.0 ,   5.970 ,   242.730 )
]

private let Earth_L4: [VSOP87_COEFFICIENT] = [
        ( 114.0 , 3.142 , 00000.00 ) ,
        (   8.0 , 4.130 ,  6283.08 ) ,
        (   1.0 , 3.840 , 12566.15 )
]

private let Earth_L5: [VSOP87_COEFFICIENT] = [
        ( 1.0 , 3.14 , 0.0 )
]

// 计算太阳黄纬周期项
private let Earth_B0: [VSOP87_COEFFICIENT] = [
        ( 280.0 , 3.199 , 84334.662) ,
        ( 102.0 , 5.422 , 5507.553 ) ,
        ( 80.0  , 3.880 , 5223.690 ) ,
        ( 44.0  , 3.700 , 2352.870 ) ,
        ( 32.0  , 4.000 , 1577.340 )
]

private let Earth_B1: [VSOP87_COEFFICIENT] = [
        ( 9.0 , 3.90 , 5507.55 ) ,
        ( 6.0 , 1.73 , 5223.69 )
]


private let Earth_B2: [VSOP87_COEFFICIENT] = [
        ( 22378.0 , 3.38509 , 10213.28555 ) ,
        (   282.0 , 0.00000 , 00000.00000 ) ,
        (   173.0 , 5.25600 , 20426.57100 ) ,
        (    27.0 , 3.87000 , 30639.86000 )
]

private let Earth_B3: [VSOP87_COEFFICIENT] = [
        ( 647.0 , 4.992 , 10213.286 ) ,
        ( 20.0  , 3.140 , 00000.000 ) ,
        (   6.0 , 0.770 , 20426.570 ) ,
        (   3.0 , 5.440 , 30639.860 )
]

private let Earth_B4: [VSOP87_COEFFICIENT] = [
        ( 14.0 , 0.32 , 10213.29 )
]

// 计算日地经距离周期项
private let Earth_R0: [VSOP87_COEFFICIENT] = [
        ( 100013989   , 0         ,    0           ),
        ( 1670700     , 3.0984635 ,    6283.0758500),
        ( 13956       , 3.05525   ,   12566.15170  ),
        ( 3084        , 5.1985    ,   77713.7715   ),
        ( 1628        , 1.1739    ,   5753.3849    ),
        ( 1576        , 2.8469    ,   7860.4194    ),
        ( 925         , 5.453     ,   11506.770    ),
        ( 542         , 4.564     ,   3930.210     ),
        ( 472         , 3.661     ,   5884.927     ),
        ( 346         , 0.964     ,   5507.553     ),
        ( 329         , 5.900     ,   5223.694     ),
        ( 307         , 0.299     ,   5573.143     ),
        ( 243         , 4.273     ,   11790.629    ),
        ( 212         , 5.847     ,   1577.344     ),
        ( 186         , 5.022     ,   10977.079    ),
        ( 175         , 3.012     ,   18849.228    ),
        ( 110         , 5.055     ,   5486.778     ),
        ( 98          , 0.89      ,   6069.78      ),
        ( 86          , 5.69      ,   15720.84     ),
        ( 86          , 1.27      ,   161000.69    ),
        ( 65          , 0.27      ,   17260.15     ),
        ( 63          , 0.92      ,   529.69       ),
        ( 57          , 2.01      ,   83996.85     ),
        ( 56          , 5.24      ,   71430.70     ),
        ( 49          , 3.25      ,   2544.31      ),
        ( 47          , 2.58      ,   775.52       ),
        ( 45          , 5.54      ,   9437.76      ),
        ( 43          , 6.01      ,   6275.96      ),
        ( 39          , 5.36      ,   4694.00      ),
        ( 38          , 2.39      ,   8827.39      ),
        ( 37          , 0.83      ,   19651.05     ),
        ( 37          , 4.90      ,   12139.55     ),
        ( 36          , 1.67      ,   12036.46     ),
        ( 35          , 1.84      ,   2942.46      ),
        ( 33          , 0.24      ,   7084.90      ),
        ( 32          , 0.18      ,   5088.63      ),
        ( 32          , 1.78      ,   398.15       ),
        ( 28          , 1.21      ,   6286.60      ),
        ( 28          , 1.90      ,   6279.55      ),
        ( 26          , 4.59      ,   10447.39     )
]

private let Earth_R1: [VSOP87_COEFFICIENT] = [
        ( 103019 , 1.107490 , 6283.075850 ),
        ( 1721   , 1.0644   , 12566.1517  ),
        ( 702    , 3.142    , 0           ),
        ( 32     , 1.02     , 18849.23    ),
        ( 31     , 2.84     , 5507.55     ),
        ( 25     , 1.32     , 5223.69     ),
        ( 18     , 1.42     , 1577.34     ),
        ( 10     , 5.91     , 10977.08    ),
        ( 9      , 1.42     , 6275.96     ),
        ( 9      , 0.27     , 5486.78     )
]

private let Earth_R2: [VSOP87_COEFFICIENT] = [
        ( 4359 , 5.7846 , 6283.0758 ),
        ( 124  , 5.579  , 12566.152 ),
        ( 12   , 3.14   , 0         ),
        ( 9    , 3.63   , 77713.77  ),
        ( 6    , 1.87   , 5573.14   ),
        ( 3    , 5.47   , 18849.23  )
]

private let Earth_R3: [VSOP87_COEFFICIENT] = [
        ( 145 , 4.273 , 6283.076 ),
        (   7 , 3.92 ,  12566.15 )
]

private let Earth_R4: [VSOP87_COEFFICIENT] = [
        ( 4 , 2.56 , 6283.08 )
]

//天体章动系数类型变量
private typealias NUTATION_COEFFICIENT = (D: Double, M: Double, Mp: Double, F: Double, omega: Double, sine1: Double, sine2: Double, cosine1: Double, cosine2: Double)
private let nutation: [NUTATION_COEFFICIENT] = [
        ( 0, 0, 0, 0, 1, -171996,  -174.2,  92025,     8.9    ),
        (-2, 0, 0, 2, 2,  -13187,    -1.6,   5736,    -3.1    ),
        ( 0, 0, 0, 2, 2,   -2274,    -0.2,    977,    -0.5    ),
        ( 0, 0, 0, 0, 2,    2062,     0.2,   -895,     0.5    ),
        ( 0, 1, 0, 0, 0,    1426,    -3.4,     54,    -0.1    ),
        ( 0, 0, 1, 0, 0,     712,     0.1,     -7,       0    ),
        (-2, 1, 0, 2, 2,    -517,     1.2,    224,    -0.6    ),
        ( 0, 0, 0, 2, 1,    -386,    -0.4,    200,       0    ),
        ( 0, 0, 1, 2, 2,    -301,       0,    129,    -0.1    ),
        (-2,-1, 0, 2, 2,     217,    -0.5,    -95,     0.3    ),
        (-2, 0, 1, 0, 0,    -158,       0,      0,       0    ),
        (-2, 0, 0, 2, 1,     129,     0.1,    -70,       0    ),
        ( 0, 0,-1, 2, 2,     123,       0,    -53,       0    ),
        ( 2, 0, 0, 0, 0,      63,       0,      0,       0    ),
        ( 0, 0, 1, 0, 1,      63,     0.1,    -33,       0    ),
        ( 2, 0,-1, 2, 2,     -59,       0,     26,       0    ),
        ( 0, 0,-1, 0, 1,     -58,    -0.1,     32,       0    ),
        ( 0, 0, 1, 2, 1,     -51,       0,     27,       0    ),
        (-2, 0, 2, 0, 0,      48,       0,      0,       0    ),
        ( 0, 0,-2, 2, 1,      46,       0,    -24,       0    ),
        ( 2, 0, 0, 2, 2,     -38,       0,     16,       0    ),
        ( 0, 0, 2, 2, 2,     -31,       0,     13,       0    ),
        ( 0, 0, 2, 0, 0,      29,       0,      0,       0    ),
        (-2, 0, 1, 2, 2,      29,       0,    -12,       0    ),
        ( 0, 0, 0, 2, 0,      26,       0,      0,       0    ),
        (-2, 0, 0, 2, 0,     -22,       0,      0,       0    ),
        ( 0, 0,-1, 2, 1,      21,       0,    -10,       0    ),
        ( 0, 2, 0, 0, 0,      17,    -0.1,      0,       0    ),
        ( 2, 0,-1, 0, 1,      16,       0,     -8,       0    ),
        (-2, 2, 0, 2, 2,     -16,     0.1,      7,       0    ),
        ( 0, 1, 0, 0, 1,     -15,       0,      9,       0    ),
        (-2, 0, 1, 0, 1,     -13,       0,      7,       0    ),
        ( 0,-1, 0, 0, 1,     -12,       0,      6,       0    ),
        ( 0, 0, 2,-2, 0,      11,       0,      0,       0    ),
        ( 2, 0,-1, 2, 1,     -10,       0,      5,       0    ),
        ( 2, 0, 1, 2, 2,      -8,       0,      3,       0    ),
        ( 0, 1, 0, 2, 2,       7,       0,     -3,       0    ),
        (-2, 1, 1, 0, 0,      -7,       0,      0,       0    ),
        ( 0,-1, 0, 2, 2,      -7,       0,      3,       0    ),
        ( 2, 0, 0, 2, 1,      -7,       0,      3,       0    ),
        ( 2, 0, 1, 0, 0,       6,       0,      0,       0    ),
        (-2, 0, 2, 2, 2,       6,       0,     -3,       0    ),
        (-2, 0, 1, 2, 1,       6,       0,     -3,       0    ),
        ( 2, 0,-2, 0, 1,      -6,       0,      3,       0    ),
        ( 2, 0, 0, 0, 1,      -6,       0,      3,       0    ),
        ( 0,-1, 1, 0, 0,       5,       0,      0,       0    ),
        (-2,-1, 0, 2, 1,      -5,       0,      3,       0    ),
        (-2, 0, 0, 0, 1,      -5,       0,      3,       0    ),
        ( 0, 0, 2, 2, 1,      -5,       0,      3,       0    ),
        (-2, 0, 2, 0, 1,       4,       0,      0,       0    ),
        (-2, 1, 0, 2, 1,       4,       0,      0,       0    ),
        ( 0, 0, 1,-2, 0,       4,       0,      0,       0    ),
        (-1, 0, 1, 0, 0,      -4,       0,      0,       0    ),
        (-2, 1, 0, 0, 0,      -4,       0,      0,       0    ),
        ( 1, 0, 0, 0, 0,      -4,       0,      0,       0    ),
        ( 0, 0, 1, 2, 0,       3,       0,      0,       0    ),
        ( 0, 0,-2, 2, 2,      -3,       0,      0,       0    ),
        (-1,-1, 1, 0, 0,      -3,       0,      0,       0    ),
        ( 0, 1, 1, 0, 0,      -3,       0,      0,       0    ),
        ( 0,-1, 1, 2, 2,      -3,       0,      0,       0    ),
        ( 2,-1,-1, 2, 2,      -3,       0,      0,       0    ),
        ( 0, 0, 3, 2, 2,      -3,       0,      0,       0    ),
        ( 2,-1, 0, 2, 2,      -3,       0,      0,       0    )
]

private typealias TD_UTC_DELTA = (year: Int, d1: Double, d2: Double, d3: Double, d4: Double)
// TD - UT1 计算表
private let deltaTbl: [TD_UTC_DELTA] = [
        ( -4000,108371.7,-13036.80,392.000, 0.0000 ),
        ( -500, 17201.0,  -627.82, 16.170,-0.3413  ),
        (  -150, 12200.6,  -346.41,  5.403,-0.1593 ),
        ( 150,  9113.8,  -328.13, -1.647, 0.0377   ),
        ( 500,  5707.5,  -391.41,  0.915, 0.3145   ),
        ( 900,  2203.4,  -283.45, 13.034,-0.1778   ),
        ( 1300,   490.1,   -57.35,  2.085,-0.0072  ),
        ( 1600,   120.0,    -9.81, -1.532, 0.1403  ),
        ( 1700,    10.2,    -0.91,  0.510,-0.0370  ),
        ( 1800,    13.4,    -0.72,  0.202,-0.0193  ),
        ( 1830,     7.8,    -1.81,  0.416,-0.0247  ),
        ( 1860,     8.3,    -0.13, -0.406, 0.0292  ),
        ( 1880,    -5.4,     0.32, -0.183, 0.0173  ),
        ( 1900,    -2.3,     2.06,  0.169,-0.0135  ),
        ( 1920,    21.2,     1.69, -0.304, 0.0167  ),
        ( 1940,    24.2,     1.22, -0.064, 0.0031  ),
        ( 1960,    33.2,     0.51,  0.231,-0.0109  ),
        ( 1980,    51.0,     1.29, -0.026, 0.0032  ),
        ( 2000,    63.87,    0.1,   0.0,     0.0   ),
        ( 2005,    0.0,      0.0,   0.0,   0.0     )
]

typealias WZDAYTIME = (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Double)

// MARK: - 天文方法计算二十四节气
/*从某一年的某个节气开始，连续计算24个节气，返回各节气的儒略日，UTC时间*/
func GetAllSolarTermsJD(_ year: Int,_ start: SOLAR_TERMS) -> [SOLAR_TERMS_M]? {
    var wzDayTimes = [(time: WZDAYTIME, solarTerm: SOLAR_TERMS)]()
    var year = year
    var i = 0
    var st = start.rawValue
    while i < SOLAR_TERMS_COUNT {
        let jd = CalculateSolarTerms(year, st * 15)
        let utcJd = JDTDtoUTC(jd)
        GetDayTimeFromJulianDay(utcJd, &VARWZDAYTIME)
        let stEnum = SOLAR_TERMS(rawValue: st)!
        wzDayTimes.append((VARWZDAYTIME, stEnum))
        if stEnum == .WINTER_SOLSTICE {
            year += 1
        }
        st = (st + 1) % SOLAR_TERMS_COUNT
        i += 1
    }
    
    var solarTerms = [SOLAR_TERMS_M]()
    var coms = DateComponents()
    var calender = Calendar.current
    calender.timeZone = .init(secondsFromGMT: 0) ?? .current
    for dayTime in wzDayTimes {
        coms.year = dayTime.time.year
        coms.month = dayTime.time.month
        coms.day = dayTime.time.day
        coms.hour = dayTime.time.hour
        coms.minute = dayTime.time.minute
        coms.second = Int(dayTime.time.second)
        
        if let date = calender.date(from: coms) {
            solarTerms.append(SOLAR_TERMS_M(time: date, solarTerm: dayTime.solarTerm))
        }
    }
    
    if solarTerms.count != SOLAR_TERMS_COUNT {
        return nil
    }
    
    return solarTerms
}

// 计算指定年份的任意节气，angle是节气在黄道上的度数
// 返回指定节气的儒略日时间(力学时)
private func CalculateSolarTerms(_ year: Int,_ angle: Int) -> Double {
    var JD0, JD1, stDegree, stDegreep: Double
    
    JD1 = GetInitialEstimateSolarTerms(year, angle)
    repeat {
        JD0 = JD1
        stDegree = GetSunEclipticLongitudeEC(JD0)
        /*
         对黄经0度迭代逼近时，由于角度360度圆周性，估算黄经值可能在(345,360]和[0,15)两个区间，
         如果值落入前一个区间，需要进行修正
         */
        stDegree = ((angle == 0) && (stDegree > 345.0)) ? stDegree - 360.0 : stDegree
        stDegreep = (GetSunEclipticLongitudeEC(JD0 + 0.000005)
                     - GetSunEclipticLongitudeEC(JD0 - 0.000005)) / 0.00001
        JD1 = JD0 - (stDegree - Double(angle)) / stDegreep
    } while((fabs(JD1 - JD0) > 0.0000001))
    
    return JD1
}

private func GetInitialEstimateSolarTerms(_ year: Int,_ angle: Int) -> Double {
    var STMonth = Int(ceil((Double(angle) + 90.0) / 30.0))
    STMonth = STMonth > 12 ? STMonth - 12 : STMonth
    
    /* 每月第一个节气发生日期基本都4-9日之间，第二个节气的发生日期都在16－24日之间*/
    if ((angle % 15 == 0) && (angle % 30 != 0)) {
        return CalculateJulianDay(year, STMonth, 6, 12, 0, 0.00)
    } else {
        return CalculateJulianDay(year, STMonth, 20, 12, 0, 0.00)
    }
}

/*得到某个儒略日的太阳地心黄经(视黄经)，单位度*/
private func GetSunEclipticLongitudeEC(_ jde: Double) -> Double {
    let dt = (jde - JD2000) / 365250.0 /*儒略千年数*/
    
    // 计算太阳的地心黄经
    var longitude = CalcSunEclipticLongitudeEC(dt)
    
    // 计算太阳的地心黄纬
    let latitude = CalcSunEclipticLatitudeEC(dt) * 3600.0
    
    // 修正精度
    longitude += AdjustSunEclipticLongitudeEC(dt, longitude, latitude)
    
    // 修正天体章动
    longitude += CalcEarthLongitudeNutation(dt)
    
    // 修正光行差
    /*太阳地心黄经光行差修正项是: -20".4898/R*/
    longitude -= (20.4898 / CalcSunEarthRadius(dt)) / 3600.0
    
    return longitude
}

private func CalcPeriodicTerm(_ coffs: [VSOP87_COEFFICIENT],_ dt: Double) -> Double {
    var val = 0.0
    
    for coff in coffs {
        val += (coff.A * cos((coff.B + coff.C * dt)))
    }
    
    return val
}

private func CalcSunEclipticLongitudeEC(_ dt: Double) -> Double {
    let L0 = CalcPeriodicTerm(Earth_L0, dt)
    let L1 = CalcPeriodicTerm(Earth_L1, dt)
    let L2 = CalcPeriodicTerm(Earth_L2, dt)
    let L3 = CalcPeriodicTerm(Earth_L3, dt)
    let L4 = CalcPeriodicTerm(Earth_L4, dt)
    let L5 = CalcPeriodicTerm(Earth_L5, dt)
    
    let L = (((((L5 * dt + L4) * dt + L3) * dt + L2) * dt + L1) * dt + L0) / 100000000.0
    
    /*地心黄经 = 日心黄经 + 180度*/
    return (Mod360Degree(Mod360Degree(L / RADIAN_PER_ANGLE) + 180.0))
}

private func CalcSunEclipticLatitudeEC(_ dt: Double) -> Double {
    let B0 = CalcPeriodicTerm(Earth_B0, dt)
    let B1 = CalcPeriodicTerm(Earth_B1, dt)
    let B2 = CalcPeriodicTerm(Earth_B2, dt)
    let B3 = CalcPeriodicTerm(Earth_B3, dt)
    let B4 = CalcPeriodicTerm(Earth_B4, dt)
    
    let B = (((((B4 * dt) + B3) * dt + B2) * dt + B1) * dt + B0) / 100000000.0
    
    /*地心黄纬 = －日心黄纬*/
    return -(B / RADIAN_PER_ANGLE)
}

/*修正太阳的地心黄经，longitude, latitude 是修正前的太阳地心黄经和地心黄纬(度)，dt是儒略千年数，返回值单位度*/
private func AdjustSunEclipticLongitudeEC(_ dt: Double,_ longitude: Double,_ latitude: Double) -> Double {
    let T = dt * 10 //T是儒略世纪数
    
    var dbLdash = longitude - 1.397 * T - 0.00031 * T * T
    
    // 转换为弧度
    dbLdash *= RADIAN_PER_ANGLE
    
    return (-0.09033 + 0.03916 * (cos(dbLdash) + sin(dbLdash)) * tan(latitude * RADIAN_PER_ANGLE)) / 3600.0
}

/*计算某时刻的黄经章动干扰量，dt是儒略千年数，返回值单位是度*/
private func CalcEarthLongitudeNutation(_ dt: Double) -> Double {
    let T = dt * 10
    var D, M, Mp, F, Omega: Double
    D = 0
    M = 0
    Mp = 0
    F = 0
    Omega = 0
    
    GetEarthNutationParameter(dt, &D, &M, &Mp, &F, &Omega)
    
    var resulte = 0.0
    for aNutation in nutation {
        var sita = aNutation.D * D + aNutation.M * M + aNutation.Mp * Mp + aNutation.F * F + aNutation.omega * Omega
        sita = DegreeToRadian(sita)
        
        resulte += (aNutation.sine1 + aNutation.sine2 * T) * sin(sita)
    }
    
    /*先乘以章动表的系数 0.0001，然后换算成度的单位*/
    return resulte * 0.0001 / 3600.0
}

private func CalcSunEarthRadius(_ dt: Double) -> Double {
    let R0 = CalcPeriodicTerm(Earth_R0, dt)
    let R1 = CalcPeriodicTerm(Earth_R1, dt)
    let R2 = CalcPeriodicTerm(Earth_R2, dt)
    let R3 = CalcPeriodicTerm(Earth_R3, dt)
    let R4 = CalcPeriodicTerm(Earth_R4, dt)
    
    let R = (((((R4 * dt) + R3) * dt + R2) * dt + R1) * dt + R0) / 100000000.0
    
    return R
}

private func CalculateJulianDay(_ year: Int,_ month: Int,_ day: Int,_ hour: Int,_ minute: Int,_ second: Double) -> Double {
    var month = month, year = year
    if month <= 2 {
        month += 12
        year -= 1
    }
    var B = -2
    if IsGregorianDays(year, month, day) {
        B = year / 400 - year / 100
    }
    
    let a = 365.25 * Double(year)
    let b = 30.6001 * Double(month + 1)
    let sum1 = Double(Int(a) + Int(b) + B)
    let sum2 = Double(day) + Double(hour) / 24.0 + Double(minute) / 1440.0 + second / 86400.0
    return sum1 + 1720996.5 + sum2
}

/*
 判断是否是启用格里历以后的日期
 1582年，罗马教皇将1582年10月4日指定为1582年10月15日，从此废止了凯撒大帝制定的儒略历，
 改用格里历
 */
private func IsGregorianDays(_ year: Int,_ month: Int,_ day: Int) -> Bool {
    if year < 1582 { return false }
    
    if year == 1582 {
        if ((month < 10) || ((month == 10) && (day < 15))) { return false }
    }
    
    return true
}

private func Mod360Degree(_ degrees: Double) -> Double {
    var dbValue = degrees
    
    while (dbValue < 0.0) { dbValue += 360.0 }
    
    while (dbValue > 360.0) { dbValue -= 360.0 }
    
    return dbValue
}

private func GetEarthNutationParameter(_ dt: Double,_ D: inout Double,_ M: inout Double,_ Mp: inout Double,_ F: inout Double,_ Omega: inout Double) {
    let T = dt * 10 /*T是从J2000起算的儒略世纪数*/
    let T2 = T * T
    let T3 = T2 * T
    
    /*平距角（如月对地心的角距离）*/
    D = 297.85036 + 445267.111480 * T - 0.0019142 * T2 + T3 / 189474.0
    
    /*太阳（地球）平近点角*/
    M = 357.52772 + 35999.050340 * T - 0.0001603 * T2 - T3 / 300000.0
    
    /*月亮平近点角*/
    Mp = 134.96298 + 477198.867398 * T + 0.0086972 * T2 + T3 / 56250.0
    
    /*月亮纬度参数*/
    F = 93.27191 + 483202.017538 * T - 0.0036825 * T2 + T3 / 327270.0
    
    /*黄道与月亮平轨道升交点黄经*/
    Omega = 125.04452 - 1934.136261 * T + 0.0020708 * T2 + T3 / 450000.0
}

private func DegreeToRadian(_ degree: Double) -> Double {
    return degree * Double.pi / 180.0
}

private func JDTDtoUTC(_ tdJD: Double) -> Double {
    var tdJD = tdJD
    let jd2K = tdJD - JD2000
    let tian = TdUtcDeltatT2(jd2K)
    tdJD -= tian
    
    return tdJD
}

private func TdUtcDeltatT2(_ jd2k: Double) -> Double {
    //传入儒略日(J2000起算),计算TD-UT(单位:日)
    return TdUtcDeltatT(jd2k / 365.2425 + 2000) / 86400.0
}

private func TdUtcDeltatT(_ y: Double) -> Double {
    //计算世界时与原子时之差,传入年
    if y >= 2005 {
        //sd是2005年之后几年（一值到y1年）的速度估计。
        //sjd是y1年之后的加速度估计。瑞士星历表jsd=31,NASA网站jsd=32,skmap的jsd=29
        let y1 = 2014.0
        let sd = 0.4
        let jsd = 31
        if y <= y1 { return 64.7 + (y - 2005) * sd } //直线外推
        var v = deltatExt(y, jsd)        //二次曲线外推
        let dv = deltatExt(y1, jsd) - (64.7 + (y1 - 2005) * sd) //y1年的二次外推与直线外推的差
        if y < y1 + 100 { v -= dv * (y1 + 100 - y) / 100 }
        
        return v
    } else {
        var i = 0
        for (idx, _) in deltaTbl.enumerated() {
            i = idx
            if y < Double(deltaTbl[idx + 1].year) {
                break
            }
        }
        
        let t1 = (y - Double(deltaTbl[i].year)) / Double(deltaTbl[i + 1].year - deltaTbl[i].year) * 10.0
        let t2 = t1 * t1
        let t3 = t2 * t1
        
        return deltaTbl[i].d1 + deltaTbl[i].d2 * t1 + deltaTbl[i].d3 * t2 + deltaTbl[i].d4 * t3
    }
}

//二次曲线外推
private func deltatExt(_ y: Double,_ jsd: Int) -> Double {
    let dy = (y - 1820.0) / 100.0
    return -20.0 + Double(jsd) * dy * dy
}

private func GetDayTimeFromJulianDay(_ jd: Double,_ pDT: inout WZDAYTIME) {
    var cna, cnd: Int
    var cnf: Double

    let jdf = jd + 0.5
    cna = Int(jdf)
    cnf = jdf - Double(cna)
    if cna > 2299161 {
        cnd = Int((Double(cna) - 1867216.25) / 36524.25)
        cna = cna + 1 + cnd - Int(cnd / 4)
    }
    cna = cna + 1524
    var year = Int((Double(cna) - 122.1) / 365.25)
    cnd = cna - Int(365.25 * Double(year))
    var month = Int(Double(cnd) / 30.6001)
    let day = cnd - Int(Double(month) * 30.6001)
    year = year - 4716
    month = month - 1
    if month > 12 { month = month - 12 }
    if month <= 2 { year = year + 1 }
    if year < 1 { year = year - 1 }
    cnf = cnf * 24.0
    
    pDT.hour = Int(cnf)
    cnf = cnf - Double(pDT.hour)
    cnf = cnf * 60.0
    pDT.minute = Int(cnf)
    cnf = cnf - Double(pDT.minute)
    //cnf = cnf * 60.0
    pDT.second = cnf * 60.0
    pDT.year = year
    pDT.month = month
    pDT.day = day
}
