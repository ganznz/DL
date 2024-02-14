-- !strict

--[[
	CREDITS:
	F_d3d (Roblox)
	DevForum Link: https://devforum.roblox.com/t/table-handler-for-all-your-arrays-needs/1518256
	GitHub Repo: https://github.com/ballgoesvroomvroom/TableHandler
]]

local module_container = {}
local algorithms = require(script.Parent.Algorithms)

local tablehandlerclass = {}
tablehandlerclass.__index = tablehandlerclass

-- types
export type SortingParameterObject = {
	Pivot: number
}
export type TableHandlerObject = {
	Ascending: boolean,
	Algorithm: number,
	IncludeNonSorted: boolean,
	ModifyArray: boolean,
	SortFirstFew: number,
	SortingParameters: SortingParameterObject
}

module_container.ver = {
	major = 0,
	minor = 1,
	patch = 1
}

local function __FillTableHandlerObjectParams(): TableHandlerObject
	return {
		Ascending = true,
		Algorithm = 1,
		IncludeNonSorted = true,
		ModifyArray = false,
		SortFirstFew = -1,
		SortingParameters = {
			Pivot = nil
		}
	}
end

local function __floor(n: number)
	if n % 1 > 0 then
		n = n -(n %1)
	end
	return n
end
local function __type_check(var: any, insisted_type: string)
	return type(var) == insisted_type
end
local function __inrange_check(var, min: number, max: number, inclusive: string)
	-- min must always be lower than max for it to logical work
	-- inclusive = "00" for both non inclusive
	-- inclusive = "01" for max value inclusive, min value non inclusive
	if inclusive == nil then
		inclusive = "00"
	end

	local lowerbound, upperbound = false, false
	if inclusive:sub(1, 1) == "0" then
		-- non inclusive for min
		lowerbound = var > min
	else
		lowerbound = var >= min
	end
	if inclusive:sub(2, 2) == "0" then
		-- non inclusive for max
		upperbound = var < max
	else
		upperbound = var <= max
	end
	return lowerbound and upperbound
end


function module_container.new(...)
	local x: TableHandlerObject = __FillTableHandlerObjectParams()
	setmetatable(x, tablehandlerclass)

	local arg = {...}
	if arg[1] ~= nil then
		x:WriteProperties(arg[1])
	end
	return setmetatable({}, { -- read-only table
		__index = x,
		__newindex = function(_, k, v)
			x:WriteProperties({[k] = v})
			-- error("TableHandlerObject properties are read-only, cannot be overwritten. To overwrite properties, use the :WriteProperties() method")
		end,
		__metatable = "READ-ONLY; Do not attempt to change the metatable"
	})
end

function module_container.getver(...)
	local arg = {...}
	local key = arg[1] -- key = "major", "minor", or "patch"
	if module_container.ver[key] ~= nil then
		return module_container.ver[key]
	else
		return tostring(module_container.ver.major).."."..tostring(module_container.ver.minor).."."..tostring(module_container.ver.patch)
	end
end

function tablehandlerclass:GetProperties()
	-- since values are hidden in the proxy table returned by module_container.new() (print(tablehandlerclass) outputs {}), need a method to retrieve all properties
	local list_of_properties = __FillTableHandlerObjectParams()
	for k, v in pairs(list_of_properties) do
		list_of_properties[k] = self[k]
	end
	return list_of_properties
end

function tablehandlerclass:WriteProperties(properties)
	if properties.Ascending ~= nil then
		if not __type_check(properties.Ascending, "boolean") then
			warn(".Ascending value must be a boolean")
		else
			self.Ascending = properties.Ascending
		end
	end
	if properties.Algorithm ~= nil then
		if not __type_check(properties.Algorithm, "number") then
			warn(".Algorithm value must be a number")
		elseif not __inrange_check(properties.Algorithm, 0, algorithms.LENGTH, "11") then
			warn((".Algorithm value must be within 1 - %d(inclusive)"):format(algorithms.LENGTH))
		else
			self.Algorithm = properties.Algorithm
		end
	end
	if properties.IncludeNonSorted ~= nil then
		if not __type_check(properties.IncludeNonSorted, "boolean") then
			warn(".IncludeNonSorted value must be a boolean")
		else
			self.IncludeNonSorted = properties.IncludeNonSorted
		end
	end
	if properties.ModifyArray ~= nil then
		if not __type_check(properties.ModifyArray, "boolean") then
			warn(".ModifyArray value must be a boolean")
		else
			self.ModifyArray = properties.ModifyArray
		end
	end
	if properties.SortFirstFew ~= nil then
		if not __type_check(properties.SortFirstFew, "number") then
			warn(".SortFirstFew must be a number")
		else
			self.SortFirstFew = properties.SortFirstFew
		end
	end
end

