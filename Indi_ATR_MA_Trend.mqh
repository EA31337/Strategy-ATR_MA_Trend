/**
 * @file
 * Implements indicator class.
 */

// Defines
#define INDI_ATR_MA_TREND_PATH "indicators-other\\Misc"

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
    custom_indi_name = "::" + INDI_ATR_MA_TREND_PATH + "\\ATR_MA_Trend";
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
class Indi_ATR_MA_Trend : public Indicator<Indi_ATR_MA_Trend_Params> {
 public:
  /**
   * Class constructor.
   */
  Indi_ATR_MA_Trend(Indi_ATR_MA_Trend_Params &_p, IndicatorBase *_indi_src = NULL)
      : Indicator<Indi_ATR_MA_Trend_Params>(_p, _indi_src) {}
  Indi_ATR_MA_Trend(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_ATR, _tf){};

  /**
   * Returns the indicator's value.
   */
  IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         iparams.custom_indi_name, Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), GetPeriod(), GetShiftPercent(),
                         GetATRPeriod(), GetATRSensitivity(), GetIndiShift(), _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        // @todo: Add custom calculation.
        break;
    }
    return _value;
  }

  /* Getters */

  /**
   * Gets period value.
   */
  int GetPeriod() { return iparams.period; }

  /**
   * Gets indicator shift in percent.
   */
  double GetShiftPercent() { return iparams.shift_percent; }

  /**
   * Gets ATR indicator period.
   */
  int GetATRPeriod() { return iparams.atr_period; }

  /**
   * Gets ATR indicator sensitivity.
   */
  double GetATRSensitivity() { return iparams.atr_sensitivity; }

  /**
   * Gets indicator shift.
   */
  int GetIndiShift() { return iparams.indi_shift; }

  /**
   * Gets buffer shift.
   */
  int GetShift() { return iparams.shift; }

  /* Setters */

  /**
   * Sets period value.
   */
  void SetPeriod(int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Sets applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }

  /**
   * Sets indicator shift in percent.
   */
  void GetShiftPercent(double _shift_percent) {
    istate.is_changed = true;
    iparams.shift_percent = _shift_percent;
  }

  /**
   * Sets ATR indicator period.
   */
  void GetATRPeriod(int _atr_period) {
    istate.is_changed = true;
    iparams.atr_period = _atr_period;
  }

  /**
   * Sets ATR indicator sensitivity.
   */
  void GetATRSensitivity(double _atr_sensitivity) {
    istate.is_changed = true;
    iparams.atr_sensitivity = _atr_sensitivity;
  }

  /**
   * Gets indicator shift.
   */
  void GetIndiShift(int _indi_shift) {
    istate.is_changed = true;
    iparams.indi_shift = _indi_shift;
  }

  /**
   * Gets buffer shift.
   */
  void GetShift(int _shift) {
    istate.is_changed = true;
    iparams.shift = _shift;
  }
};
