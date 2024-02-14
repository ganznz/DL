algorithms = {}
--[[
Changes will be made to passed array (Modifies the passed array).
Parser(SorterObj) would have made a copy array where number elements are filtered into it.
All sorting functions assume that the array passed contains valid elements.
All sorted occurs in ascending order.
--]]

--algorithms.LENGTH = 6 -- amount of algorithms
setmetatable(algorithms, {
	__index = function(a, k)
		if k == "LENGTH" then
			-- to get .LENGTH constant
			return #a.dir
		end
	end
})

local function __round(n)
	if n % 1 >= 0.5 then
		return n - (n % 1) + 1
	else
		return n - (n % 1)
	end
end
local function __floor(n)
	if n % 1 > 0 then
		n = n -(n %1)
	end
	return n
end

function algorithms.distributor(algoNo: number, array, sortingargs)
	if type(algoNo) ~= "number" or algoNo <= 0 or algoNo > #algorithms.dir then
		error(("Invalid argument passed, 'algoNo', must be a number between 1 and %d (inclusive)"):format(#algorithms.dir))
	else
		if #array < 2 then
			-- array only has less than 2 items, no sorting needed
			return array
		end
		return algorithms.dir[algoNo](array, sortingargs)
	end
end

function algorithms.bubblesort(array, _)
	for x = 1, #array do
		for y = 1, #array -x do
			if array[y] > array[y +1] then
				local c = array[y]
				array[y] = array[y +1]
				array[y +1] = c
			end
		end
	end
	return array
end

function algorithms.insertionsort(array, _)
	for x = 2, #array do
		y = x -1
		while y > 0 and array[y] < array[x] do
			array[y +1] = array[y]
			y = y - 1
		end
		array[y +1] = array[x]
	end
	return array
end

local function __heapify(array, n, i)
	local largest = i
	local l = 2 *i
	local r = 2 *i +1

	if l <= n and r <= n then
		-- both child exists
		if array[l] < array[r] then
			array[r], array[l] = array[l], array[r]
		end
	end
	if l <= n and array[l] > array[largest] then
		-- right child node exists
		largest = l
	end
	if r <= n and array[r] > array[largest] then
		-- left child node exists
		largest = r
	end

	if largest ~= i then
		array[i], array[largest] = array[largest], array[i]
		__heapify(array, n, largest)
	else
		-- done
	end
end
function algorithms.heapsort(array)
	n = #array

	for i = __floor(n/2), 1, -1 do
		__heapify(array, n, i)
	end

	local stored = {}
	for i = n, 2, -1 do
		table.insert(stored, 1, array[1]) -- insert at the very front
		n = n - 1

		array[1] = array[i]
		__heapify(array, n, 1)
	end
	return stored
end

local function __getpartition(l, h, array, pivot)
	local startingpivot = l --round(#array/2 -.5)
	if pivot ~= nil then
		startingpivot = pivot
	end

	local pivotvalue = array[startingpivot]
	local i = l
	local j = h
	while i < j do
		while array[i] <= pivotvalue do
			i = i + 1 -- i++ ;(
		end
		while array[j] > pivotvalue do
			j = j - 1
		end

		if (i < j) then
			array[i], array[j] = array[j], array[i]
		end
	end

	array[startingpivot], array[j] = array[j], array[startingpivot]
	return startingpivot, j
end
local function __quicksort(l, h, array, startingpivot)
	-- recursive
	if l < h then
		local initial, j = __getpartition(l, h, array, startingpivot)
		if not (initial == j) then
			__quicksort(l, j, array) -- left side
			__quicksort(j +1, h, array) -- right side
		else
			-- sorted
			--print("sorted already")
		end
	else
		-- print("sorted by < 2 values")
		-- array has less than 2 values (1)
		-- no need to return, since array is being modified
	end
end
function algorithms.quicksort(array, args)
	local startingpivot = __round(#array/2 -.5)
	if args ~= nil and args.Pivot ~= nil and type(args.Pivot) == "number" and args.Pivot > 0 and args.Pivot <= #array then
		startingpivot = args.Pivot
	elseif args ~= nil and args.Pivot ~= nil then
		-- failed to use args.Pivot
		warn(".Pivot argument in SorterObject.SortingParameters was invalid; did not use")
	end

	__quicksort(1, #array, array, startingpivot)
	return array
end

function algorithms.selectionsort(array, _)
	for a = 1, #array do
		local smallest_index = a
		for b = 1 +a -1, #array do
			if array[b] < array[smallest_index] then
				smallest_index = b
			end
		end
		array[a], array[smallest_index] = array[smallest_index], array[a]
	end
	return array
end

algorithms.dir = {
	algorithms.bubblesort,
	algorithms.insertionsort,
	algorithms.heapsort,
	algorithms.quicksort,
	algorithms.selectionsort
}
return algorithms