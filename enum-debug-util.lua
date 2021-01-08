
---replaces numbers with tables with metamethods to display enum names instead of raw numbers
---puts the enums_table in global to make it accessible in the variables view and debug console
---@param enums_table table<string, table<string, number>> @ the actual enums table to hook
---@param enums_table_name string @ the name of the enums table used for displaying and the global variable name
local function hook_enums(enums_table, enums_table_name)
  __DebugAdapter.defineGlobal(enums_table_name)
  _ENV[enums_table_name] = enums_table -- for the variables view and debug console

  local next = next
  local setmetatable = setmetatable
  local type = type
  local script = script

  local lookups = {}

  -- metatable for all enum values to nicely display their actual name in debug views
  local meta = {
    __debugline = function(enum_value)
      local enum_name = enum_value.__enum_name
      return enums_table_name .. "." .. enum_name .. "." .. lookups[enum_name][enum_value.__value]
    end,
    __debugchildren = false,
    __debugtype = "number",
  }

  -- replace all enum values in the enums_table with tables
  -- which are given the metatable above
  for enum_name, values in next, enums_table do
    local lookup = {}
    for k, v in next, values do
      lookup[v] = k
    end
    lookups[enum_name] = lookup
    for value_name, value in next, values do
      local new_value = {
        __is_custom_enum = true,
        __enum_name = enum_name,
        __value = value,
      }
      values[value_name] = setmetatable(new_value, meta)
    end
  end

  -- hook functions to set metatables in the factorio global table
  local hook_enums_in_table_recursive
  local function try_hook_value(value, processed_tables)
    if processed_tables[value] then return end
    if type(value) == "table" then
      processed_tables[value] = true
      if value.__is_custom_enum then
        setmetatable(value, meta)
      else
        hook_enums_in_table_recursive(value, processed_tables)
      end
    end
  end
  function hook_enums_in_table_recursive(t, processed_tables)
    for k, v in next, t do
      try_hook_value(k, processed_tables)
      try_hook_value(v, processed_tables)
    end
  end
  local function hook_enums_in_global()
    hook_enums_in_table_recursive(global, {})
  end

  -- replace on_load with a custom one in order for
  -- the previous hook functions to actually get run
  local on_load = script.on_load
  function script.on_load(func)
    if func then
      on_load(function()
        hook_enums_in_global()
        return func()
      end)
    else
      on_load(hook_enums_in_global)
    end
  end
  script.on_load(nil)
  -- if script.on_load was already called before this then RIP that handler
end

return {
  hook_enums = hook_enums,
}
