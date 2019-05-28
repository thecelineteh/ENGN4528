function [MOVINGREG, TBetter] = FindBetterCorrespondences(MOVING,FIXED)
%registerImages  Register grayscale images using auto-generated code from Registration Estimator app.
%  [MOVINGREG] = registerImages(MOVING,FIXED) Register grayscale images
%  MOVING and FIXED using auto-generated code from the Registration
%  Estimator app. The values for all registration parameters were set
%  interactively in the app and result in the registered image stored in the
%  structure array MOVINGREG.

% Auto-generated by registrationEstimator app on 26-May-2019
%-----------------------------------------------------------


% Feature-based techniques require license to Computer Vision Toolbox
% checkLicense()

% Convert RGB images to grayscale
FIXED = rgb2gray(FIXED);
MOVING = rgb2gray(MOVING);

FIXED(1:65,1:65) = 0;
FIXED(1:50,320:end) = 0;
FIXED(260:end,422:end) = 0;

MOVING(1:65,1:65) = 0;
MOVING(1:50,320:end) = 0;
MOVING(260:end,422:end) = 0;

% Default spatial referencing objects
fixedRefObj = imref2d(size(FIXED));
movingRefObj = imref2d(size(MOVING));

% Detect SURF features
fixedPoints = detectSURFFeatures(FIXED,'MetricThreshold',750.000000,'NumOctaves',3,'NumScaleLevels',5);
movingPoints = detectSURFFeatures(MOVING,'MetricThreshold',750.000000,'NumOctaves',3,'NumScaleLevels',5);

% Extract features
[fixedFeatures,fixedValidPoints] = extractFeatures(FIXED,fixedPoints,'Upright',true);
[movingFeatures,movingValidPoints] = extractFeatures(MOVING,movingPoints,'Upright',true);

% Match features
indexPairs = matchFeatures(fixedFeatures,movingFeatures,'MatchThreshold',21.944444,'MaxRatio',0.219444);
fixedMatchedPoints = fixedValidPoints(indexPairs(:,1));
movingMatchedPoints = movingValidPoints(indexPairs(:,2));
MOVINGREG.FixedMatchedFeatures = fixedMatchedPoints;
MOVINGREG.MovingMatchedFeatures = movingMatchedPoints;

TBetter = NaN;
MOVINGREG.Transformation = NaN;

% Apply transformation - Results may not be identical between runs because of the randomized nature of the algorithm
try
tform = estimateGeometricTransform(movingMatchedPoints,fixedMatchedPoints,'similarity');
MOVINGREG.Transformation = tform;
MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true);
TBetter = tform.T;

points = movingMatchedPoints.Location - fixedMatchedPoints.Location;

points = points(points(:,1) > 0,:);

sampleSize = 2; % number of points to sample per trial
maxDistance = 2; % max allowable distance for inliers

fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); % fit function using polyfit
evalLineFcn = ...   % distance evaluation function
    @(model, points) sum((points(:, 2) - polyval(model, points(:,1))).^2,2);

[~, inlierIdx] = ransac(points,fitLineFcn,evalLineFcn, ...
    sampleSize,maxDistance);

out = mean(points(inlierIdx, :), 1);


TBetter(3,1) = out(1);
TBetter(3,2) = out(2);
catch
    TBetter(3,1) = 0;
    TBetter(3,2) = 0;
end

% Store spatial referencing object
MOVINGREG.SpatialRefObj = fixedRefObj;



end

