%% evaluate uavision
N=9;
res_dir="large_results\Real\pombal_3\";
mean_ers=zeros(N,2);
xys=zeros(N,4);
dzs=zeros(N,4);
for i=1:N
    load(strcat(res_dir,int2str(i)),'xy','dz');
    % evaluate
    mean_ers(i,:)=[mean(xy(1:4)),mean(abs(dz(1:4)))];
    xys(i,:)=xy(1:4);
    dzs(i,:)=abs(dz(1:4));
end

% show mean errors
figure; scatter(mean_ers(:,1),mean_ers(:,2));
xlabel("XY error [m]"); ylabel("Z error [m]");
title("Mean georeferencing errors with the UAVision dataset for 9 algorithm runs");

% show all targets (xy)
figure;
boxplot(xys,["Target 1","Target 2","Target 3","Target 4"]);
title("XY georeferencing error distribution for 4 targets");
xlabel("Target");
ylabel("XY error [m]");

% show all targets (dz)
figure;
boxplot(dzs,["Target 1","Target 2","Target 3","Target 4"]);
title("Z georeferencing error distribution for 4 targets");
xlabel("Target");
ylabel("Z error [m]");



%% show target in image with points near it
load("large_results\Real\pombal_3\9");
i=5; % target number7id
points=p_icp_abs;

% geo_evaluate_rel.m loop
fprintf("--------- Target %d ---------\n",i);
load(strcat(dir,"/target_",int2str(i)));
target_xyz=px2xyz(points,tracks,1,px,'10idw');
[actual_x,actual_y,~]=...
    latlon2local(target_gps(1),target_gps(2),target_gps(3),origin);
actual_z=target_gps(3);
xy(i)=sqrt( (target_xyz(1)-actual_x)^2 + (target_xyz(2)-actual_y)^2 );
dz(i)=target_xyz(3)-actual_z;
fprintf("XY error: %.2f\n",xy(i));
fprintf("Z error: %.2f\n",dz(i));

% find nearby points
[pxs,~,xyz_est]=getPixelsFromTrack(tracks,1,points);
D=sqrt((px(1)-pxs(:,1)).^2 + (px(2)-pxs(:,2)).^2);
[~,idx]=mink(D,10);
bad_pxs=pxs(setdiff(1:end,idx),:);
pxs=pxs(idx,:);

% show image 1, px of target and nearby points
figure;
imshow(color_images{1}); hold on,
scatter(px(1),px(2),300,'kx'); hold on;
scatter(pxs(:,1),pxs(:,2),50,'g*');  hold on;
scatter(bad_pxs(:,1),bad_pxs(:,2),50,'r*');
title("Target and nearby features extracted");
legend("Target","10 closest features","Other features");

%% show ICP
load("large_results\Real\pombal_3\9",'p','p_icp_abs','origin');
load("DEMs/pombal_DEM.mat");

% dem 2 pcl
[c_origin,l_origin] = geographicToIntrinsic(R,origin(1),origin(2));
X= ((1:R.RasterSize(2))-c_origin )* x_res; % WEST-EAST
Y=( (-1:-1:-R.RasterSize(1)) + l_origin )*y_res; % NORTH-SOUTH
% convert matrix to pcl
C=size(X,2); L=size(Y,2);
XYZ=zeros(C*L,3);
i=1;
for l=1:L
    for c=1:C
        XYZ(i,:)=[X(c),Y(l),A(l,c)];
        i=i+1;
    end
end

% show
pcshow(p,'r','MarkerSize',20); hold on;
pcshow(p_icp_abs,'g','MarkerSize',20);hold on;
pcshow(XYZ,'k','MarkerSize',20);
axis equal; set(gca,'visible','off');
legend1=legend("Before ICP","After ICP","DEM");
set(legend1,...
    'Position',[0.819279764746359 -0.00357143878936745 0.196428568288684 0.126190472784497],...
    'Color',[1 1 1]);
xlabel("X East [m]"); ylabel("Y North [m]"); zlabel("Z Up [m]");
xlim([200,1500]);
ylim([350,2000]);
title("Reconstruction before and after ICP");

%% SURF and KLT features
load("large_results\Real\pombal_3\9",'tracks','color_images','images','p');
% SURF
border = 50;
I=images{1};
roi = [border, border, size(I, 2)- 2*border, size(I, 1)- 2*border];
t=detectSURFFeatures(I, 'NumOctaves', 8, 'ROI', roi); pxs=t.Location;
figure;
imshow(color_images{1}); hold on; scatter(pxs(:,1),pxs(:,2),20,'r+');
title("Features extracted by SURF");
% KLT
[pxs,~,~]=getPixelsFromTrack(tracks,1,p);
figure;
imshow(color_images{1}); hold on; scatter(pxs(:,1),pxs(:,2),10,'r+');
title("Features tracked by the KLT");
