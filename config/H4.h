//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2022, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ATR_MA_Trend_EURUSD_H4_Params : StgParams {
  Stg_ATR_MA_Trend_EURUSD_H4_Params() {
    ATR_MA_Trend_Indi_ATR_MA_Trend_Period = 13;
    ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Period = 15;
    ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Sensitivity = 1.5;
    ATR_MA_Trend_Indi_ATR_MA_Trend_Indi_Shift = 0;
  }
} stg_atr_ma_trend_h4;
