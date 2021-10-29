function [pcloud,t,s] = xyz_transform(...
    xyzPoints,camPoses,abspos,heading,pitch,input_s)
%blender_xyz_transform Transform a point cloud and a trajectory into
% world coordinates

%% transform abspos into relative pos to first point (not in Z tho)
ttrue=abspos;
ttrue(:,1:2)=ttrue(:,1:2)-ttrue(1,1:2);
%% Compute the estimated trajectory
if ~isempty(camPoses)
    t=getEstimatedTraj(camPoses);
end
%% transform with pitch (p and t)
% p=deg2rad(pitch(1)-180);
p=deg2rad(180-pitch(1));

tform= affine3d(axang2tform([1 0 0 p]));
pcloud = pctransform(pointCloud(xyzPoints),tform);
if ~isempty(camPoses)
    t=transformPointsForward(tform,t);
end
%% transform with heading
head=deg2rad(heading(1)); %heading
tform= affine3d(axang2tform([0 0 1 head]));
pcloud = pctransform(pcloud,tform);
if ~isempty(camPoses)
    t=transformPointsForward(tform,t);
end
%% Scale point cloud and trajectory
if input_s==0
    s=getScaleFactor(ttrue,t,pcloud,"distanceRatio");
else
    s=input_s;
end

tform = affine3d([s 0 0 0; 0 s 0 0; 0 0 s 0; 0 0 0 1]);
pcloud=pctransform(pcloud,tform);
if ~isempty(camPoses)
    t=transformPointsForward(tform,t);
end
%% Sum UAV altitude
tform=affine3d([eye(3,4);[0 0 ttrue(1,3) 1]]);
pcloud=pctransform(pcloud,tform);
if ~isempty(camPoses)
    t=transformPointsForward(tform,t);
else
    t=0;
end



end

