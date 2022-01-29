//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                                     Copyright 2016-2022, FX31337 |
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
INPUT float ATR_MA_Trend_LotSize = 0;                // Lot size
INPUT int ATR_MA_Trend_SignalOpenMethod = 0;         // Signal open method
INPUT int ATR_MA_Trend_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int ATR_MA_Trend_SignalOpenFilterTime = 9;     // Signal open filter time
INPUT float ATR_MA_Trend_SignalOpenLevel = 0.0f;     // Signal open level
INPUT int ATR_MA_Trend_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int ATR_MA_Trend_SignalCloseMethod = 0;        // Signal close method
INPUT int ATR_MA_Trend_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT float ATR_MA_Trend_SignalCloseLevel = 0.0f;    // Signal close level
INPUT int ATR_MA_Trend_PriceStopMethod = 1;          // Price stop method (0-127)
INPUT float ATR_MA_Trend_PriceStopLevel = 2;         // Price stop level
INPUT int ATR_MA_Trend_TickFilterMethod = 28;        // Tick filter method (0-255)
INPUT float ATR_MA_Trend_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT short ATR_MA_Trend_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT int ATR_MA_Trend_OrderCloseLoss = 0;           // Order close loss
INPUT int ATR_MA_Trend_OrderCloseProfit = 0;         // Order close profit
INPUT int ATR_MA_Trend_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)

INPUT string __ATR_MA_Trend_Indi_ATR_MA_Trend_Params__ =
    "-- TMA True: ATR MA Trend indicator params --";       // >>> ATR MA Trend strategy: ATR MA Trend indicator <<<
INPUT int ATR_MA_Trend_Indi_ATR_MA_Trend_Period = 13;      // Main Period
INPUT double ATR_MA_Trend_Indi_ATR_MA_Trend_Shift_Pc = 0;  // Indicator Shift Percentage
INPUT int ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Period = 15;  // ATR Period
INPUT double ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Sensitivity = 1.5;  // ATR Sensitivity
INPUT int ATR_MA_Trend_Indi_ATR_MA_Trend_Indi_Shift = 0;            // Indicator Shift
INPUT int ATR_MA_Trend_Indi_ATR_MA_Trend_Shift = 0;                 // Shift (relative to the current bar, 0 - default)

// Defines struct with default user strategy values.
struct Stg_ATR_MA_Trend_Params_Defaults : StgParams {
  Stg_ATR_MA_Trend_Params_Defaults()
      : StgParams(::ATR_MA_Trend_SignalOpenMethod, ::ATR_MA_Trend_SignalOpenFilterMethod,
                  ::ATR_MA_Trend_SignalOpenLevel, ::ATR_MA_Trend_SignalOpenBoostMethod,
                  ::ATR_MA_Trend_SignalCloseMethod, ::ATR_MA_Trend_SignalCloseFilter, ::ATR_MA_Trend_SignalCloseLevel,
                  ::ATR_MA_Trend_PriceStopMethod, ::ATR_MA_Trend_PriceStopLevel, ::ATR_MA_Trend_TickFilterMethod,
                  ::ATR_MA_Trend_MaxSpread, ::ATR_MA_Trend_Shift) {
    Set(STRAT_PARAM_LS, ATR_MA_Trend_LotSize);
    Set(STRAT_PARAM_OCL, ATR_MA_Trend_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ATR_MA_Trend_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ATR_MA_Trend_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ATR_MA_Trend_SignalOpenFilterTime);
  }
} stg_atrmat_defaults;

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
//#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_ATR_MA_Trend : public Strategy {
 public:
  Stg_ATR_MA_Trend(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_ATR_MA_Trend *Init(ENUM_TIMEFRAMES _tf = NULL) {
    // Initialize strategy initial values.
    StgParams _stg_params(stg_atrmat_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_atr_ma_trend_m1, stg_atr_ma_trend_m5, stg_atr_ma_trend_m15,
                             stg_atr_ma_trend_m30, stg_atr_ma_trend_h1, stg_atr_ma_trend_h4, stg_atr_ma_trend_h4);
#endif
    // Initialize indicator.
    // Initialize strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_ATR_MA_Trend(_stg_params, _tparams, _cparams, "ATR MA Trend");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    Indi_ATR_MA_Trend_Params _indi_params(
        ::ATR_MA_Trend_Indi_ATR_MA_Trend_Period, ::ATR_MA_Trend_Indi_ATR_MA_Trend_Shift_Pc,
        ::ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Period, ::ATR_MA_Trend_Indi_ATR_MA_Trend_ATR_Sensitivity,
        ::ATR_MA_Trend_Indi_ATR_MA_Trend_Indi_Shift, ::ATR_MA_Trend_Indi_ATR_MA_Trend_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_ATR_MA_Trend(_indi_params));
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_ATR_MA_Trend *_indi = GetIndicator();
    Chart *_chart = (Chart *)_indi;
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double _down1 = _indi[_shift][(int)INDI_ATR_MA_TREND_DOWN];
    double _down2 = _indi[_shift][(int)INDI_ATR_MA_TREND_DOWN2];
    double _up1 = _indi[_shift][(int)INDI_ATR_MA_TREND_UP];
    double _up2 = _indi[_shift][(int)INDI_ATR_MA_TREND_UP2];
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _indi[_shift][(int)INDI_ATR_MA_TREND_DOWN2] > 0;
        break;
      case ORDER_TYPE_SELL:
        _result &= _indi[_shift][(int)INDI_ATR_MA_TREND_UP2] > 0;
        break;
    }
    return _result;
  }
};
