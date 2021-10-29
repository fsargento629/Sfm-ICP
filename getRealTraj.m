function cam_pos = getRealTraj(gps,altitude)
%GETREALTRAJ Summary of this function goes here
%   Detailed explanation goes here
origin = [gps(1,1), gps(1,2), altitude(1)];
[cam_x,cam_y] = latlon2local(gps(:,1),gps(:,2),altitude,origin);
cam_z=altitude;
cam_pos=[cam_x cam_y cam_z];
end

