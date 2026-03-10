# luluworlds-params

Teeworlds and ddnet console parameter parser. Parses these kind of param texts.

https://github.com/ddnet/ddnet/blob/4ae9ce874b8961ee1be4d54359997474a80db648/src/game/server/gamecontext.cpp#L3895-L3902

- `s[tuning] ?f[value]`
- `s[name] r[command]`

## installation

```
luarocks install luluworlds-params
```

## example usage

```lua
local console = require("luluworlds.params")

local err, params = console.parse_params("i[client id]?s[name]")
if err == nil then
	print(params[1].name) -- => client id
	print(params[1].type) -- => i

	print(params[2].optional) -- => true
end
```
