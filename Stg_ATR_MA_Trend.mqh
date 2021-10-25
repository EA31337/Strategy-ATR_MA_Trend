//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                                     Copyright 2016-2021, FX31337 |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements ATR MA Trend strategy
 * based on the Average True Range (ATR) and Moving Average (MA) indicators.
 */

// Includes.
#include "Indi_ATR_MA_Trend.mqh"

// User input params.
INPUT string __ATR_MA_Trend_Parameters__ = "-- TMA True strategy params --";  // >>> TMA True <<<
INPUT float ATR_MA_Trend_LotSize = 0;                                         // Lot size
INPUT int ATR_MA_Trend_SignalOpenMethod = 0;                                  // Signal open method
INPUT int ATR_MA_Trend_SignalOpenFilterMethod = 1;                            // Signal open filter method
INPUT float ATR_MA_Trend_SignalOpenLevel = 0.0f;                              // Signal open level
INPUT int ATR_MA_Trend_SignalOpenBoostMethod = 0;                             // Signal open boost method
INPUT int ATR_MA_Trend_SignalCloseMethod = 0;                                 // Signal close method
INPUT float ATR_MA_Trend_SignalCloseLevel = 0.0f;                             // Signal close level
INPUT int ATR_MA_Trend_PriceStopMethod = 0;                                   // Price stop method
INPUT float ATR_MA_Trend_PriceStopLevel = 2;                                  // Price stop level
INPUT int ATR_MA_Trend_TickFilterMethod = 1;                                  // Tick filter method (0-255)
INPUT float ATR_MA_Trend_MaxSpread = 4.0;                                     // Max spread to trade (in pips)
INPUT short ATR_MA_Trend_Shift = 0;           // Shift (relative to the current bar, 0 - default)
INPUT int ATR_MA_Trend_OrderCloseTime = -20;  // Order close time in mins (>0) or bars (<0)

INPUT string __ATR_MA_Trend_Indi_ATR_MA_Trend_Params__ =
    "-- TMA True: ATR MA Trend indicator params --";       // >>> ATR MA Trend strategy: ATR MA Trend indicator <<<
INPUT int ATR_MA_Trend_Indi_ATR_MA_Trend_Period = 13;      // Main Period
INPUT double ATR_MA_Trend_Indi_ATR_MA_Trend_Shift_Pc = 0;  // Indicator Shift Percentage
INPUT int ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Period = 15;  // ATR Period
INPUT double ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Sensitivity = 1.5;  // ATR Sensitivity
INPUT int ATR_MA_Trend_Indi_ATR_MA_Trend_Indi_Shift = 0;            // Indicator Shift
INPUT int ATR_MA_Trend_Indi_ATR_MA_Trend_Shift = 0;                 // Shift (relative to the current bar, 0 - default)

// Defines struct with default user indicator values.
struct Indi_ATR_MA_Trend_Params_Defaults : Indi_ATR_MA_Trend_Params {
  Indi_ATR_MA_Trend_Params_Defaults()
      : Indi_ATR_MA_Trend_Params(::ATR_MA_Trend_Indi_ATR_MA_Trend_Period, ::ATR_MA_Trend_Indi_ATR_MA_Trend_Shift_Pc,
                                 ::ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Period,
                                 ::ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Sensitivity,
                                 ::ATR_MA_Trend_Indi_ATR_MA_Trend_Indi_Shift, ::ATR_MA_Trend_Indi_ATR_MA_Trend_Shift) {}
} indi_atrmat_defaults;

// Defines struct with default user strategy values.
struct Stg_ATR_MA_Trend_Params_Defaults : StgParams {
  Stg_ATR_MA_Trend_Params_Defaults()
      : StgParams(::ATR_MA_Trend_SignalOpenMethod, ::ATR_MA_Trend_SignalOpenFilterMethod,
                  ::ATR_MA_Trend_SignalOpenLevel, ::ATR_MA_Trend_SignalOpenBoostMethod,
                  ::ATR_MA_Trend_SignalCloseMethod, ::ATR_MA_Trend_SignalCloseLevel, ::ATR_MA_Trend_PriceStopMethod,
                  ::ATR_MA_Trend_PriceStopLevel, ::ATR_MA_Trend_TickFilterMethod, ::ATR_MA_Trend_MaxSpread,
                  ::ATR_MA_Trend_Shift, ::ATR_MA_Trend_OrderCloseTime) {}
} stg_atrmat_defaults;

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_ATR_MA_Trend : public Strategy {
 public:
  Stg_ATR_MA_Trend(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_ATR_MA_Trend *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_ATR_MA_Trend_Params _indi_params(indi_atrmat_defaults, _tf);
    StgParams _stg_params(stg_atrmat_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_atr_ma_trend_m1, stg_atr_ma_trend_m5, stg_atr_ma_trend_m15,
                             stg_atr_ma_trend_m30, stg_atr_ma_trend_h1, stg_atr_ma_trend_h4, stg_atr_ma_trend_h4);
#endif
    // Initialize indicator.
    _stg_params.SetIndicator(new Indi_ATR_MA_Trend(_indi_params));
    // Initialize strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_ATR_MA_Trend(_stg_params, _tparams, _cparams, "ATR MA Trend");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indicator *_indi = GetIndicator();
    Chart *_chart = trade.GetChart();
    bool _is_valid = _indi[_shift].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double level = _level * _chart.GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = _indi[_shift][(int)INDI_ATR_MA_TREND_DOWN2] > 0;
        break;
      case ORDER_TYPE_SELL:
        _result = _indi[_shift][(int)INDI_ATR_MA_TREND_UP2] > 0;
        break;
    }
    if (_result) {
      double _down1 = _indi[_shift][(int)INDI_ATR_MA_TREND_DOWN];
      double _down2 = _indi[_shift][(int)INDI_ATR_MA_TREND_DOWN2];
      double _up1 = _indi[_shift][(int)INDI_ATR_MA_TREND_UP];
      double _up2 = _indi[_shift][(int)INDI_ATR_MA_TREND_UP2];
      // DebugBreak();
    }
    return _result;
  }

  /**
   * Gets price stop value for profit take or stop loss.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f) {
    Indi_ATR_MA_Trend *_indi = GetIndicator();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        int _bar_count = (int)_level * (int)_indi.GetPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest<double>(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest<double>(_bar_count));
        break;
      }
    }
    return (float)_result;
  }
};
