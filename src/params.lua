---@class ParsedParam
---@field name string|false the name of the param
---@field type string the type of the param, possible values "i", "r", "s"
---@field optional boolean

---Parses a teeworlds or ddnet rcon or chat command parameter string
---into a lua table representing the individual parameters.
---It does NOT parse user given arguments. Only the expected parameter text.
---
---@param params string # teeworlds console params text like "i[client_id]"
---@return string|nil, ParsedParam[] # error msg or nil followed by list of parsed params
local function parse_params(params)
   ---@type ParsedParam[]
   local pparams = {}

   ---@type string|false
   local current_name = false

   ---@type string|false
   local current_type = false

   ---@type boolean
   local current_optional = false

   -- TODO: error if optional is followed by non optional

   for i = 1, #params do
      local c = params:sub(i,i)
      local last = params:sub(i+1,i+1) == ""
      if current_name then
         if c == "]" then
            table.insert(pparams, {
               name = current_name,
               type = current_type,
               optional = current_optional
            })
            current_name = false
            current_type = false
            current_optional = false
         else
            current_name = current_name .. c
         end
      elseif c == "[" then
         current_name = ""
      elseif c == "?" then
         current_optional = true
      elseif (c == "i") or (c == "s") then
         if current_type then
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
         if last then
            table.insert(pparams, {
               name = current_name,
               type = current_type,
               optional = current_optional
            })
            current_name = false
            current_type = false
            current_optional = false
         end
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
