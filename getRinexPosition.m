function pos_xyz = getRinexPosition(filename)

fid = fopen(filename,'r');
if fid == -1
    error('Cannot open file.');
end

pos_xyz = [];

while ~feof(fid)
    line = fgetl(fid);

    % Stop if header ends and nothing found
    if contains(line, 'END OF HEADER')
        break;
    end

    % Find approximate receiver position
    if contains(line, 'APPROX POSITION XYZ')
        pos_xyz = sscanf(line(1:60), '%f %f %f').';
        break;
    end
end

fclose(fid);

if isempty(pos_xyz)
    error('APPROX POSITION XYZ not found in RINEX header.');
end

end