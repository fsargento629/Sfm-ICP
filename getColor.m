function [color] = getColor(tracks,images,N)
%getColor(tracks,images,points) Return color matrix for the 3D points
%   color is Mx3
color=zeros(N,3);

% get rgb color for each point
for i=1:size(color,1)
    I=images{tracks(i).ViewIds(1)};
    px=tracks(i).Points(1,:); px=round(px);  
    if px(1)>size(I,2)
        px(1)=size(I,2);
    end
    if px(2)>size(I,1)
        px(2)=size(I,1);
    end
    if px(1)<=0
        px(1)=1;
    end
    if px(2)<=0
        px(2)=1;
    end
    color(i,:)=I(px(2),px(1),:);
   
end
color=uint8(color);
end

