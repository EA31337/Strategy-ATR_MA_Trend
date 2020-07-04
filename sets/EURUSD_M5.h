//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ATR_MA_Trend_EURUSD_M5_Params : Stg_ATR_MA_Trend_Params {
  Stg_ATR_MA_Trend_EURUSD_M5_Params() {
    ATR_MA_Trend_Period = 13;
    ATR_MA_Trend_Shift_Pc = 0;
    ATR_MA_Trend_ATR_Period = 15;
    ATR_MA_Trend_ATR_Sensitivity = 1.5;
    ATR_MA_Trend_Indi_Shift = 0;
    ATR_MA_Trend_Shift = 0;
    ATR_MA_Trend_SignalOpenMethod = 0;
    ATR_MA_Trend_SignalOpenLevel = 0;
    ATR_MA_Trend_SignalCloseMethod = 0;
    ATR_MA_Trend_SignalCloseLevel = 0;
    ATR_MA_Trend_PriceLimitMethod = 0;
    ATR_MA_Trend_PriceLimitLevel = 1;
    ATR_MA_Trend_MaxSpread = 3;
  }
} stg_atr_ma_trend_m5;
