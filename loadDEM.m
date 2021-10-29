function [DEM,A,R] = loadDEM(scene,origin)
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

DEM=pointCloud(XYZ); % not using interpolation
end

