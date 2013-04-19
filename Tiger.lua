-- Tutorial 4: Close is good!

function ai.init(map, money)
	--buyTrain(1,1, 'E')
    --print("huhu")

    -- build Graph
    G = buildGraph(map)
    Passengers = {}
    print(map[3][4])
    local start = {idx=getIdx(1,1), d="E"}
    print("start " .. node2Str(start))
    dist, path = dijkstra(start, getIdx(4,3))
    print(dist)
    print(t2s(path))
    print("done init")
end

function printNodeList( path )
    for _, v in pairs(path) do print(node2Str(v)) end
end
function node2Str( node )
    return "" .. node.idx .. " from " .. node.d
end

function getIdx( x, y )
    return x * 1000 + y
end

function getPositionFromIndex( idx )
    local x = math.floor(idx / 1000)
    local y = idx - math.floor(idx/1000)*1000
    return x,y
    -- body
end

function getDirectionFromIndex( from, to )
    local fromX, fromY = getPositionFromIndex(from)
    local toX, toY = getPositionFromIndex(to)
    print("ll"..fromX.."." .. fromY .."|".. toX ..".".. toY)
    return getDirection(fromX, fromY, toX, toY)
end

function getDirection( fromX, fromY, toX, toY )
    if fromX > toX then
        print("west")
        return "W"
    elseif fromX < toX then
        print("east")
        return "E"
    elseif fromY > toY then
        print("north")
        return "N"
    elseif fromY < toY then
        print("south")
        return "S"
    end
end

function getStartNodeFromTrain( train )
    local node = {}
    node.idx = getIdx(train.nextX, train.nextY)
    node.d = getDirection(train.nextX, train.nextY, train.x, train.y)
    return node
end

function ai.chooseDirection(train, possibleDirs)
    local start_n = getStartNodeFromTrain(train)
    if train.passenger then
        local goal_idx = getIdx(train.passenger.destX, train.passenger.destY)
        local dist, path = dijkstra(start_n, goal_idx)
        --print(path[2].idx)
        return getDirectionFromIndex(start_n.idx, path[2].idx)
        --print(">>" .. next_step)
        -- get shortes distance to direction
    else
        -- get shortest distance to next player
        --if #Passengers > 0 then
            local passenger = Passengers[1]
            local min_goal_idx = getIdx(passenger.x, passenger.y)
            --print(t2s(start_n)..".."..min_goal_idx)
            local min_dist, min_path = dijkstra(start_n, min_goal_idx)
            print(min_dist .. "|" .. t2s(min_path))
            --for _, passenger in Passengers do
            --    local goal_idx = getIdx(passenger.x, passenger.y)
            --    local dist, path = dijkstra(start_n, goal_idx)
            --    if dist < min_dist then
            --        min_dist = dist
            --        min_path = path
            --        min_goal_idx = goal_idx
            --    end
            --end
            -- tODO register this passenger, and ignore it for the other trains
            return getDirectionFromIndex(start_n.idx, min_path[2].idx)
            --print("boo")
        --end
    end
    --print(train.x .. ":" .. train.y .. "|" ..train.nextX .. ":" .. train.nextY)
end

function ai.newPassenger( name, x, y, destX, destY, vipTime )
    -- body
    local passenger = {}
    passenger.name = name
    passenger.x = x
    passenger.y = y
    passenger.destX = destX
    passenger.destY = destY
    passenger.vipTime = vipTime
    passenger.assigned = nil
    table.insert(Passengers, passenger)

    buyTrain(x,y)
end

function ai.passengerBoarded(train, passenger)      -- called when another player's train picks up a passenger

end

function ai.foundPassengers( train, passengers )
    pass = passengers[1]
    dist = distance(train, pass)
    i = 2
    while i <= #passengers do
        d = distance(train, passengers[i])
        if d < dist then
            pass = passengers[i]
        end
        i = i + 1
    end
    return pass
end

function ai.foundDestination( train )
    dropPassenger(train)
end

function ai.enoughMoney(  )
    -- buyTrain(3,5)
end

function distance( train, passenger )
    return math.abs(train.x - passenger.destX) + math.abs(train.y - passenger.destY)
end

