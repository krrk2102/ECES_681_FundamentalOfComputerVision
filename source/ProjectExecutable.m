clear;

% Following variables keeps track of comparsion results. 
% This matrix contains all matching percentage information among every
% fingerprint and every image in database.
percent = zeros(5, 10);
% This vector records the maximum matching percentage of each input
% fingerprints among images most fit in the database.
maxPercent = zeros(1, 5);
% This vector records the best fit index of image in the database to the
% input fingerprint image. 
match = zeros(1, 5);

% Run all the images to be recognized. 
for i = 1 : 5
    
    distorted = imread(['image/FP',num2str(i), '.png']);
    distorted = rgb2gray(distorted);
    
    % For each fingerprints, compare it to all images in database.
    for j = 1 : 10
        
        original = imread(['image/', num2str(j, '%02i'), '.png']);
        percent(i, j) = FpCompare(original, distorted);
        
        % Record current best match to the unrecognized fingerprints.
        if percent(i, j) > maxPercent(1, i)
            maxPercent(1, i) = percent(i, j);
            match(1, i) = j;
        end
    end
    
end