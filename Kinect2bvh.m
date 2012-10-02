function Kinect2bvh(newdata, frm_num)


%% Data read
% bvhdat = newdata;
% action = (bvhdat(:,1:20)-2048) .* 180 ./ 2048;
% action2 = action;
% action(:,11:12) = action2(:,9:10);
% action(:,9:10) = action2(:,11:12);

%newdata = gen_dat;
action = newdata;

action_size = size(newdata, 1);

%% Write header
fin = fopen('Kinect.bvh');
fout = fopen('KinectMove.bvh', 'w');
header = fread(fin);
fwrite(fout, header);

fprintf(fout, 'MOTION\nFrames: %d\nFrame Time: 0.0333333\n', action_size);

%% Match format and write actions

for i = 1:size(action, 1)
    angles = action(i, :);
    
    fprintf(fout, '%d %d %d ', 0,0,0);
    
    for j =1:size(action, 2)
        fprintf(fout, '%d ', angles(j));
    end
    
    fprintf(fout, '\n');
end
fclose(fin);
fclose(fout);

% for act=frm_num %1:action_size
%     angles = action(act, :);
%     angles = repmat(angles, 3, 1)';
% 
%     % direction of each motor axis: XYZ 
%     direction = [
%         -1 0 0 ;
%         1 0 0 ;
%         0 0 -1 ;
%         0 0 -1 ;
%         0 1 0 ; % 5
%         0 1 0 ;
%         0 -1 0 ;
%         0 -1 0 ;
%         1 0 0 ;
%         -1 0 0 ; % 10
%         0 0 -1 ;
%         0 0 -1 ;
%         1 0 0 ;
%         -1 0 0 ;
%         -1 0 0 ; % 15
%         1 0 0 ;
%         0 0 1 ;
%         0 0 1 ;
%         0 1 0 ;
%         -1 0 0 ; % 20
%     ];
% 
%     % offset angle
%     offset = zeros(20, 3);
%     offset(3, 3) = -180/4;
%     offset(4, 3) = 180/4;
%     offset(5, 2) = 180/2;
%     offset(6, 2) = -180/2;
% 
%     % mapping
%     map = [19, 20, 2, 4, 6, 1, 3, 5, 8, 10, 12, 14, 16, 18, 7, 9, 11, 13, 15, 17];
%     % Reshaping
%     % direction = reshape(direction', 1, []);
%     % offset = reshape(offset', 1, []);
% 
%     angles = (angles + offset) .* direction;
%     angles = [angles(:,3), angles(:,1:2)]; % Change XYZ to ZXY
%     new_angles = angles(map, :); % Reorder motor num to bvh sequence
%     new_angles = reshape(new_angles', 1, []); % Serialize
% 
%     %% bvh file write
% 
%     for i=1:9 % set root pos and dummy to zero
%         fprintf(fout, '%d ', 0);
%     end
%     for i=1:60
%         fprintf(fout, '%d ', new_angles(i));
%     end
%     fprintf(fout, '\n');
% 
% end

%%
% bvhPlayFile('DarwinMove.bvh');


end