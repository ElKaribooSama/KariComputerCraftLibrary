-- LINK TO THE RAW INSTALL.LUA --

local args = {...}

-- LINK TO THE RAW INSTALL.LUA --

local link = args[0]

function GetFileName(file)
    local file_name = file:match("[^/]*.lua$")
    return file_name:sub(0, #file_name - 4)
end

if link ~= "" then
    print("Starting install...")

    do
        local raw = http.get(link)
        local filecontent = raw.readAll()
        
        local file = fs.open("temp/" .. GetFileName(link), "w")
        file.write(filecontent)
        file.close()
    end

    local infos = require("temp/" .. GetFileName(link))

    for index, value in ipairs(infos.lib) do
        print("Downloading library : " .. GetFileName(value))

        local raw = http.get(value)
        local filecontent = raw.readAll()
    
        local file = fs.open("lib/" .. GetFileName(value), "w")
        file.write(filecontent)
        file.close()
    end
    
    for index, value in ipairs(infos.src) do
        print("Downloading source : " .. GetFileName(value))

        local raw = http.get(value)
        local filecontent = raw.readAll()
    
        local file = fs.open("src/" .. GetFileName(value), "w")
        file.write(filecontent)
        file.close()
    end
    
    os.remove("temp/" .. GetFileName(link))
else 
    print("Link to install.lua not found.")
    print("run the installer with the raw github link as an argument.")
end
