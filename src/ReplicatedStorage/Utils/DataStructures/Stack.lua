local Stack = {}

Stack.__index = Stack


function Stack.new()
	local self = setmetatable({}, Stack)
	self._stack = {}

	return self
end

function Stack:IsEmpty()
	return #self._stack == 0
end

function Stack:Push(value)
	self._stack[#self._stack+1] = value
end

function Stack:Peek()
	if self:IsEmpty() then return nil end

	local value = self._stack[#self._stack]

	return value
end

function Stack:Pop()
	if self:IsEmpty() then return nil end

	local value = self._stack[#self._stack]
	self._stack[#self._stack] = nil

	return value
end

return Stack