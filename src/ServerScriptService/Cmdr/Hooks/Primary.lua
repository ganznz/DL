return function(registry)
    return registry:RegisterHook("BeforeRun", function(context)
        if context.Executor.UserId ~= 2640156429 then
            return "Nice try lol"
        end
    end)
end