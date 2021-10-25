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
#ifdef __resource__
    custom_indi_name = "::Indicators\\ATR_MA_Trend";
#else
    custom_indi_name = "ATR_MA_Trend";
#endif
    itype = INDI_ATR;
    max_modes = FINAL_INDI_ATR_MA_TREND_ENTRY;
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
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         params.custom_indi_name, Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), GetPeriod(), GetShiftPercent(),
                         GetATRPeriod(), GetATRSensitivity(), GetIndiShift(), _mode, _shift);
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
    IndicatorDataEntry _entry(FINAL_INDI_ATR_MA_TREND_ENTRY);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < FINAL_INDI_ATR_MA_TREND_ENTRY; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(DBL_MAX));
      if (_entry.IsValid()) idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

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
