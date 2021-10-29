function [world_ang,rel_ang] = getAngles(vSet,heading,pitch)
%getAngles Get the estimated angles from the view set

% get the orientation for each view
camPoses=vSet.poses;
pose=camPoses.AbsolutePose(:);
yaw=zeros(size(pose,1),1);
roll=yaw; p=roll;
for i=1:size(pose,1)
    % angles are as yaw pitch roll
    [yaw(i), p(i), roll(i)]=dcm2angle(pose(i).Rotation);
end
yaw=rad2deg(yaw); roll=rad2deg(roll);p=rad2deg(p);
rel_ang=[yaw p roll];



% Sum the true angle values of the first view
world_ang=rel_ang+[heading(1), -pitch(1), 0];

end

