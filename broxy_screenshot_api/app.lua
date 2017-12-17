local cmd = require('cmd')

local filename = random_string(16)

local conf = read_yaml('conf.yaml')

if conf.api_key then
    if app.request:args():get('api_key') ~= conf.api_key then
        app.response:set_status(401)
        app.response:write('bad APi key')
        return
    end
end

local err = cmd.run('node ' .. conf.script_path .. ' '.. app.request:args():get('url') ..' ' .. filename .. '.png')

if err ~= '' then
    app.response:set_status(500)
    app.response:write(err)
    return
end

data = read_file(filename .. '.png')
delete_file(filename .. '.png')

app.response:headers():set('Content-Type', 'image/png')
app.response:write(data)
