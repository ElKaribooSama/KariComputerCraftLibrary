local direction = {
    north = 0,
    east = 1,
    south = 2,
    west = 3
}
 
function GetDisplacement(position,destination)
    local displacement = {
        x = position.x - destination.x,
        y = position.y - destination.y,
        z = position.z - destination.z,
        w = math.fmod(4 - position.w + destination.w,4)
    }
    
    return displacement
end
 
function CanGoForward()
    local hit, data = turtle.inspect()
    return not hit
end
 
function CanGoDown()
    local hit, data = turtle.inspectDown()
    return not hit
end
 
function CanGoUp()
    local hit, data = turtle.inspectUp()
    return not hit
end
 
function LookToward(pos,direction)
    local rotation = math.fmod(4-pos.w+direction,4)
    pos.w = rotation

    for i = 1,rotation do
        turtle.turnRight()
    end
end

function LookIntoBlock(position,destination)
    local distanceX = destination.x - position.x
    local distanceZ = destination.z - position.z
    
    if (math.abs(distanceX) + math.abs(distanceZ)) == 1 then
        if distanceX ~= 0 then
            if (destination.x - position.x) < 0 then
                LookToward(position,direction.east)
            else
                LookToward(position,direction.west)
            end
        end
        if distanceZ ~= 0 then
            if (destination.z - position.z) < 0 then
                LookToward(position,direction.north)
            else
                LookToward(position,direction.south)
            end
        end
    else
        return false
    end
end

function GoToPos(position, destination)
    local moveX = destination.x - position.x
    local moveY = destination.y - position.y
    local moveZ = destination.z - position.z

    print("moving in y : " .. moveY)
    while moveY ~= 0 do
        print(moveY)
        if moveY < 0 then
            if not CanGoDown() then
                turtle.digDown()
            end
            turtle.down()
            position.y = position.y - 1
            moveY = moveY + 1
        else
            if not CanGoUp() then
                turtle.digUp()
            end
            turtle.up()
            position.y = position.y + 1
            moveY = moveY - 1
        end
    end

    print("moving in x : " .. moveX)
    while moveX ~= 0 do
        print(moveX)
        if moveX < 0 then
            LookToward(position,direction.west)
            position.x = position.x - 1
            moveX = moveX + 1
        else
            LookToward(position,direction.east)
            position.x = position.x + 1
            moveX = moveX - 1
        end
        
        TryRefuel()
        if CanGoForward() then
            turtle.dig()
        end
        turtle.forward()
    end

    print("moving in Z : " .. moveZ)                                                                                                                        
    while moveZ ~= 0 do
        print(moveZ)
        if moveZ < 0 then
            LookToward(position,direction.north)
            position.z = position.z - 1
            moveZ = moveZ + 1
        else
            LookToward(position,direction.south)
            position.z = position.z + 1
            moveZ = moveZ - 1
        end
        TryRefuel()
        if not CanGoForward() then
            turtle.dig()
        end
        turtle.forward()
    end

    LookToward(position,destination.w)
    return position
end
 
return { 
    LookToward = LookToward,
    CanGoUp = CanGoUp,
    CanGoDown = CanGoDown,
    CanGoForward = CanGoForward,
    GetDisplacement = GetDisplacement,
    GoToPos = GoToPos,
    direction = direction
}
