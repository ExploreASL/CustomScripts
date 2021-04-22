function readText = readTextFile(filePath)

    fid = fopen(filePath);
    tline = fgetl(fid);
    it = 1;
    while ischar(tline)
        tline = fgetl(fid);
        readText{it,1} = tline;
        it = it+1;
    end
    fclose(fid);

end