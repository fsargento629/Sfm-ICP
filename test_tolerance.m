function ers = test_tolerance(origin,dataset_name,tracks,... 
    abspos,p,gps,alt,delta,phi,scene)
ers=zeros(1,4);
%% insert noise in p and abspos
rot=axang2rotm([1 0 0 deg2rad(delta)]);
rot=axang2rotm([0 0 1 deg2rad(phi)])*rot;
p_noisy=p*rot;
p_noisy=p_noisy+[0,0,alt];
abspos_noisy=abspos+[gps,gps,0];

% register the two pcls
%[tform,picp,rmse]=pcregistercpd(pidw,dem);
[~,tform,~]=blender_ICP(p_noisy,abspos_noisy,origin,scene);
[xy,dz]=geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,0,false);
ers(1:2)=[xy,dz];
[xy,dz]=geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,tform,false);
ers(3:4)=[xy,dz];

end
