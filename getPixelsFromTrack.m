function [px,small_tracks,small_p] = getPixelsFromTrack(tracks,id,p)
%getPixelsFromTrack Returns all the pixels from a view
px=zeros(size(tracks,2),2);
for i=1:size(tracks,2)
    mask=tracks(i).ViewIds==id;
    if sum(mask)~=0
        px(i,:)=tracks(i).Points(mask,:);
    end
end
mask=px(:,1)~=0;
px=px(mask,:);
small_tracks=tracks(mask);
if p~=0
    small_p=p(mask,:);
end
end

