function [xyzPoints, camPoses, reprojectionErrors,tracks] = dense_constructor_LKT(intrinsics,images,constructor,vSet)
%DENSE_CONSTRUCTOR extract points and construct a large dense pointcloud
%   Detailed explanation goes here

% Read the first image
%I = images{1};
I=undistortImage(images{1},intrinsics);
% Detect corners in the first image.
prevPoints=extractPoints(I,constructor);

% Create th e point tracker object to track the points across views.
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 6);

% Initialize the point tracker.
prevPoints = prevPoints.Location;
initialize(tracker, prevPoints, I);

% Store the dense points in the view set.

vSet = updateConnection(vSet, 1, 2, 'Matches', zeros(0, 2));
vSet = updateView(vSet, 1, 'Points', prevPoints);

% Track the points across all views.
for i = 2:numel(images)
    % Read and undistort the current image.
    %I=images{i}; 
    I=undistortImage(images{i},intrinsics);
    % Track the points.
    [currPoints, validIdx] = step(tracker, I);
       
    
    % Clear the old matches between the points.
    if i < numel(images)
        vSet = updateConnection(vSet, i, i+1, 'Matches', zeros(0, 2));
    end
    vSet = updateView(vSet, i, 'Points', currPoints);
    
    % Store the point matches in the view set.
    matches = repmat((1:size(prevPoints, 1))', [1, 2]);
    matches = matches(validIdx, :);        
    vSet = updateConnection(vSet, i-1, i, 'Matches', matches);
end

% Find point tracks across all views.
tracks = findTracks(vSet);

% Find point tracks across all views.
camPoses = poses(vSet);

% Triangulate initial locations for the 3-D world points.
[xyzPoints,reprojectionErrors] = triangulateMultiview(tracks, camPoses,...
    intrinsics);
mask=reprojectionErrors<5;
xyzPoints=xyzPoints(mask,:);
tracks=tracks(mask);

% Refine the 3-D world points and camera poses.
[xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(...
   xyzPoints, tracks, camPoses, intrinsics, 'FixedViewId', 1);


end

