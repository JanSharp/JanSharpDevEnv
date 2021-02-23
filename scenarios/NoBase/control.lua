

if not script.active_mods["JanSharpDevEnv"] then
  error("JanSharpDevEnv is required to load this scenario.")
end

require("__JanSharpDevEnv__.scenario-scripts.NoBase.control")
