function [vSet] = motion_estimation(intrinsics,images,detector,features_per_image)
%MOTION_ESTIMATION Returns the view set with normalized camera motion
%   Detailed explanation goes here


%I =images{1};
I=undistortImage(images{1},intrinsics);
% Detect features
if detector=="SURF"
    border = 50;
    roi = [border, border, size(I, 2)- 2*border, size(I, 1)- 2*border];
    prevPoints   = detectSURFFeatures(I, 'NumOctaves', 8, 'ROI', roi);
elseif detector=="KAZE"
        prevPoints   = selectStrongest(detectKAZEFeatures(I),features_per_image);
elseif detector=="ORB"
        prevPoints   = selectStrongest(detectORBFeatures(I),features_per_image);
end

% Extract features. Using 'Upright' features improves matching, as long as
% the camera motion involves little or no in-plane rotation.
prevFeatures = extractFeatures(I, prevPoints);

% Create an empty imageviewset object to manage the data associated with each
% view.
vSet = imageviewset;

% Add the first view. Place the camera associated with the first view
% and the origin, oriented along the Z-axis.
viewId = 1;
vSet = addView(vSet, viewId, rigid3d, 'Points', prevPoints);

for i = 2:numel(images)
    % Select image
    %I=images{i};
    I=undistortImage(images{i},intrinsics);
    % Detect features
    if detector=="SURF"
        currPoints   = detectSURFFeatures(I, 'NumOctaves', 8, 'ROI', roi);
        
    elseif detector=="KAZE"
        currPoints   = selectStrongest(detectKAZEFeatures(I),features_per_image);
    elseif detector=="ORB"
        currPoints   = selectStrongest(detectORBFeatures(I),features_per_image);
    end
    
   
    % extract and match features.
    currFeatures = extractFeatures(I, currPoints);
    indexPairs   = matchFeatures(prevFeatures, currFeatures);
    
    % Select only matched points.
    matchedPoints1 = prevPoints(indexPairs(:, 1));
    matchedPoints2 = currPoints(indexPairs(:, 2));
    
    % Estimate the camera pose of current view relative to the previous view.
    % The pose is computed up to scale, meaning that the distance between
    % the cameras in the previous view and the current view is set to 1.
    % This will be corrected by the bundle adjustment.
    [relativeOrient, relativeLoc, inlierIdx] = EstimateRelativePose(...
        matchedPoints1, matchedPoints2, intrinsics);
    
    % Get the table containing the previous camera pose.
    prevPose = poses(vSet, i-1).AbsolutePose;
    relPose  = rigid3d(relativeOrient, relativeLoc);
    
    % Compute the current camera pose in the global coordinate system
    % relative to the first view.
    currPose = rigid3d(relPose.T * prevPose.T);
    
    % Add the current view to the view set.
    vSet = addView(vSet, i, currPose, 'Points', currPoints);
    
    % Store the point matches between the previous and the current views.
    vSet = addConnection(vSet, i-1, i, relPose, 'Matches', indexPairs(inlierIdx,:));
    
   
    
    prevFeatures = currFeatures;
    prevPoints   = currPoints;
end
 % Find point tracks across all views.
    tracks = findTracks(vSet);
    
    % Get the table containing camera poses for all views.
    camPoses = poses(vSet);
    

     % Triangulate initial locations for the 3-D world points.
    [xyzPoints,reprojectionErrors] = triangulateMultiview(tracks, camPoses, intrinsics);
    
    % remove high error points  
    mask=reprojectionErrors<5;
    tracks=tracks(mask);
    xyzPoints=xyzPoints(mask,:);
    
    % Refine the 3-D world points and camera poses.
    [xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(xyzPoints, ...
        tracks, camPoses, intrinsics, 'FixedViewId', 1);
 
    % Store the refined camera poses.
    vSet = updateView(vSet, camPoses);
% % Show result
% cams=zeros(size(camPoses,1),3);
% for i=1:size(camPoses,1)
%     cams(i,:)=camPoses.AbsolutePose(i).Translation;
% end
% figure;plot3(cams(:,1),cams(:,2),cams(:,3),'ko--');

end

