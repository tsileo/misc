local docstore = require('docstore')
local router = require('router').new()

local col_name = 'gps_locations'

router:post('/', function(params)
  local col = docstore.col(col_name)
  -- Are You Tracking Me? will send POST requests that looks like:
  -- {"device_id": <Android device ID>, "locations":[{"lat": 1.0, "lng": 1.0, , "ts": <timestamp UTC in ms>}]}
  local payload = app.request:body():json()
  for _, loc in ipairs(payload.locations) do
    loc.device_id = payload.device_id
    col:insert(loc)
  end
end)

router:run()
