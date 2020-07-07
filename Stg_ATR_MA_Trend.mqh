//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                                     Copyright 2016-2020, FX31337 |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Strategy based on the Average True Range (ATR) and Moving Average (MA) indicators.
 */

// Includes.
#include <EA31337-classes/Strategy.mqh>

INPUT string __ATR_MA_Trend_Parameters__ = "-- ATR MA Trend strategy params --";  // >>> ATR <<<
INPUT int ATR_MA_Trend_Period = 13;                                      // Main Period
INPUT double ATR_MA_Trend_Shift_Pc = 0;                                  // Indicator Shift Percentage
INPUT int ATR_MA_Trend_ATR_Period = 15;                                  // ATR Period
INPUT double ATR_MA_Trend_ATR_Sensitivity = 1.5;                         // ATR Sensitivity
INPUT int ATR_MA_Trend_Indi_Shift = 0;                                   // Indicator Shift
INPUT int ATR_MA_Trend_Shift = 0;                                        // Shift (relative to the current bar, 0 - default)
INPUT int ATR_MA_Trend_SignalOpenMethod = 0;                             // Signal open method (0-31)
INPUT double ATR_MA_Trend_SignalOpenLevel = 0;                           // Signal open level
INPUT int ATR_MA_Trend_SignalOpenFilterMethod = 0;                       // Signal open filter method
INPUT int ATR_MA_Trend_SignalOpenBoostMethod = 0;                        // Signal open boost method
INPUT int ATR_MA_Trend_SignalCloseMethod = 0;                            // Signal close method
INPUT double ATR_MA_Trend_SignalCloseLevel = 0;                          // Signal close level
INPUT int ATR_MA_Trend_PriceLimitMethod = 0;                             // Price limit method
INPUT double ATR_MA_Trend_PriceLimitLevel = 2;                           // Price limit level
INPUT double ATR_MA_Trend_MaxSpread = 6.0;                               // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_ATR_MA_Trend_Params : StgParams {
  int ATR_MA_Trend_Period;
  double ATR_MA_Trend_Shift_Pc;
  int ATR_MA_Trend_ATR_Period;
  double ATR_MA_Trend_ATR_Sensitivity;
  int ATR_MA_Trend_Indi_Shift;
  int ATR_MA_Trend_Shift;
  int ATR_MA_Trend_SignalOpenMethod;
  double ATR_MA_Trend_SignalOpenLevel;
  int ATR_MA_Trend_SignalOpenFilterMethod;
  int ATR_MA_Trend_SignalOpenBoostMethod;
  int ATR_MA_Trend_SignalCloseMethod;
  double ATR_MA_Trend_SignalCloseLevel;
  int ATR_MA_Trend_PriceLimitMethod;
  double ATR_MA_Trend_PriceLimitLevel;
  double ATR_MA_Trend_MaxSpread;

  // Constructor: Set default param values.
  Stg_ATR_MA_Trend_Params()
      : ATR_MA_Trend_Period(::ATR_MA_Trend_Period),
        ATR_MA_Trend_Shift_Pc(::ATR_MA_Trend_Shift_Pc),
        ATR_MA_Trend_ATR_Period(::ATR_MA_Trend_ATR_Period),
        ATR_MA_Trend_ATR_Sensitivity(::ATR_MA_Trend_ATR_Sensitivity),
        ATR_MA_Trend_Indi_Shift(::ATR_MA_Trend_Indi_Shift),
        ATR_MA_Trend_Shift(::ATR_MA_Trend_Shift),
        ATR_MA_Trend_SignalOpenMethod(::ATR_MA_Trend_SignalOpenMethod),
        ATR_MA_Trend_SignalOpenLevel(::ATR_MA_Trend_SignalOpenLevel),
        ATR_MA_Trend_SignalOpenFilterMethod(::ATR_MA_Trend_SignalOpenFilterMethod),
        ATR_MA_Trend_SignalOpenBoostMethod(::ATR_MA_Trend_SignalOpenBoostMethod),
        ATR_MA_Trend_SignalCloseMethod(::ATR_MA_Trend_SignalCloseMethod),
        ATR_MA_Trend_SignalCloseLevel(::ATR_MA_Trend_SignalCloseLevel),
        ATR_MA_Trend_PriceLimitMethod(::ATR_MA_Trend_PriceLimitMethod),
        ATR_MA_Trend_PriceLimitLevel(::ATR_MA_Trend_PriceLimitLevel),
        ATR_MA_Trend_MaxSpread(::ATR_MA_Trend_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_ATR_MA_Trend : public Strategy {
 public:
  Stg_ATR_MA_Trend(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_ATR_MA_Trend *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_ATR_MA_Trend_Params _params;
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_ATR_MA_Trend_Params>(_params, _tf, stg_atr_ma_trend_m1, stg_atr_ma_trend_m5, stg_atr_ma_trend_m15, stg_atr_ma_trend_m30, stg_atr_ma_trend_h1,
                                    stg_atr_ma_trend_h4, stg_atr_ma_trend_h4);
    }
    // Initialize strategy parameters.
    ATR_MA_Trend_Params atr_ma_params(
      _params.ATR_MA_Trend_Period, _params.ATR_MA_Trend_Shift_Pc, _params.ATR_MA_Trend_ATR_Period,
      _params.ATR_MA_Trend_ATR_Sensitivity,
      _params.ATR_MA_Trend_Indi_Shift, _params.ATR_MA_Trend_Shift
      );
    atr_ma_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_ATR_MA_Trend(atr_ma_params), NULL, NULL);
    sparams.logger.Ptr().SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.ATR_MA_Trend_SignalOpenMethod, _params.ATR_MA_Trend_SignalOpenLevel, _params.ATR_MA_Trend_SignalOpenFilterMethod,
                       _params.ATR_MA_Trend_SignalOpenBoostMethod, _params.ATR_MA_Trend_SignalCloseMethod, _params.ATR_MA_Trend_SignalCloseLevel);
    sparams.SetPriceLimits(_params.ATR_MA_Trend_PriceLimitMethod, _params.ATR_MA_Trend_PriceLimitLevel);
    sparams.SetMaxSpread(_params.ATR_MA_Trend_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_ATR_MA_Trend(sparams, "ATR MA Trend");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    Chart *_chart = this.Chart();
    Indi_ATR_MA_Trend *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double level = _level * _chart.GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = _indi[CURR].value[ATR_MA_TREND_DOWN2] > 0;
        break;
      case ORDER_TYPE_SELL:
        _result = _indi[CURR].value[ATR_MA_TREND_UP2] > 0;
        break;
    }
    if (_result) {
      double _down1 = _indi[CURR].value[ATR_MA_TREND_DOWN];
      double _down2 = _indi[CURR].value[ATR_MA_TREND_DOWN2];
      double _up1 = _indi[CURR].value[ATR_MA_TREND_UP];
      double _up2 = _indi[CURR].value[ATR_MA_TREND_UP2];
      //DebugBreak();
    }
    return _result;
  }

  /**
   * Check strategy's opening signal additional filter.
   */
  bool SignalOpenFilter(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      // if (METHOD(_method, 0)) _result &= Trade().IsTrend(_cmd);
      // if (METHOD(_method, 1)) _result &= Trade().IsPivot(_cmd);
      // if (METHOD(_method, 2)) _result &= Trade().IsPeakHours(_cmd);
      // if (METHOD(_method, 3)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 4)) _result &= Trade().IsHedging(_cmd);
      // if (METHOD(_method, 5)) _result &= Trade().IsPeakBar(_cmd);
    }
    return _result;
  }

  /**
   * Gets strategy's lot size boost (when enabled).
   */
  double SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = 1.0;
    if (_method != 0) {
      // if (METHOD(_method, 0)) if (Trade().IsTrend(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 1)) if (Trade().IsPivot(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 2)) if (Trade().IsPeakHours(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 3)) if (Trade().IsRoundNumber(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 4)) if (Trade().IsHedging(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 5)) if (Trade().IsPeakBar(_cmd)) _result *= 1.1;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, double _level = 0.0) {
    Indi_ATR_MA_Trend *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        int _bar_count = (int) _level * (int) _indi.GetPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count)) : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
    }
    return _result;
  }
};
