function [cams] = getEstimatedTraj(camPoses)
cams=zeros(size(camPoses,1),3);
for i=1:size(camPoses,1)
    cams(i,:)=camPoses.AbsolutePose(i).Translation;
end
end

