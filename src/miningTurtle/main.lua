local miningControl = require("miningTurtle")

-- CONTROLLING VARIABLES -- 
local setup = {
    chestDirection = 0,
    miningDirection = 0,
    miningY = 171,
    homePosition = {
        x = -219,
        y = 174,
        z = 1171,   
        w = 0
    },
    tunnelIsWalkable = true
}
-- CONTROLLING VARIABLES --

miningControl.SetupOptions(setup)
miningControl.Start()