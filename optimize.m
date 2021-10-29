n=20;
xys=zeros(n,1);
dzs=zeros(n,1);
rmses=zeros(n,1);
mres=zeros(n,1);
sizes=zeros(n,1);
for i=1:n
    load(strcat("res/",int2str(i)),'p','origin','scene','tracks','dir','reprojectionErrors');
    [rmse,tform,p_icp_abs] = ICP(p,[0,0,0],origin(1:2),scene);
    sizes(i)=size(p,1);
    rmses(i)=rmse;
    mres(i)=mean(reprojectionErrors);
    % evaluate
    [xy,dz]=geo_evaluate_real(origin,p_icp_abs,tracks,dir,[1,2,3,4]);
    xys(i)=mean(xy);
    dzs(i)=mean(dz);
    %disp(mean(xy));
    %disp(mean(dz));
    disp(i);
    fprintf("---\n");
end

fprintf("END\n");
disp(mean(xys));
disp(mean(abs(dzs)));

%% xys and dz
scatter(xys,abs(dzs));

%% mre and rmse
scatter(mres,rmses)
%% mre and xys
scatter(mres,xys);
%% rmse and xys
scatter(rmses,xys);
%% size and xys
scatter(sizes,xys);

%% filter out
idx=mres<.7 & rmses<4.5 & sizes>4500;
xysf=xys(idx);
dzsf=abs(dzs(idx));
disp(mean(xysf)); disp(mean(dzsf));