function buildGraph( map )
    local idx = 1
    local powerMap = {}
    local G = {}

    for j = 1, map.height do
        for i = 1, map.width do
            if map[i][j] == "C" then
                local num_neighbours = 0
                local pos = getIdx(i, j)
                local node = {}
                node.neighbours = {}
                for f,d in pairs({"N", "E", "S", "W"}) do
                    next_pos = getNextIdx(map, i, j, d)
                    if next_pos then
                        num_neighbours = num_neighbours + 1
                        node.neighbours[d] = next_pos
                    end
                end
                G[pos]=node
            else
            end
        end
    end

    printMap(map)
    return G

end

function getNextIdx( map, x, y, direction )
    if direction == "N" then
        y = y - 1
    elseif direction == "E" then
        x = x + 1
    elseif direction == "S" then
        y = y + 1
    elseif direction == "W" then
        x = x - 1
    else
        return nil
    end

    if x <= 0 or y <= 0 or x > map.width or y > map.height then
        return nil
    end

    if map[x][y] == "C" then
        return getIdx(x, y)
    else
        return nil
    end
end

function printMap(map)
    local str = {}
    for j = 1, map.height do
        str[j] = ""
        for i = 1, map.width do
            local new = "_ "
            if map[i][j] == "C" then 
                new = map[i][j] .. " "
            --elseif map[i][j] then
             --   new = " . "
            end
            str[j] = str[j] .. new
        end
    end
    for i = 1, #str do
        print(str[i])
    end
end

function od( direction )
    if direction == "N" then
        return "S"
    elseif direction == "E" then
        return "W"
    elseif direction == "S" then
        return "N"
    elseif direction == "W" then
        return "E"
    else
        return nil
    end
end


function get_neighbours( node )
    local node_lookup = G[node.idx]
    local last_n = nil
    local inserts = 0
    local neighbours = {}
    for d, node_idx in pairs(node_lookup.neighbours) do
        last_n = {idx=node_idx, d=od(d)}
        if d ~= node.d then
            table.insert(neighbours, last_n)
            inserts = inserts + 1
        end
    end

    if inserts == 0 then
        table.insert(neighbours, last_n)
    end

    return neighbours
end

function are_neighbours( nodea, nodeb )
    node_lookup = G[nodea.idx]
    for d, node_idx in pairs(node_lookup.neighbours) do
        if nodeb.idx == node_idx then
            return true
        end
    end
    return false
end

--[[
  Finds shortest paths from node \a n_start to all other nodes in graph
  
  \param n_start start node of search
  \param length function where length(n, m) denotes length between
   node m and n
   connected to a node. \a edges should be on the form edges(n), which 
   returns a function that will return the next neighbor of node n

   the node must represent the direction where it came from, so we could eleminate this as
   a possible neighbor. But if there is just one neighbour, we cannot ignore it.
]]--
function dijkstra(n_start, goal_idx)
    local candidates = {n_start} -- Nodes which will be visisted
    local distance = {} -- distance[n] is best estimate of distance from node n to n_start
    local visited = {} -- visited[v] == true means v has been visisted in graph traversal
    local path = {}

    distance[n_start] = 0
    path[n_start] = n_start
    visited[n_start] = true
    -- Greedy loop
    while #candidates >= 0 do
        -- Select closest neighbor, mark as visisted
        local v = nil
        local minn = candidates[1]
        local mind = distance[minn]
        local mindx = 1
        for _, node in pairs(candidates) do
            
            if distance[node] < mind then
                mind = distance[node]
                minn = node
                mindx = _
            end
        end
        table.remove(candidates,mindx)
        v = minn

        if v.idx == goal_idx then
            local c = v
            local pathtmp = {c}
            while c ~= n_start do
                c = path[c]
                table.insert(pathtmp, 1, c)
            end
            return distance[v] + 1, pathtmp
        end
        for _,w in pairs(get_neighbours(v)) do
            if not visited[w] then 
                table.insert(candidates, w) 
                distance[w] = distance[v] + 1
                path[w] = v        
                visited[w] = true
            end
        end
        
        -- Relax edges
        for _,w in pairs(candidates) do
            if are_neighbours(v,w) then
                local d = distance[v] + 1
                if  d < distance[w] then
                    distance[w] = d
                    path[w] = v
                end
            end
        end
    end
    return distance, path
end


function t2s(list, i)
    local retval = '{'
    for k,v in pairs(list) do
        if(type(v) == 'table') then
            retval = retval .. t2s(v)
        else
            retval = retval .. k .. "=" .. v
        end
    end
    return retval .. '}'
end