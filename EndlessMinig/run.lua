--[[ Download and run this.
	Downloads main.lua and all dependencies
	and executes main.lua with the arguments
	it was executed with.
]]
local repoURL = 'https://github.com/RC-14/turtleScrips'
local filesPath = '/EndlessMining'
local librariesPath = '/libraries'

--[[
	All files in the project folder (eg. "/EndlessMining")
	except "run.lua".
]] local files = {
    'main.lua'
}

--[[
	All files in the libraries folder
	that are required by the program.
]] local libraries = {}

local function download(url, path)
    if url == nil or path == nil then
        return false, 'param', "paraneters can't be empty" -- function was called with an empty parameter
    end

    local response = http.get(url)
    local status = response.getResponseCode()

    if status ~= 0 and (status < 200 or status >= 400) then
        return false, 'http', status -- request was not successfull
    end

    local file = fs.open(path, 'w')

    if file == nil then
        return false, 'file', 'read only' -- can't write to that location
    end

    local contents = response.readAll()

    file.write(contents)
    file.close()

    file = fs.open(path, 'r')
    if file == nil then
        return false, 'file', "can't read" -- can't read from that location
    end

    if file.readAll() ~= contents then
        return false, 'file', 'faulty write' -- contents of the file aren't what they should be
    end

    file.close()

    return true -- downloaded the file successfully
end

local installDir = fs.getDir(shell.getRunningProgram())
local librariesDir = librariesPath
local tmpDir = '/temp'
local error = false

fs.makeDir(tmpDir .. librariesPath)

for i, filename in ipairs(libraries) do
    local success, error, reason =
        download(repoURL .. librariesPath .. '/' .. filename, tmpDir .. librariesPath .. '/' .. filename)

    if not success then
        print('ERROR: ' .. error)
        print(reason)
        print('File:' .. filename)
        print('Path: ' .. tmpDir .. librariesPath)
        print('URL: ' .. repoURL .. librariesPath .. filename)

        error = true
    end
end

if not error then
    fs.makeDir(tmpDir .. filesPath)

    for i, filename in ipairs(files) do
        local success, error, reason =
            download(repoURL .. filesPath .. '/' .. filename, tmpDir .. filesPath .. '/' .. filename)

        if not success then
            print('ERROR: ' .. error)
            print(reason)
            print('File:' .. filename)
            print('Path: ' .. tmpDir .. filesPath)
            print('URL: ' .. repoURL .. filesPath .. '/' .. filename)

            error = true
        end
    end
end

if not error then
    fs.makeDir(librariesDir)

    for i, filename in ipairs(libraries) do
        fs.delete(librariesDir .. '/' .. filename)
        fs.move(tmpDir .. librariesPath .. '/' .. filename, librariesDir .. '/' .. filename)
    end

    for i, filename in ipairs(files) do
        fs.delete(installDir .. '/' .. filename)
        fs.move(tmpDir .. filesPath .. '/' .. filename, installDir .. '/' .. filename)
    end
end

fs.delete(tmpDir .. librariesPath)
fs.delete(tmpDir .. filesPath)
