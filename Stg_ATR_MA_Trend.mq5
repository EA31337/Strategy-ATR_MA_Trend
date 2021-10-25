//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements ATR MA Trend strategy.
 */

// Includes conditional compilation directives.
#include "config/define.h"

// Includes EA31337 framework.
#include <EA31337-classes/EA.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Strategy.mqh>

// Inputs.
input int Active_Tfs = 15;                // Activated timeframes (1-255) [M1=1,M5=2,M15=4,M30=8,H1=16,H4=32,H8=64...]
input ENUM_LOG_LEVEL Log_Level = V_INFO;  // Log level.
input bool Info_On_Chart = true;          // Display info on chart.

// Includes main strategy class.
#include "Stg_ATR_MA_Trend.mqh"

// Defines.
#define ea_name "Strategy ATR MA Trend"
#define ea_version "1.007"
#define ea_desc "Strategy based on EA31337 framework."
#define ea_link "https://github.com/EA31337/Strategy-Stg_ATR_MA_Trend"

// Properties.
#property version ea_version
#ifdef __MQL4__
#property description ea_name
#property description ea_desc
#endif
#property link ea_link
#ifdef __resource__
#ifdef __MQL5__
#property tester_indicator "::Indicators\\ATR_MA_Trend.ex5"
#property tester_library "::Indicators\\ATR_MA_Trend.ex5"
#endif
#endif

// Load external resources.
#ifdef __resource__
#ifdef __MQL5__
#resource "Indicators\\ATR_MA_Trend.ex5"
#endif
#endif

// Class variables.
EA *ea;

/* EA event handler functions */

/**
 * Implements "Init" event handler function.
 *
 * Invoked once on EA startup.
 */
int OnInit() {
  bool _result = true;
  EAParams ea_params(__FILE__, Log_Level);
  ea = new EA(ea_params);
  _result &= ea.StrategyAdd<Stg_ATR_MA_Trend>(Active_Tfs);
  return (_result ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements "Tick" event handler function (EA only).
 *
 * Invoked when a new tick for a symbol is received, to the chart of which the
 * Expert Advisor is attached.
 */
void OnTick() {
  ea.ProcessTick();
  if (!ea.GetTerminal().IsOptimization()) {
    ea.UpdateInfoOnChart();
  }
}

/**
 * Implements "Deinit" event handler function.
 *
 * Invoked once on EA exit.
 */
void OnDeinit(const int reason) { Object::Delete(ea); }
