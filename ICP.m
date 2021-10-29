function [rmse,tform,p_icp_abs] = ICP(p,abspos,origin,scene)

%% load real DEM
if scene=="archeira"
    load("DEMs/archeira_DEM.mat"); %A,R,x_res,y_res
elseif scene=="Vila_real"
    load("DEMs/Vila_real_DEM.mat"); %A,R,x_res,y_res
elseif scene=="pombal"
    load("DEMs/pombal_DEM.mat"); %A,R,x_res,y_res
elseif scene=="oeste"
    load("DEMs/oeste_DEM.mat"); %A,R,x_res,y_res
end

%% load ICP parameters

inlier_ratio=.5;
maxIterations=150;
gridstep=2;



%% DEM to pcl
% make X and Y vectors
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

%DEM=pointCloud(XYZ); % not using interpolation

%% interpolate DEM to create a denser fixed pcl
x_inter=5;
y_inter=5;
F1 = scatteredInterpolant(XYZ(:,1),XYZ(:,2),XYZ(:,3));
[xq,yq] = ndgrid(min(XYZ(:,1)):x_inter:max(XYZ(:,1)),...
    min(XYZ(:,2)):y_inter:max(XYZ(:,2)));
vq1 = F1(xq,yq);
% turn matrices into pcl
N=numel(vq1);
XYZ=zeros(N,3);
XYZ(:,1)=reshape(xq,1,[]);
XYZ(:,2)=reshape(yq,1,[]);
XYZ(:,3)=reshape(vq1,1,[]);
DEM=pointCloud(XYZ);

%% register p to dem
p_abs=p+[abspos(1,1:2),0];
pidw=pointCloud(p_abs);
pidw=pcdownsample(pidw,'gridAverage',gridstep);
[tform,~,rmse]=pcregistericp(pidw,DEM,'Metric','PointToPlane',...
    'Extrapolate',true,...
    'InlierRatio',inlier_ratio,'MaxIterations',maxIterations,'Verbose',false);
% transform p and return
p_icp_abs=transformPointsForward(tform,p_abs);

% evaluate
%[xy,dz]=geoEvaluate(abspos,p,tracks,dataset_name,tform,false)





end

