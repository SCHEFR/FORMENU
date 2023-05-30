-- FORMENU v0.1.0
--───── ADDITIONAL FUNCTIONS ─────--
local function table.titles(functions, parameter)
    parameter = parameter or "title"
    local titles = {}
    for place, funce in ipairs(functions) do
        titles[place] = funce[parameter]
    end
    return titles
end
local function table.merge(this, with)
    for key, value in next, with do
        this[key] = value
    end
    return this
end
local function table.map(table, func)
    for i, v in next, table do
        table[i] = func(i, v)
    end
    return table
end

return {
    version = 'FORMENU v0.1.0',
    dialog = function(format, newTable)
        --───── CHECKS ─────--
        local function fassert(cond, throw)
            return assert(cond, "[ FORMENU ERROR ]	" .. throw .. "\n")
        end
        fassert(newTable, "No newTable provided")
        fassert(type(newTable) == "table", "newTable is not a table")
        fassert(newTable.type, "newTable does not have a type field")
        if newTable.type == "doubleChoice" then
            fassert(newTable.items, "newTable.items is nil")
            fassert(type(newTable.items) == "table", "newTable.items is not a table")
        elseif newTable.functions then
            fassert(type(newTable.functions) == "table", "newTable.functions is not a table")
        elseif newTable.next then
            fassert(type(newTable.next) == "table", "newTable.next is not a table")
        end

        --───── SELECTION DIALOG TYPES ─────--
        local types = {
            choice = function(self, message) -- gg.choice
                message = type(message) == "string" and message or ""
                local choice = gg.choice(table.titles(self.functions), nil, "#  " .. message)
                return choice and
                    ((self.functions[choice].func and
                        (self.functions[choice].func() or self.functions[choice].return_message or true)) or
                        (self.functions[choice].next and (format:dialog(self.functions[choice].next):form() or true)))
            end,
            multiChoice = function(self, message) -- gg.multiChoice
                local chosee = {defaults = {}, chosen = {}}
                for i, v in next, self.functions do
                    if v.chosen then
                        chosee.defaults[i] = true
                    end
                end
                return table.map(
                    gg.multiChoice(table.titles(self.functions), chosee.defaults, message) or {},
                    function(index, state)
                        return state and self.functions[index].func()
                    end
                )
            end,
            doubleChoice = function(self, message)
                local choice = gg.choice(table.merge(table.titles(self.items, "name"), table.titles(self.functions)))
                return choice and
                    (choice > #self.items and self.functions[choice - #self.items].func() and
                        self.functions[choice - #self.items].return_message or
                        choice <= #self.items and self.itemFunction(self.items[choice]))
            end
        }
        --───── DIALOG RETURN ─────--
        return table.merge(
            newTable,
            {
                form = function(self, message)
                    local formation = types[self.type](self, message)
                    return formation and self.returns and self:form(formation) or self
                end,
                wrap = function(self)
                    return format.wrap(self)
                end
            }
        )
    end,
    wrap = function(self)
        gg.showUiButton()
        while true do
            if gg.isClickedUiButton() then
                self:form()
            end
        end
    end
}
