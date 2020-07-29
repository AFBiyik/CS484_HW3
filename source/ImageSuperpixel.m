% Author: Ahmet Furkan Biyik
% ID: 21501084
% Date: 11.12.2019

classdef ImageSuperpixel
    %ImageSuperpixel for segmenting an image.
    %   Constructors: ImageSuperpixel() : Default constructor.
    %                 ImageSuperpixel(path) : Reads image from path.
    %   Methods: mergePixels(type) : Merges superpixels with feature type.
    %            resetPixels() : reset labelMatrix and numLabels to original
    %            showImage() : Shows image and labels.
    %            showGaborResult() : Shows Gabor results.
    
    properties (Constant)
        gaborBank = ImageSuperpixel.createGaborBank(); % constant static gaborbank creation
        numPixels = 1500; % number of superpixels
        threshold = 0.065; % threshold value for merging
    end
    
    properties
        image; % rgb image
        mag; % Gabor result
        labelMatrix; % label matrix (it can change with merging)
        numLabels; % number of created labels (it can change with merging)
        orgLabelMatrix; % original label matrix
        orgNumLabels; % original number of created labels
        labels; % Label object array
        gaborFeatures;
        rgbFeatures;
        combinedFeatures;
    end
    
    methods
        function obj = ImageSuperpixel(path)
            %ImageSuperpixel(path) Construct an instance of this class
            %   obj = ImageSuperpixel() Default constructor.
            %   obj = ImageSuperpixel(path) Reads image in path.
            if nargin == 1
                obj.image = imread(path); % read image
                [obj.orgLabelMatrix, obj.orgNumLabels] = slicomex(obj.image, ImageSuperpixel.numPixels); % segmentation using slico
                gray = rgb2gray( obj.image ); % gray image for Gabor
                obj.mag = imgaborfilt(gray, ImageSuperpixel.gaborBank); % gabor result
                obj = obj.resetPixels(); % reset labelMatrix and numLabels
            end
        end
        
        function obj = resetPixels(obj)
            %resetPixels() reset labelMatrix and numLabels to original
            %   obj = obj.resetPixels();
            obj.labelMatrix = obj.orgLabelMatrix;
            obj.numLabels = obj.orgNumLabels;
        end
        
        function obj = mergePixels(obj, type) % entry point for merge
            %mergePixels(type)
            %   obj = obj.mergePixels(type)
            %   type can be 1,2,3.
            %   1 for Gabor merging.
            %   2 for color merging.
            %   3 for combined merging
            obj = obj.resetPixels(); 
            obj = obj.mergeRec(type); % call recursive function
        end
        
        function showImage(obj)
            %showImage() Shows image and labels.
            %   obj.showImage();
            
            L = labeloverlay(obj.image, obj.labelMatrix,'Transparency',0.7);
            figure;
            imshow(L);
            
        end
        
        function showGaborResult(obj)
            %showGaborResult(obj) Shows Gabor results.
            %   obj.showGaborResult();
            
            % figure('Position', get(0, 'Screensize')); % fulsize
            it = 0; % subplot position
            
            for i = 1 : size(obj.mag, 3)

                subplot(12,16,[1+it,2+it,3+it,17+it,18+it,19+it,33+it,34+it,35+it]);
                
                % normalize mag to graycolor image
                A = obj.mag(:,:,i);
                normA = A - min(A(:));
                normA = (normA ./ max(normA(:)));
                imshow(normA, 'Border','tight');
                title('Output');
                ax = gca;
                ax.FontSize = 6;
                
                % show Gabor filter
                subplot(12,16,[4+it,20+it,36+it]);
                imshow(real(ImageSuperpixel.gaborBank(i).SpatialKernel), 'Border','tight') ;
                title( sprintf('Wavelength : %d\nOrientation: %d',...
                    ImageSuperpixel.gaborBank(i).Wavelength, ...
                    ImageSuperpixel.gaborBank(i).Orientation));
                ax = gca;
                ax.FontSize = 6;
                
                it = it + 4; % next subplot position
                if mod(i,4) == 0
                   it = it + 32; 
                end
            end 
            
        end
    end
    
    methods (Access = private)
        function obj = initFeatures(obj, type)
            %initFeatures(type) initialize features of each superpixel with type
            %   obj = obj.initFeatures(type);
            %   type can be 1,2,3.
            %   1 for Gabor merging.
            %   2 for color merging.
            %   3 for combined merging
            
            % Gabor or combined
            if type == 1 || type == 3
                obj = obj.initGaborFeatures();
            end
            % color or combined
            if type == 2 || type == 3
                obj = obj.initRGBFeatures();
            end
            % combined
            if type == 3
                obj.combinedFeatures = vertcat(obj.rgbFeatures, obj.gaborFeatures);
            end
        end
        
        function obj = initGaborFeatures(obj)
            %initGaborFeatures() initialize Gabor features
            
            % create zero matrix
            obj.gaborFeatures = zeros(size(ImageSuperpixel.gaborBank,2), obj.numLabels);
            
            % for each Gabor filter
            for i = 1 : size(ImageSuperpixel.gaborBank,2)
                % for each superpixel
                for j = 1 : obj.numLabels
                    gaborArray = zeros(1, size(obj.labels(j).rows, 1)); % to calculate mean
                    
                    for k = 1 : size(obj.labels(j).rows, 1)
                        gaborArray(k) = obj.mag(obj.labels(j).rows(k), obj.labels(j).cols(k), i);
                    end
                    
                    obj.gaborFeatures(i, j) = mean(gaborArray);
                end
            end
            
            obj.gaborFeatures = ImageSuperpixel.normalizeRows(obj.gaborFeatures); % normalize values
        end
        
        function obj = initRGBFeatures(obj)
            %initRGBFeatures() initialize color features
            
            % create zero matrix
            obj.rgbFeatures = zeros(3, obj.numLabels);
            
            % for each color band 1 red, 2 green, 3 blue
            for i = 1 : 3
                for j = 1 : obj.numLabels
                    rgbArray = zeros(1, size(obj.labels(j).rows, 1)); % to calculate mean
                    
                    % for each superpixel
                    for k = 1 : size(obj.labels(j).rows, 1)
                        rgbArray(k) = obj.image(obj.labels(j).rows(k), obj.labels(j).cols(k), i);
                    end
                    
                    obj.rgbFeatures(i, j) = mean(rgbArray);
                end
            end
            
            obj.rgbFeatures = ImageSuperpixel.normalizeRows(obj.rgbFeatures); % normalize values
        end
        
        function obj = mergeRec(obj, type)
            %mergeRec(type) recursive merge function. 
            %   obj = obj.mergeRec(type)
            %   It calls itsel until no superpixel can merge.
            %   type can be 1,2,3.
            %   1 for Gabor merging.
            %   2 for color merging.
            %   3 for combined merging
            
            % create label array
            labelArray(1, obj.numLabels) = Label;
            
            % calculate neighbors
            % left
            glcms1 = graycomatrix(obj.labelMatrix,'NumLevels',obj.numLabels, 'GrayLimits',[], 'Offset', [1 0], 'Symmetric', true );
            % down
            glcms2 = graycomatrix(obj.labelMatrix,'NumLevels',obj.numLabels, 'GrayLimits',[], 'Offset', [0 1], 'Symmetric', true );
            glcms = glcms1 + glcms2; % combine left and down
            
            for i = 0 : obj.numLabels - 1
               
                % find rows and cols
                [row, col] = find(obj.labelMatrix == i);
                labelArray(i + 1).rows = row;
                labelArray(i + 1).cols = col;
                
                % find neighbor superpixels
                neighborRow = glcms(i + 1,:);
                neighborRow(i + 1) = 0;
                labelArray(i + 1).neighbors = find( neighborRow > 0) - 1;
            end
            
            % set labels
            obj.labels = labelArray;
            
            % initialize features
            obj = obj.initFeatures(type);
            
            % set pixel map to keep track of merging pixels
            pixelMap = -ones(1,obj.numLabels);
            
            % set features
            if type == 1
                features = obj.gaborFeatures;
            elseif type == 2
                features = obj.rgbFeatures;
            else
                features = obj.combinedFeatures;
            end
            
            % for each superpixel
            for i = 0 : obj.numLabels - 1
                
                neighbors = obj.labels(i + 1).neighbors;
                
                % for each nieghbor
                for j = 1 : size(neighbors, 2)
                    
                    if neighbors(j) < i % not to combine two times
                        s = sum((features(:, i + 1) - features( :, neighbors(j) + 1)).^2);
                        
                        % if can merge
                        if (s < ImageSuperpixel.threshold)
                            pixelMap(i + 1) = neighbors(j);
                            break;
                        end
                    end
                end
            end
            
            % if changed
            if size(find(pixelMap > -1),2) > 0
            
                % from last to first label change label ids
                for i = obj.numLabels - 1 : -1 : 0
                    
                    if pixelMap(i + 1) > -1
                   
                        [row, col] = find( obj.labelMatrix == i );

                        for j = 1 : size(row, 1)
                            obj.labelMatrix(row(j), col(j)) = pixelMap(i + 1) ;
                        end

                    end
                end
                
                % set label values consecutively
                currentLabel = 0;
                for i = 0 : obj.numLabels - 1
                    
                    [row, col] = find( obj.labelMatrix == i );

                    if size(row, 1) > 0
                        for j = 1 : size(row, 1)
                            obj.labelMatrix(row(j), col(j)) = currentLabel;
                        end
                        currentLabel = currentLabel + 1;
                    end
                end
                obj.numLabels = currentLabel;
                
                % recursive call
                obj = obj.mergeRec(type);
            end
            
        end
        
    end
    
    methods (Static)
        function g = createGaborBank()
            %createGaborBank() static function
            %   g = createGaborBank();
            %   Creates gabor filter bank with wavelength 2, 4, 8, 16 and
            %   oriantations 0, 45, 90, 135.
            %   In total it creates 16 Gabor filters.
            
            wavelength = 2;
            orientation = [0 45 90 135];
            g1 = gabor(wavelength,orientation);
            
            wavelength = 4;
            g2 = gabor(wavelength,orientation);
            
            wavelength = 8;
            g3 = gabor(wavelength,orientation);
            
            wavelength = 16;
            g4 = gabor(wavelength,orientation);
            
            g = [g1 g2 g3 g4];
        end
        
        function out = normalizeRows(mat)
            %normalizeRows(mat) normalizes matrix rows
            %   out = normalizeRows(mat);
            %   normalizes matrix rows between 0 and 1.
            %   largest value gets 1. smallest value gets 0.
            %   normalize each row. Rows are independent.
            
            out = zeros(size(mat));
            
            for i = 1 : size(mat,1)
                normRow = mat(i,:) - min(mat(i,:)); % minus min
                normRow = (normRow ./ max(mat(i,:))); % divide max
                out(i,:) = normRow; % set row
            end
        end
    end
end

