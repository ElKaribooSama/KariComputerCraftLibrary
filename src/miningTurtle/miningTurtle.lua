-- Libraries

local movement = require("../lib/movement")
local chestHandler = require("../lib/chestInteraction")
local oreNode = require("../lib/oreNode")

-- Setup

local miningY = -53
local tunnelIsWalkable = false
local chestDirection = movement.direction.north
local miningDirection = movement.direction.east
local homePosition = {
    x = 0,
    y = 0,
    z = 0,
    w = 0
}

-- variables

local INVENTORY_SIZE = 16
local FUEL_SLOT = 1
local MINIMUM_FUEL = 50
local position = {
    x = 0,
    y = 0,
    z = 0,
    w = 0
}

function IsInventoryFull()
    for i = 1, INVENTORY_SIZE do
        if turtle.getItemDetail(i) == nil then
            return false
        end
    end
end

function TryRefuel() 
    if turtle.getFuelLevel() < MINIMUM_FUEL then
        turtle.select(FUEL_SLOT)
        turtle.refuel()
    end
end

function GoToMiningPos()
    local destination = {
        x = position.x,
        y = miningY - homePosition.y,
        z = position.z,
        w = position.w
    }

    position = movement.GoToPos(position,destination)
end

function GoBackHome()
    local destination = {
        x = position.x,
        y = position.y,
        z = position.z,
        w = position.w
    }

    destination.z = 0
    position = movement.GoToPos(position,destination)
    
    destination.x = 0
    position = movement.GoToPos(position,destination)

    destination.y = 0
    position = movement.GoToPos(position,destination)
end

function End()
    GoBackHome()
end

function GetFuel()
    local destination = {
        x = 0,
        y = 1,
        z = 0,
        w = chestDirection
    }
    movement.GoToPos(position,destination)

    turtle.select(FUEL_SLOT)
    local count = turtle.getItemCount()
    turtle.suck(64 - count)
    
    destination.y = 0
    movement.GoToPos(position,destination)
end

function EmptyInventoryToChest()
    local destination = {
        x = 0,
        y = 0,
        z = 0,
        w = chestDirection
    }
    movement.GoToPos(position,destination)

    local oreChest = chestHandler.GetChest()
    chestHandler.EmptyInventory(oreChest,FUEL_SLOT)
end

function WalkBackOneThroughNode(node)
    for i = #node.movementList, 1, -1 do
        local value = node.movementList[i]
        local dx = -value.x
        local dy = -value.y
        local dz = -value.z
        if dx ~= 0 then
            if dx == -1 then
                movement.LookToward(position,movement.direction.west)
            else
                movement.LookToward(position,movement.direction.east)
            end
        end

        if dy ~= 0 then
            movement.GoToPos(position,{x = position.x, y = position.y + dy, z = position.z, w = position.w})
        end

        if dz ~= 0 then
            if dz == -1 then
                movement.LookToward(position,movement.direction.north)
            else
                movement.LookToward(position,movement.direction.south)
            end

        end
        
        movement.GoToPos(position,{x = position.x + dx, y = position.y, z = position.z + dz, w = position.w})
        table.remove(node.movementList,nil)
    end
end

function MineOreNode(type)
    print("start mining node of " .. type)

    local node = oreNode.NewNode(type)

    local basePosition = position

    local direction = oreNode.FindBlockAround(position,node)

    if direction < 4 then
        movement.LookToward(position,direction)
    end
    local loop = true
    while loop do
        print("Not back to the tunnel. Continuing")
        loop = position.x ~= basePosition.x
        loop = position.y ~= basePosition.y and loop
        loop = position.z ~= basePosition.z and loop
        
        while direction ~= oreNode.direction.none do
            print("Node Extended")

            TryRefuel()
            if direction == oreNode.direction.down then
                oreNode.AddMove(node,{x = 0, y = -1, z = 0})
                movement.GoToPos(position,{x = position.x, y = position.y - 1, z = position.z, w = position.w})
            end

            if direction == oreNode.direction.up then
                oreNode.AddMove(node,{x = 0, y = 1, z = 0})
                movement.GoToPos(position,{x = position.x, y = position.y + 1, z = position.z, w = position.w})
            end

            if direction < 4 then
                local dx = (direction == 1) and 1 or (direction == 3) and -1 or 0
                local dz = (direction == 2) and 1 or (direction == 0) and -1 or 0
                
                movement.LookToward(position,direction)

                oreNode.AddMove(node,{x = dx, y = 0, z = dz})
                movement.GoToPos(position,{x = position.x + dx, y = position.y, z = position.x + dz, w = position.w})
            end
            
            
            direction = oreNode.FindBlockAround(position,node)
        end

        WalkBackOneThroughNode(node)
        direction = oreNode.FindBlockAround(position,node)
    end

    movement.LookToward(position,basePosition.w)
end

function ShouldMine(data)
    local miningBlackList = {
        "minecraft:stone",
        "minecraft:deepslate",
        "minecraft:granite",
        "minecraft:diorite",
        "minecraft:tuff",
        "twigs:rhyolite",
    }

    for index, value in pairs(miningBlackList) do
        if data.name == value then
            return false
        end
    end

    print("Node Detected")
    return true
end

function StartMiningTunnel()

    local rootPosition = {
        x = position.x,
        y = position.y,
        z = position.z,
        w = position.w
    }

    local destination = {
        x = position.x,
        y = position.y,
        z = position.z,
        w = miningDirection
    }

    while not IsInventoryFull() do
        TryRefuel()

        local dx = (miningDirection == 1) and 1 or (miningDirection == 3) and -1 or 0
        local dz = (miningDirection == 2) and 1 or (miningDirection == 0) and -1 or 0
        movement.GoToPos(position,{x = position.x + dx, y = position.y, z = position.x + dz, w = position.w})

        local hit, data = turtle.inspectUp()
        if hit then
            if ShouldMine(data) then
                MineOreNode(data.name)
            end
        end

        local hit, data = turtle.inspectDown()
        if hit then
            if ShouldMine(data) then
                MineOreNode(data.name)
            end
        end
        if tunnelIsWalkable then
            turtle.digDown()
        end
        
        movement.LookToward(position,math.fmod(position.w + 1,4))
        local hit, data = turtle.inspect()
        if hit then
            if ShouldMine(data) then
                MineOreNode(data.name)
            end
        end
        
        movement.LookToward(position,math.fmod(position.w + 2,4))
        local hit, data = turtle.inspect()
        if hit then
            if ShouldMine(data) then
                MineOreNode(data.name)
            end
        end
        
        movement.LookToward(position,math.fmod(position.w + 1,4))
        local hit, data = turtle.inspect()
        if hit then
            if ShouldMine(data) then
                MineOreNode(data.name)
            end
        end

        movement.LookToward(position,miningDirection)
    end

    movement.GoToPos(position,rootPosition)

end

function Start()
    GetFuel()

    local destination = {
        x = 0,
        y = -homePosition.y + miningY,
        z = 0,
        w = 0
    }
    
    position = movement.GoToPos(position,destination)

    StartMiningTunnel()

    GoBackHome()

    EmptyInventoryToChest()
end

function SetupOptions(options)
    miningY = options.miningY
    miningDirection = options.miningDirection
    chestDirection = options.chestDirection
    homePosition = options.homePosition
    tunnelIsWalkable = options.tunnelIsWalkable
end

return {
    Start = Start,
    SetupOptions = SetupOptions
}