function printFocalChannels(data)

N = size( data.Data.MeasuredData,2);
for i=1:N
    fprintf('Channel %4.0f -> %s\n',i,data.Data.MeasuredData(i).Name)
end
