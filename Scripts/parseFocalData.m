function channelData = parseFocalData(data,groupName,channelName)

str = [groupName,'/',channelName];

index = -1;
N = size( data.Data.MeasuredData,2);
for i=1:N
    if strcmp(data.Data.MeasuredData(i).Name,str)
        index = i;
    end
end

if (index < 0)
    error(['Cannot find channel ',str])
end
    
channelData = data.Data.MeasuredData(index).Data;
