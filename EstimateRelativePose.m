function [orientation, location, inlierIdx] = ...
    EstimateRelativePose(matchedPoints1, matchedPoints2, cameraParams)
%EstimateRelativePose return the relative orientation and location
% of the 2nd camera relative to the first 
%   Detailed explanation goes here

%[F,inlierIdx]=estimateFundamentalMatrix(matchedPoints1,matchedPoints2);
[E,inlierIdx]=estimateEssentialMatrix(matchedPoints1,matchedPoints2,cameraParams);
% fprintf("Inlier ratio");
% disp(sum(inlierIdx)/size(inlierIdx,1));

% Get the epipolar inliers.
inlierPoints1 = matchedPoints1(inlierIdx, :);
inlierPoints2 = matchedPoints2(inlierIdx, :);

[orientation, location, validPointFraction] = ...
        relativeCameraPose(E, cameraParams, inlierPoints1(1:end, :),...
        inlierPoints2(1:end, :));

end

