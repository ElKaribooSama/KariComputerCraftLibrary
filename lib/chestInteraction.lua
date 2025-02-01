local ChestStruct = {
    connected = false,
    handle = nil,
    name = nil,
    inventory = {
        size = nil,
        items = nil
    }
}

function GetChest()
    local chest = peripheral.wrap("front")
    local cperiph = ChestStruct
    cperiph.handle = chest
    cperiph.connected = true
    cperiph.inventory.size = chest.size()
    cperiph.name = peripheral.getName(chest)
    return cperiph
end

function DebugItems(chest,callback)
    for slot, item in pairs(chest.handle.list()) do
        print(("%d x %s in slot %d"):format(item.count, item.name, slot))
    end
end

function CallbackOverAllItems(chest,callback)
    for slot, item in pairs(chest.handle.list()) do
        callback(slot,item)
    end
end

function EmptyInventory(chest,slotBlackList)
    for i = 1, 16 do
        local skip = false 
        for index, value in pairs(slotBlackList) do
            skip = i == value
        end
        if not skip then
            chest.pushItems(chest.name,i)
        end
    end
end

return { 
    EmptyInventory = EmptyInventory,
    CallbackOverAllItems = CallbackOverAllItems,
    DebugItems = DebugItems,
    GetChest = GetChest,
}
