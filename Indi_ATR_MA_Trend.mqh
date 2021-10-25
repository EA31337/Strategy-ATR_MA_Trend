/**
 * @file
 * Implements indicator class.
 */

// Includes.
#include <EA31337-classes/Indicator.mqh>

// Enums.
// Indicator mode identifiers used in ATR MA Trend indicator.
enum ENUM_INDI_ATR_MA_TREND_MODE {
  INDI_ATR_MA_TREND_UP = 0,
  INDI_ATR_MA_TREND_DOWN,
  INDI_ATR_MA_TREND_UP2,
  INDI_ATR_MA_TREND_DOWN2,
  FINAL_INDI_ATR_MA_TREND_ENTRY,
};

// Structs.
struct Indi_ATR_MA_Trend_Params : IndicatorParams {
  int period;
  double shift_percent;
  int atr_period;
  double atr_sensitivity;
  int indi_shift;
  ENUM_APPLIED_PRICE applied_price;

  // Struct constructor.
  void Indi_ATR_MA_Trend_Params(int _period = 13, double _shift_percent = 0, int _atr_period = 15,
                                double _atr_sensitivity = 1.5, int _indi_shift = 0, int _shift = 0)
      : period(_period),
        shift_percent(_shift_percent),
        atr_period(_atr_period),
        atr_sensitivity(_atr_sensitivity),
        indi_shift(_indi_shift) {
    itype = INDI_ATR;
    max_modes = FINAL_INDI_ATR_MA_TREND_ENTRY;
    custom_indi_name = "Indi_ATR_MA_Trend";
    SetDataSourceType(IDATA_ICUSTOM);
    SetDataValueType(TYPE_DOUBLE);
  };
  void Indi_ATR_MA_Trend_Params(Indi_ATR_MA_Trend_Params &_params, ENUM_TIMEFRAMES _tf) {
    this = _params;
    _params.tf = _tf;
  }
};

/**
 * Indicator class.
 */
class Indi_ATR_MA_Trend : public Indicator {
 protected:
  Indi_ATR_MA_Trend_Params params;

 public:
  /**
   * Class constructor.
   */
  Indi_ATR_MA_Trend(Indi_ATR_MA_Trend_Params &_p)
      : params(_p.period, _p.shift_percent, _p.atr_period, _p.atr_sensitivity, _p.indi_shift, _p.shift),
        Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_ATR_MA_Trend(Indi_ATR_MA_Trend_Params &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.period, _p.shift_percent, _p.atr_period, _p.atr_sensitivity, _p.indi_shift, _p.shift),
        Indicator(INDI_ATR, _tf) {
    params = _p;
  }

  /**
   * Returns value for the indicator.
   */
  static double GetValue(string _symbol, ENUM_TIMEFRAMES _tf, int _period, double _shift_percent, int _atr_period,
                         double _atr_sensitivity, int _indi_shift = 0, int _mode = 0, int _shift = 0,
                         Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, "Indi_ATR_MA_Trend", _period, _shift_percent, _atr_period, _atr_sensitivity,
                     _indi_shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      // @fixme: Load indicator from the current folder?
      if ((_handle = ::iCustom(_symbol, _tf, "Indi_ATR_MA_Trend", _period, _shift_percent, _atr_period,
                               _atr_sensitivity, _indi_shift)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (GetLastError() > 0) {
      return EMPTY_VALUE;
    } else if (_bars_calc <= 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_ATR_MA_Trend::GetValue(Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                                             GetPeriod(), GetShiftPercent(), GetATRPeriod(), GetATRSensitivity(),
                                             GetIndiShift(), _mode, _shift, GetPointer(this));
        break;
      case IDATA_INDICATOR:
        // @todo: Add custom calculation.
        break;
    }
    istate.is_ready = _value != EMPTY_VALUE && _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < FINAL_INDI_ATR_MA_TREND_ENTRY; _mode++) {
        _entry.values[_mode] = Indi_ATR_MA_Trend::GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(DBL_MAX));
      if (_entry.IsValid()) idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  /*
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).values[_mode];
    return _param;
  }
  */

  /* Getters */

  /**
   * Gets period value.
   */
  int GetPeriod() { return params.period; }

  /**
   * Gets indicator shift in percent.
   */
  double GetShiftPercent() { return params.shift_percent; }

  /**
   * Gets ATR indicator period.
   */
  int GetATRPeriod() { return params.atr_period; }

  /**
   * Gets ATR indicator sensitivity.
   */
  double GetATRSensitivity() { return params.atr_sensitivity; }

  /**
   * Gets indicator shift.
   */
  int GetIndiShift() { return params.indi_shift; }

  /**
   * Gets buffer shift.
   */
  int GetShift() { return params.shift; }

  /* Setters */

  /**
   * Sets period value.
   */
  void SetPeriod(int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Sets applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }

  /**
   * Sets indicator shift in percent.
   */
  void GetShiftPercent(double _shift_percent) {
    istate.is_changed = true;
    params.shift_percent = _shift_percent;
  }

  /**
   * Sets ATR indicator period.
   */
  void GetATRPeriod(int _atr_period) {
    istate.is_changed = true;
    params.atr_period = _atr_period;
  }

  /**
   * Sets ATR indicator sensitivity.
   */
  void GetATRSensitivity(double _atr_sensitivity) {
    istate.is_changed = true;
    params.atr_sensitivity = _atr_sensitivity;
  }

  /**
   * Gets indicator shift.
   */
  void GetIndiShift(int _indi_shift) {
    istate.is_changed = true;
    params.indi_shift = _indi_shift;
  }

  /**
   * Gets buffer shift.
   */
  void GetShift(int _shift) {
    istate.is_changed = true;
    params.shift = _shift;
  }
};
