function [xy,dz] = geo_evaluate_real(origin,points,tracks,dir,targets)
xy=zeros(size(targets));
dz=zeros(size(targets));
for i=targets
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
end

end

