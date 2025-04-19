coinImages = {"testCoinImage1.png","testCoinImage2.png","testCoinImage3.png"};
BW = cell(1, numel(coinImages));
maskedImages = cell(1, numel(coinImages));
coinImgEdges = cell(1, numel(maskedImages));
erodedMasks = cell(1, numel(maskedImages));
faceEdgeMask = cell(1, numel(maskedImages));
expandedEdgeMasks = cell(1, numel(maskedImages));
fusedPairs = cell(1, numel(expandedEdgeMasks));
validRegions = cell(1, numel(expandedEdgeMasks));
nDimes = cell(1, numel(expandedEdgeMasks));
nNickels = cell(1, numel(expandedEdgeMasks));
nQuarters = cell(1, numel(expandedEdgeMasks));
nFiftyCents = cell(1, numel(expandedEdgeMasks));
USD = cell(1, numel(expandedEdgeMasks));


for k = 1:numel(coinImages)
    coinImg = imread(coinImages{k});
    filteredCoinImg = imgaussfilt(coinImg);
    [BW{k}, maskedImages{k}] = segmentCoins(filteredCoinImg);
    coinImgEdges{k} = edge(maskedImages{k}, "sobel", "nothinning");
    erodedMasks{k} = imerode(maskedImages{k}, strel('disk', 16));
    faceEdgeMask{k} = coinImgEdges{k} & erodedMasks{k};
    expandedEdgeMasks{k} = imdilate(faceEdgeMask{k}, strel('disk', 28));
    fusedPairs{k} = imfuse(expandedEdgeMasks{k}, BW{k});
    validRegions{k} = expandedEdgeMasks{k} & BW{k};
    nDimes{k} = bwpropfilt(validRegions{k}, 'Area',[4000, 5000]);
    nDimes{k} = length(regionprops(nDimes{k}));
    nNickels{k} = bwpropfilt(validRegions{k}, 'Area',[5000, 7000]);
    nNickels{k} = length(regionprops(nNickels{k}));
    nQuarters{k} = bwpropfilt(validRegions{k}, 'Area',[7000, 9000]);
    nQuarters{k} = length(regionprops(nQuarters{k}));
    nFiftyCents{k} = bwpropfilt(validRegions{k}, 'Area',[10000, 13000]);
    nFiftyCents{k} = length(regionprops(nFiftyCents{k}));
    USD{k} = nDimes{k}*0.10 + nNickels{k}*0.05 + nQuarters{k}*0.25 + nFiftyCents{k}*0.50;
end

allsteps = cat(4, BW, maskedImages, coinImgEdges, erodedMasks, faceEdgeMask, expandedEdgeMasks, fusedPairs, validRegions);
montage(allsteps, "Size", [8 3]);
title('Image Processing, Filtering, & Region Analysis: 3 Test Coin Images')
numCoinsInImgs = table(nDimes, nNickels, nQuarters, nFiftyCents, USD);
save('NumberOfCoinsInImgs.mat',"numCoinsInImgs");