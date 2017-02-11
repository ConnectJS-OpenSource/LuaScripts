function split(str,sep)
    local array = {}
    local reg = string.format("([^%s]+)",sep)
    for mem in string.gmatch(str,reg) do
        table.insert(array, mem)
    end
    return array
end

_str = "gpio,8,output,high"
s,e = string.find(_str,"gpio")
print(s.."-"..e)
a = split(_str,",")
print(table.getn(a))