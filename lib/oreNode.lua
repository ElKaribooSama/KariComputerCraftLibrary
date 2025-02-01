local nodeStruct = {
    type = nil,
    movementList = nil,
    size = nil
}

local direction = {
    north = 0,
    east = 1,
    south = 2,
    west = 3,
    up = 4,
    down = 5,
    none = 6
}

function NewNode(type)
    local node = nodeStruct
    node.type = type
    node.size = 1
    node.movementList = {}
    return node
end

function AddMove(node,move)
    node.size = node.size + 1
    table.insert(node.movementList,move)
end

function FindBlockAround(position,node)
    local hit, data = nil, nil
    hit, data = turtle.inspect()
    
    if hit then
        if data.name == node.type then
            return position.w
        end
    end

    turtle.turnRight()
    hit, data = turtle.inspect()
    
    if hit then
        if data.name == node.type then
            turtle.turnLeft()
            return math.fmod(position.w + 1,4)
        end
    end

    turtle.turnRight()
    hit, data = turtle.inspect()

    if hit then
        if data.name == node.type then
            turtle.turnLeft()
            turtle.turnLeft()

            return math.fmod(position.w + 2,4)
        end
    end


    turtle.turnRight()
    hit, data = turtle.inspect()

    if hit then
        if data.name == node.type then
            turtle.turnRight()

            return math.fmod(position.w + 3,4)
        end
    end

    turtle.turnRight()
    hit, data = turtle.inspectUp()

    if hit then
        if data.name == node.type then
            return direction.up
        end
    end

    hit, data = turtle.inspectDown()

    if hit then
        if data.name == node.type then
            return direction.down
        end
    end

    return direction.none
end

return {
    direction = direction,
    NewNode = NewNode,
    FindBlockAround = FindBlockAround,
    AddMove = AddMove,
}