function tablehandlerclass:Flip(array)
	-- flips/reverse the array
	-- i.e, array = {3, 1, 5, 10}, return = {10, 5, 1, 3}
	-- NOTE: Modifies the actual array passed as an argument
	if not self.ModifyArray then
		local a = {}
		for i = #array, 1, -1 do
			table.insert(a, array[i])
		end
		return a
	else
		for i = 1, __floor(#array/2) do
			array[i], array[#array -i +1] = array[#array -i +1], array[i]
		end
		return array
	end
end

function tablehandlerclass:Slice(array, s: number, e: number, ...)
	-- s = start, must be positive
	-- e = end, must be positive
	-- step = step value, must be positive, (defualt = 1)
	-- will slice beginning from the start(inclusive) and ending before end value
	-- will return a new array, leaving the passed array(argument) un-modified
	local arg = {...}
	local step = 1
	if #arg >= 1 and type(arg[1]) == "number" then
		step = arg[1]
	end

	local n = #array
	if n == 0 then
		-- array is empty, return immediately
		return array
	end

	-- to handle negative indexes
	if type(s) == "number" and s <= -1 then
		s = #array + s + 1
	end
	if type(e) == "number" and e <= -1 then
		e = #array + e + 1
	end

	if (s == nil or type(s) ~= "number") then
		error("Start value must be a number")
	elseif (e == nil or type(e) ~= "number") then
		error("End value must be a number")
	elseif type(step) ~= "number" then
		error("Step value must be a number")
	elseif s == 0 or e == 0 or step == 0 then
		error("Start, end, step values cannot be zero")
	elseif s > #array or e > #array +1 then -- +1 because it needs a margin of 1 extra index to slice fully till the end of the array
		error(("Start, end values must be within %d and %d (inclusive)"):format(#array *-1, #array))
	elseif step >= 1 then
		-- start must be smaller than end
		if s > e then
			error("Start value cannot be greater than end value with a positive step value")
		end
	elseif step <= -1 then
		-- start value must be greater than end as it traverses right to left
		if s < e then
			error("Start value cannot be smaller than end value with a negative step value")
		end
	end

	local re = {}
	for i = s, e -1, step do
		table.insert(re, array[i])
	end
	return re
end

function tablehandlerclass:Concat(a, b)
	-- concatenate two arrays, a and b
	-- i.e, a = {3, 1}, b = {3, 5}, return = {3, 1, 3, 5}
	-- if modify_array is false, it will create a new table
	local new = {}
	if self.ModifyArray then
		new = a
	else
		for i = 1, #a do
			table.insert(new, a[i])
		end
	end
	for i = 1, #b do
		table.insert(new, b[i])
	end
	return new
end

function tablehandlerclass:Randomise(array, seed: number)
	-- randomises the array
end

function tablehandlerclass:Shift(array, c: number)
	-- positive c to shift all elements to the right
	-- negative to do likewise

	local n = #array
	local true_shift = c % n
	if true_shift == 0 then
		-- no shift
		return array
	end
	if c < 0 then
		-- shift left as c is negative
		true_shift = true_shift * -1
	end

	local new_array = {}
	for i = 1, n do
		local old_pos = i - true_shift
		if old_pos <= 0 then
			old_pos = n + old_pos
		elseif old_pos > n then
			old_pos = old_pos - n
		end

		table.insert(new_array, array[old_pos])
	end
	return new_array
end

function tablehandlerclass:Sort(array)
	local ToSort = {}
	local ToAppend = {} -- to store the non numerical values

	local iteration_limit
	if self.SortFirstFew > 0 then
		iteration_limit = self.SortFirstFew
	end

	for _, v in pairs(array) do
		if type(v) == "number" and (iteration_limit == nil or iteration_limit > 0) then
			table.insert(ToSort, v)
		else
			table.insert(ToAppend, v)
		end
		if iteration_limit ~= nil then
			iteration_limit = iteration_limit - 1
		end
	end

	local SortedList = algorithms.distributor(self.Algorithm, ToSort, self.SortingParameters)
	if not self.Ascending then
		-- SortedList is in Ascending
		SortedList = self:Flip(SortedList)
	end
	if self.IncludeNonSorted then
		-- Appends ToAppend to SortedList
		SortedList = self:Concat(SortedList, ToAppend, true)
	end
	return SortedList
end

function tablehandlerclass:__recurse_array(array)
	local ToSort = {}
	local ToInsert = {} -- store nested sorted arrays here
	local ToInsertIndex = {} -- store nested sorted arrays' index here; when inserting `ToInsert` into `ToAppend` if `.IncludeNonSorted` is true
	local ToAppend = {}

	local iteration_limit
	if self.SortFirstFew > 0 then
		iteration_limit = self.SortFirstFew
	end

	for _, v in pairs(array) do
		if type(v) == "number" and (iteration_limit == nil or iteration_limit > 0) then
			table.insert(ToSort, v)
		elseif type(v) == "table" and (iteration_limit == nil or iteration_limit > 0) then
			table.insert(ToInsert, self:__recurse_array(v))
			table.insert(ToInsertIndex, #ToAppend +1)
		else
			table.insert(ToAppend, v)
		end
		if iteration_limit ~= nil then
			iteration_limit = iteration_limit - 1
		end
	end

	local SortedList = algorithms.distributor(self.Algorithm, ToSort, self.SortingParameters)
	if not self.Ascending then
		-- SortedList is in Ascending
		SortedList = self:Flip(SortedList)
	end
	if self.IncludeNonSorted then
		-- Appends ToAppend to SortedList
		for elementIndex, insertIndex in pairs(ToInsertIndex) do
			table.insert(ToAppend, insertIndex, ToInsert[elementIndex])
		end
		SortedList = self:Concat(SortedList, ToAppend, true)
	else
		SortedList = self:Concat(SortedList, ToInsert, true)
	end
	return SortedList
end

function tablehandlerclass:DeepSort(array)
	-- takes in an array where there are nested arrays
	-- i.e, array = {3, 1, 5, 10, {1, 3, 10, 5, 4, {4, 3, 1, 2}}}
	-- return = {1, 3, 5, 10, {1, 3, 4, 5, 10, {1, 2, 3, 4}}}
	-- index of nested arrays are maintained
	return self:__recurse_array(array)
end

return module_container