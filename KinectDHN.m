%% Dynamic Hypernetwork
% All in one version

%% Parameters
dim = 54; % 처음 조인트 xyz position만 제거 
step = 3;   he_order = 6;   spat_order = 2;
num_edge = 300000;
num_gen = 100;

%% Data Read
%data1 = Data('shake_2t.txt');
% data1 = Data('wave_test_1.txt');
% data1 = Data('test.txt');
filename = 'test';
data1 = Data([filename  '.txt']);

%% Data Sampling
num_data = data1.len-step+1;

% at first do random, later sample in normal dist.
sample_range = step * dim;

hn = zeros(num_edge, sample_range+1);
data_sample = randsample(1:num_data, num_edge, true);

% Initial sample
tic;
edge_idx = 0;
for data_idx=data_sample
    sampling_data = data1.norm_data(data_idx:data_idx+step-1,:);
    rnd_2 = randsample(data1.incl_idx,2)*step-step+1; % Spatial 
    rnd_seq = [rnd_2, rnd_2+1, rnd_2+2];%%%%%%%%%%% This should be revised
    he = NaN*ones(1,sample_range+1);
    he(1+rnd_seq(1:he_order)) = sampling_data(rnd_seq(1:he_order));
    he(1) = 1; % weight
    edge_idx = edge_idx + 1;
    hn(edge_idx,:) = he;
end
toc;
fprintf('sampling completed\n');

%% Generate and resample (Posterior Inference)
% data_set = randperm(num_data);
% for data_idx=data_set
%     sampling_data = norm_data(data_idx:data_idx+step-1,:);
%     gen_data = sampling_data;
%     for to_fill=1:step
%         % build matcher
%         matcher = sampling_data;
%         matcher(to_fill,:) = NaN;
%         matcher = [0, reshape(matcher, 1, [])];
%         matcher = repmat(matcher, num_edge, 1);
%         
%         % match
%         se = (matcher - hn) .^ 2;
%         se(isnan(se)) = 0;
%         sum_se = sum(se(:,2:end),2);
%         
%         importance = hn(:,1) ./ (sum_se + 0.0001);
%         [~,sorted_idx] = sort(importance);
%         
%         rank_num = 1000;
%         ranked_idx = sorted_idx(end-rank_num+1:end);
%         ranked_importance = importance(ranked_idx);
%         sum_ranked_importance = ranked_importance' * ~isnan(hn(ranked_idx,2:end));
%         
%         % DEBUG
%         high_he = hn(sorted_idx,:);
%         high_he = reshape(high_he(end,2:end), 3, []);
%         cur_data = norm_data(data_idx:data_idx+2,:);
%         %%%
%         
%         
%         numer_hn = hn;
%         numer_hn(isnan(numer_hn)) = 0;
%         to_fill_idx = 1+to_fill:3:sample_range;
%         gen_data(to_fill,:) = ...
%             ranked_importance' * numer_hn(ranked_idx,to_fill_idx) ./ sum_ranked_importance(:,to_fill_idx);
%     end % data_generated
%     
%     % build matcher
%     matcher = gen_data;
%     matcher = [0, reshape(matcher, 1, [])];
%     matcher = repmat(matcher, num_edge, 1);
% 
%     % match
%     se = (matcher - hn) .^ 2;
%     se(isnan(se)) = 0;
%     sum_se = sum(se(:,2:end),2);
% 
%     importance = hn(:,1) ./ (sum_se + 0.0001);
% 
% end

%% Generate the data
to_fill = step;

gen_seq = zeros(num_gen, dim);
gen_seq(1:step-1,:) = data1.norm_data(1:step-1,:);
% gen_seq(1:step-1,:) = data1.norm_data(135:136,:);

tic;
for gen_idx=1:num_gen-step+1
    % build matcher
    matcher = gen_seq(gen_idx:gen_idx+step-1,:);
    matcher(to_fill,:) = NaN;
    matcher = [0, reshape(matcher, 1, [])];
    matcher = repmat(matcher, num_edge, 1);

    % match
    se = (matcher - hn) .^ 2;
    se(isnan(se)) = 0;
    sum_se = sum(se(:,2:end),2);

    importance = hn(:,1) ./ (sum_se + 0.0001);
    [~,sorted_idx] = sort(importance);

    rank_num = 5000;
    ranked_idx = sorted_idx(end-rank_num+1:end);
    ranked_importance = importance(ranked_idx);
    sum_ranked_importance = ranked_importance' * ~isnan(hn(ranked_idx,2:end));

    % % DEBUG
    % high_he = hn(sorted_idx,:);
    % high_he = reshape(high_he(end,2:end), 3, []);
    % cur_data = norm_data(data_idx:data_idx+2,:);
    % %%%

    numer_hn = hn;
    numer_hn(isnan(numer_hn)) = 0;
    to_fill_idx = 1+to_fill:3:(sample_range+1);
    gen_seq(gen_idx+step-1,:) = ...
        ranked_importance' * numer_hn(ranked_idx,to_fill_idx) ./ sum_ranked_importance(:,to_fill_idx-1);
end
gen_dat = data1.orig_scale(gen_seq);
toc;

%% Figure 출력 
% for i = 1:dim
% figure(i);
% clf;
% hold on;
% p1 = data1.orig_data(1:num_gen,i);
% p2 = gen_dat(:,i);
% plot(p1, 'r');
% plot(p2, 'b--');
% legend('original', 'generated');
% %axis([0,300,0,4000])
% end

%% BVH 파일로 출력
Kinect2bvh(gen_dat, filename); 

%%
addpath('MOCAP_Toolbox');
addpath('NDLUTIL');
bvhPlayFile([filename, '.bvh']);
