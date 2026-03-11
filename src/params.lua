---@class ParsedParam
---@field name string|false the name of the param
---@field type string the type of the param, possible values "i", "r", "s"
---@field optional boolean

---Parses a teeworlds or ddnet rcon or chat command parameter string
---into a lua table representing the individual parameters.
---It does NOT parse user given arguments. Only the expected parameter text.
---
---Usage:
---```lua
---local err, params = console.parse_params("i[client id]?s[name]")
---if err == nil then
---	print(params[1].name) -- => client id
---	print(params[1].type) -- => i
---
---	print(params[2].optional) -- => true
---end
---```
---
---@param params string # teeworlds console params text like "i[client_id]"
---@return string|nil error either the error message as string or nil on success
---@return ParsedParam[] params error msg or nil followed by list of parsed params
local function parse_params(params)
   ---@type ParsedParam[]
   local pparams = {}

   ---@type string|false
   local current_name = false

   ---@type string|false
   local current_type = false

   ---@type boolean
   local current_optional = false

   ---@type boolean
   local expect_optional = false

   for i = 1, #params do
      local c = params:sub(i,i)
      local next_c = params:sub(i+1,i+1)
      local last = next_c == ""
      if current_name then
         if c == "]" then
            if expect_optional == true and current_optional == false then
               return "optional can not be followed by non optional", {}
            end
            table.insert(pparams, {
               name = current_name,
               type = current_type,
               optional = current_optional
            })
            current_name = false
            current_type = false
            current_optional = false
         elseif c == "[" then
            return "unexpected [", {}
         else
            current_name = current_name .. c
         end
      elseif c == "[" then
         current_name = ""
      elseif c == "?" then
         current_optional = true
         expect_optional = true
      elseif (c == "i") or (c == "s") or (c == "r") then
         if current_type then
            if expect_optional == true and current_optional == false then
               return "optional can not be followed by non optional", {}
            end
            table.insert(pparams, {
               name = current_name,
               type = current_type,
               optional = current_optional
            })
            current_name = false
            current_type = false
            current_optional = false
         end
         -- only flush prev type and queue next
         -- unless its end of string then we flush both
         current_type = c
         if last or next_c == "?" then
            if expect_optional == true and current_optional == false then
               return "optional can not be followed by non optional", {}
            end
            table.insert(pparams, {
               name = current_name,
               type = current_type,
               optional = current_optional
            })
            current_name = false
            current_type = false
            current_optional = false
         end
      elseif c == " " then
         -- skip spaces
      else
         return "unsupported parameter type '" .. c .. "'", {}
      end
   end

   if current_optional or current_name or current_type then
      return "unexpected end of parameters", {}
   end
   return nil, pparams
end

return {
	parse_params = parse_params
}
