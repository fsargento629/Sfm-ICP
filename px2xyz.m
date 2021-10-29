function  xyz_est=px2xyz(p,tracks,id,pxin,method)

if method=="closest"
    [px,~,xyz_est]=getPixelsFromTrack(tracks,id,p);
    D=sqrt((pxin(1)-px(:,1)).^2 + (pxin(2)-px(:,2)).^2);
    [~,idx]=mink(D,1);
    xyz_est=xyz_est(idx,:);
    
elseif method=="5closest"
    [px,~,xyz_est]=getPixelsFromTrack(tracks,id,p);
    D=sqrt((pxin(1)-px(:,1)).^2 + (pxin(2)-px(:,2)).^2);
    [~,idx]=mink(D,5);
    xyz_est=mean(xyz_est(idx,:));
elseif method=="10closest"
    [px,~,xyz_est]=getPixelsFromTrack(tracks,id,p);
    D=sqrt((pxin(1)-px(:,1)).^2 + (pxin(2)-px(:,2)).^2);
    [~,idx]=mink(D,10);
    xyz_est=mean(xyz_est(idx,:));
elseif method=="10idw"
    [px,~,xyz_est]=getPixelsFromTrack(tracks,id,p);
    D=sqrt((pxin(1)-px(:,1)).^2 + (pxin(2)-px(:,2)).^2);
    [~,idx]=mink(D,10);
    d=D(idx); xyz_est=xyz_est(idx,:);
    w=d.^-2;
    w=w./sum(w);
    xyz_est=w'*xyz_est;
elseif method=="5idw"
    [px,~,xyz_est]=getPixelsFromTrack(tracks,id,p);
    D=sqrt((pxin(1)-px(:,1)).^2 + (pxin(2)-px(:,2)).^2);
    [~,idx]=mink(D,5);
    d=D(idx); xyz_est=xyz_est(idx,:);
    w=d.^-2;
    w=w./sum(w);
    xyz_est=w'*xyz_est;
end

end

