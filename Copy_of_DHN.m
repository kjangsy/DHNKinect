%% Dynamic Hypernetwork
% All in one version

%% Data Read
data = dlmread('record.txt', '\t');
data = data(11:end,[1:2,9:18]);

%% Data Normalize 
dim = size(data, 2);
len = size(data, 1);

% Normalize
data_mean = mean(data);
data_std = std(data);
data_std(data_std==0) = 1;
norm_data = (data - repmat(data_mean, len, 1)) ./ repmat(data_std, len, 1);

%% Data sampling
step = 3;
num_data = len-step+1;

% at first do random, later sample in normal dist.
sample_range = step * dim;
he_order = 6;
num_edge = 100000;
hn = zeros(num_edge, sample_range+1);
data_sample = randsample(1:num_data, num_edge, true);

% Initial sample
edge_idx = 0;
for data_idx=data_sample
    sampling_data = norm_data(data_idx:data_idx+step-1,:);
    rnd_2 = randsample(1:dim,2)*3-2;%%%%%%%%%%% This '2' should be revised
    rnd_seq = [rnd_2, rnd_2+1, rnd_2+2];
    he = NaN*ones(1,sample_range+1);
    he(1+rnd_seq(1:he_order)) = sampling_data(rnd_seq(1:he_order));
    he(1) = 1; % weight
    edge_idx = edge_idx + 1;
    hn(edge_idx,:) = he;
end

% Generate and sample
data_set = randperm(num_data);
for data_idx=data_set
    sampling_data = norm_data(data_idx:data_idx+step-1,:);
    gen_data = sampling_data;
    for to_fill=1:step
        % build matcher
        matcher = sampling_data;
        matcher(to_fill,:) = NaN;
        matcher = [0, reshape(matcher, 1, [])];
        matcher = repmat(matcher, num_edge, 1);
        
        % match
        se = (matcher - hn) .^ 2;
        se(isnan(se)) = 0;
        sum_se = sum(se(:,2:end),2);
        
        importance = hn(:,1) ./ (sum_se + 0.0001);
        [~,sorted_idx] = sort(importance);
        
        rank_num = 1000;
        ranked_idx = sorted_idx(end-rank_num+1:end);
        ranked_importance = importance(ranked_idx);
        sum_ranked_importance = ranked_importance' * ~isnan(hn(ranked_idx,2:end));
        
        % DEBUG
        high_he = hn(sorted_idx,:);
        high_he = reshape(high_he(end,2:end), 3, []);
        cur_data = norm_data(data_idx:data_idx+2,:);
        %%%
        
        
        numer_hn = hn;
        numer_hn(isnan(numer_hn)) = 0;
        to_fill_idx = 1+to_fill:3:sample_range;
        gen_data(to_fill,:) = ...
            ranked_importance' * numer_hn(ranked_idx,to_fill_idx) ./ sum_ranked_importance(:,to_fill_idx);
    end
end












