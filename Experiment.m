actions = char('clap', 'wave', 'handshake', 'go', 'come');
for ii=1:5 %% for five actions
    action = strtrim(actions(ii, :));

    gen_data = zeros(5, 100);
    errArr = zeros(5, 5);
    for i = 1:5
        [seed_idx, fileoutname] = FileCon(action, i);
        for j = 1:i
            [errArr(i,j), gen_temp] = KinectDHNFunc(fileoutname, i, seed_idx(j));
        end
    end
    save([action, 'exp_result']);
end