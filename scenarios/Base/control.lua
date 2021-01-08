
if __DebugAdapter or __Profiler then
  (__DebugAdapter or __Profiler).levelPath("JanSharpDevEnv", "scenarios/Base/")
end

if not script.active_mods["JanSharpDevEnv"] then
  error("JanSharpDevEnv is required to load this scenario.")
end

require("__JanSharpDevEnv__.scenario-scripts.Base.control")
