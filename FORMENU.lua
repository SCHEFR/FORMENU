return {
    --───── SELECTION DIALOG TYPES ─────--
    types = {
        choice = function(format, self, message) -- gg.choice
            message = type(message) == "string" and message or ""
            local choice = gg.choice(format.titles(self.functions), nil, (self.default_message or '').."\n#  " .. message)
            return choice and
                ((self.functions[choice].warn and format.warn(self.functions[choice].warn)) or
                    (self.functions[choice].func and
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
            return map(
                gg.multiChoice(format.titles(self.functions), chosee.defaults, message) or {},
                function(index, state)
                    return state and self.functions[index].func()
                end
            )
        end,
        doubleChoice = function(self, message)
            local choice = gg.choice(merge(format.titles(self.items, "name"), format.titles(self.functions)))
            return choice and
                (choice > #self.items and self.functions[choice - #self.items].func() and
                    self.functions[choice - #self.items].return_message or
                    choice <= #self.items and self.itemFunction(self.items[choice]))
        end
    },
    --───── ADDITIONAL FUNCTIONS ─────--
    map = function(table, func)
        for i, v in next, table do
            table[i] = func(i, v)
        end
        return table
    end,
    merge = function(this, with)
        for key, value in next, with do
            this[key] = value
        end
        return this
    end,
    titles = function(functions, parameter)
        parameter = parameter or "title"
        local titles = {}
        for place, funce in ipairs(functions) do
            titles[place] = funce[parameter]
        end
        return titles
    end,
    dialog = function(format, newTable)
        --───── CHECKS ─────--
        local function fassert(cond, throw)
            return assert(cond, "[FORMENU]	" .. throw .. "\n")
        end
        fassert(newTable, "No newTable provided")
        fassert(type(newTable) == "table", "newTable is not a table.")
        fassert(newTable.type, "newTable does not have a type field")
        if newTable.type == "doubleChoice" then
            fassert(newTable.items, "newTable.items is nil")
            fassert(type(newTable.items) == "table", "newTable.items is not a table.")
        end
        if newTable.functions then
            fassert(type(newTable.functions) == "table", "newTable.functions is not a table.")
            format.map(
                newTable.functions,
                function(key, value)
                    if value.link then
                        local function linkInner(path)
                            local short = path.self or newTable
                            for i, v in ipairs(path) do
                                short = short.functions[v].next or short.functions[v]
                            end
                            return short
                        end
                        fassert(
                            type(value.link) == "number" or type(value.link) == "table",
                            "link must be a number or a table"
                        )
                        return type(value.link == "number") and newTable.functions[value.link] or linkInner(value.link)
                    else
                        return value
                    end
                end
            )
        end

        --───── DIALOG RETURN ─────--
        return format.merge(
            newTable,
            {
                form = function(self, message)
                    local formation = format.types[self.type](format, self, message)
                    return formation and self.returns and self:form(formation) or self
                end,
                wrap = format.wrap
            }
        )
    end,
    wrap = function(dialog)
        gg.showUiButton()
        while true do
            if gg.isClickedUiButton() then
                dialog:form()
            end
        end
    end,
    warn = function(message)
        return gg.alert(message, "PROCEED", nil, "RETURN") == 3
    end
}
