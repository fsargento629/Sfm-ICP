%% Definitions
clear;clc;close all;
reprojection_error_threshold=2;
dir="Datasets\pombal_3\";
detector="SURF";
scene="pombal";

%% intrinsics
load(strcat(dir,'/intrinsics'));
%% load extrinsics
load(strcat(dir,'/extrinsics'));
pitch=90-pitch;
%% load images
imds = imageDatastore(dir);

% select images (only the selected samples
images = cell(1, numel(imds.Files));
color_images= cell(1, numel(imds.Files));
for i=1:numel(imds.Files)
    I = readimage(imds, i);
    images{i} = rgb2gray(I);
    color_images{i}=I;
end
%% motion estimation and reconstruction
tic;
while 1
    % motion estimation
    [vSet]=motion_estimation(intrinsics,images,detector,400);
    ang=getAngles(vSet,heading,pitch);
    % dense reconstruction (KLT)
    [xyzPoints, camPoses, reprojectionErrors,tracks]...
        = dense_constructor_LKT(intrinsics,images,"Eigen001",vSet);
    if size(xyzPoints,1)>4200 && mean(reprojectionErrors)<0.8
        break;
    end
end
toc;
%% xyz transform
traj=getEstimatedTraj(camPoses);
s=25;
[pcl,traj,scale]=xyz_transform(xyzPoints,...
    camPoses,[0,0,origin(3)],heading,pitch,s);
%% remove outliers
[idx,p,tracks,reprojectionErrors]=removeOutliers_real(...
    pcl,reprojectionErrors,reprojection_error_threshold,tracks,10000);
%% get color
color=getColor(tracks,color_images,size(p,1));
% save_dir='res/';
% formatOut = 30;
% d=datestr(now, formatOut);
% save(strcat(save_dir,d));

%% ICP
[rmse,tform,p_icp_abs] = ICP(p,[0,0,0],origin(1:2),scene);
disp(rmse);
% evaluate
[xy,dz]=geo_evaluate_real(origin,p_icp_abs,tracks,dir,[1,2,3,4]);
disp(mean(xy));
disp(mean(dz));

%% show reconstruction
figure; pcshow(p_icp_abs,color);
xlabel("X East [m]");
ylabel("Y North [m]");
zlabel("Z elevation [m]");



% %% Save?
% save_dir='large_results\Real\oeste_2\';
% formatOut = 30;
% d=datestr(now, formatOut);
% save(strcat(save_dir,d));
% str = input("Do you want to save result (y/n)?\n",'s');
%
% if str=="y"
%     formatOut = 30;
%     d=datestr(now, formatOut);
%     save(save_dir);
% end