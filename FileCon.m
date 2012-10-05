function [seed_idx, fileoutname] =  FileCon(action, cnt)
seed_idx = ones(cnt, 1);
fileoutname = [action, int2str(cnt), 'conn.txt'];
fout = fopen(fileoutname, 'w');

for i=1:cnt
    filename = [action, '_', int2str(i), '.txt'];
    
    fin = fopen(filename);
    temp = fread(fin);
    
    dd = Data(filename);
    if i == 1
        seed_idx(i+1) = size(dd.orig_data, 1) + 11;
    else
        seed_idx(i+1) = seed_idx(i) + size(dd.orig_data, 1) + 20;
    end
    
    
    fwrite(fout, temp);
    fclose(fin);
end
fclose(fout);
    