local DatastoreUtils = {}

function DatastoreUtils.CFrameToTable(cf: CFrame)
    return { cf:GetComponents() }
end

function DatastoreUtils.TableToCFrame(t)
    return CFrame.new(table.unpack(t));
end

return DatastoreUtils