return {
    {
        class="Fighter",
        moveShape = function() return grid.newCircle(2) end,
        attackShape = function() return grid.newCross(1) end,
        img = 3,
        color = {100,100,255},
        hero = true,
        stats = {
            hp = 4,
            armor = 3,
            str = 1,
            },
        cost = 10,
        weight = 0,
        ai = function(self) return d.pickClosestAttack(self) or d.moveTowardEnemy(self) end
    },
    {
        class="Ranger",
        moveShape = function() return grid.newBox(1) end,
        attackShape = function() return grid.findCompliment(grid.newStar(10),grid.newStar(1)) end,
        img = 4,
        color = {203,178,151},
        hero = true,
        stats = {
            hp = 2,
            armor = 2,
            str = 1,
            },
        cost = 10,
        weight = 0,
        ai = function(self) return d.pickFurthestAttack(self) or d.moveTowardEnemy(self) end
    },
    {
        class="Mage",
        moveShape = function() return grid.newBox(1) end,
        attackShape = function() return grid.findCompliment(grid.newCross(10),grid.newCross(2)) end,
        img = 5,
        color = {192,20,169},
        hero = true,
        stats = {
            hp = 3,
            armor = 1,
            str = 1,
            },
        cost = 10,
        weight = 0,
        ai = function(self) return d.pickFurthestAttack(self) or d.moveTowardEnemy(self) end
    },
    {
        class="Beastmaster",
        moveShape = function() return grid.joinLists(grid.newBox(1),grid.newCross(2)) end,
        attackShape = function() return grid.newShapeFromGrid({
            {0,0,0,0,0,0,0},
            {0,0,1,0,1,0,0},
            {0,1,1,0,1,1,0},
            {0,0,0,0,0,0,0},
            {0,1,1,0,1,1,0},
            {0,0,1,0,1,0,0},
            {0,0,0,0,0,0,0}
            }) end,
        img = 6,
        color = {86,188,109},
        hero = true,
        stats = {
            hp = 4,
            armor = 2,
            str = 1,
            },
        cost = 10,
        weight = 0,
        ai = function(self) return d.pickFurthestAttack(self) or d.moveTowardEnemy(self) end
    },
    {
        class="Warlock",
        moveShape = function() return grid.newBox(1) end,
        attackShape = function() return grid.newCross(10) end,
        img = 12,
        color = {125,200,125},
        stats = {
            hp = 2,
            armor = 2,
            str = 1,
            },
        cost = 2,
        weight = 1,
        ai = function(self) return d.pickFurthestAttack(self) or d.moveTowardEnemy(self) end
    },
    {
        class="Goatlord",
        moveShape = function() return grid.newStar(2) end,
        attackShape = function() return grid.newBox(1) end,
        img = 11,
        color = {125,200,125},
        stats = {
            hp = 3,
            armor = 3,
            str = 1,
            },
        cost = 4,
        weight = 1,
        ai = function(self) return d.pickClosestAttack(self) or d.moveTowardEnemy(self) end
    },
    {
        class="Demon",
        moveShape = function() return grid.newCircle(4) end,
        attackShape = function() return grid.newCross(1) end,
        img = 13,
        color = {125,200,125},
        stats = {
            hp = 5,
            armor = 1,
            str = 1,
            },
        cost = 4,
        weight = 2,
        ai = function(self) return d.pickFurthestAttack(self) or d.moveTowardEnemy(self) end
    },
    {
        class="Archer",
        moveShape = function() return grid.newBox(1) end,
        attackShape = function() return grid.newRing(4,5) end,
        img = 8,
        color = {125,200,125},
        stats = {
            hp = 2,
            armor = 2,
            str = 1,
            },
        cost = 3,
        weight = 5,
        ai = function(self) return d.pickFurthestAttack(self) or d.moveTowardEnemy(self) end
    },
    {
        class="Thief",
        moveShape = function() return grid.newCross(2) end,
        attackShape = function() return grid.newCross(1) end,
        img = 7,
        color = {125,200,125},
        stats = {
            hp = 2,
            armor = 2,
            str = 1,
            },
        cost = 2,
        weight = 10,
        ai = function(self) return d.pickClosestAttack(self) or d.moveTowardEnemy(self) end
    },
    {
        class="TutorialBoy",
        moveShape = function() return grid.newCross(1) end,
        attackShape = function() return grid.newBox(0) end,
        img = 2,
        color = {125,200,125},
        stats = {
            hp = 3,
            armor = 1,
            str = 1,
            },
        cost = 1,
        weight = 0,
        ai = function(self) return d.avoidEnemy(self) end
    },
    {
        class="Pyromancer",
        moveShape = function() return grid.newStar(1) end,
        attackShape = function() return grid.newShapeFromGrid({
            {0,0,0,0,1,0,0,0,0},
            {0,0,0,1,0,1,0,0,0},
            {0,0,1,0,1,0,1,0,0},
            {0,1,0,1,0,1,0,1,0},
            {1,0,1,0,0,0,1,0,1},
            {0,1,0,1,0,1,0,1,0},
            {0,0,1,0,1,0,1,0,0},
            {0,0,0,1,0,1,0,0,0},
            {0,0,0,0,1,0,0,0,0}
            }) end,
        img = 14,
        color = {125,200,125},
        stats = {
            hp = 3,
            armor = 2,
            str = 1,
            },
        cost = 5,
        weight = 2,
        ai = function(self) return d.pickMostCombos(self) or d.moveTowardEnemy(self) end
    }
}
