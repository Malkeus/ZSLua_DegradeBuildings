function table.random_value (t)

  local f = true
  local tf = {}
  if (f) then
    for _, v in pairs(t) do
    if (type(v) ~= "function" ) then
      table.insert(tf, v)
    end
    end
  else
    tf = t
  end
  
  local choice
  local n = 0
  for _, o in pairs(tf) do
    n = n + 1
    if (math.random() < (1/n)) then
      choice = o    
    end
  end
  return choice 
end

