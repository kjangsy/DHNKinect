function [seed_idx, fileoutname] =  FileCon2(cnt)
actions = ['clap', 'wave', 'handshake', 'go', 'come'];
as = char('clap', 'wave', 'handshake', 'go', 'come');
splits = [4,8,17,19,23];


seed_idx = ones(cnt, 1);
fileoutname = [actions(1:splits(cnt)), '.txt'];
fout = fopen(fileoutname, 'w');

for i=1:cnt

    filename = [strtrim(as(i, :)), '_1.txt'];
    
    
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
    