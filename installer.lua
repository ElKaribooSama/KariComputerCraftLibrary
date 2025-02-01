-- LINK TO THE RAW INSTALL.LUA --

local link = ""

function GetFileName(file)
    local file_name = file:match("[^/]*.lua$")
    return file_name:sub(0, #file_name - 4)
end

if link ~= "" then
    local raw = http.get(link)
    local filecontent = raw.readAll()
    
    local infos = loadstring(filecontent)
    
    if infos == nil then
        os.exit()
    end
    if infos.lib == nil or infos.src == nil then
        os.exit()
    end

    for index, value in ipairs(infos.lib) do
        local raw = http.get(value)
        local filecontent = raw.readAll()
    
        local file = fs.open("lib/" .. GetFileName(value), "w")
        file.write(filecontent)
        file.close()
    end
    
    for index, value in ipairs(infos.src) do
        local raw = http.get(value)
        local filecontent = raw.readAll()
    
        local file = fs.open("src/" .. GetFileName(value), "w")
        file.write(filecontent)
        file.close()
    end
end