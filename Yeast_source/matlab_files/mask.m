classdef mask < handle
    %　This class receive the input target row and column, and the target dimension to segment, and generate a index
    %  mask for 
    properties
        x = 1;
        y = 1;
        xdim = 2048;
        ydim = 2048;
        original_matrix;
        index_matrix;
        value_matrix;
    end
    
    methods
        function obj = mask(varargin)
            % varargin is x, y, the target columns and rows to be
            % segmented, and then x dim and y dim the size or original
            % matrix
            display(nargin)
            if nargin == 1
                obj.x = varargin{1};
                obj.y = varargin{1};
            end
            if nargin >= 2
                obj.x = varargin{1};
                obj.y = varargin{2};
            end
            if nargin >= 3
                obj.xdim = varargin{3};
                obj.ydim = varargin{3};
            end
            if nargin >= 4
                obj.ydim = varargin{4};
            end
            
            % Create a 2048 by 2048 matrix
            obj.original_matrix = zeros(obj.xdim,obj.ydim);
            obj.index_matrix = zeros(obj.xdim,obj.ydim);
            obj.value_matrix = zeros(obj.xdim,obj.ydim);
        end
        
        % add index for x and y columns
        function assign_index(obj)
            [rows, cols] = size(obj.original_matrix);

            % calculate size for each segment
            rowSize = floor(rows/obj.x);
            colSize = floor(cols/obj.y);

            % loop over to fill in target matrix
            obj.index_matrix = zeros(rows, cols);
            for i = 1:obj.x
                for j = 1:obj.y
                    rowStart = (i-1)*rowSize+1;
                    rowEnd = i*rowSize;
                    colStart = (j-1)*colSize+1;
                    colEnd = j*colSize;
                    obj.index_matrix(rowStart:rowEnd,colStart:colEnd) = (i-1)*obj.x + j;
                end
            end
        end
        % assign value to obj by block, receive a one dim array, create a new value matrix
        function assign_value(obj,array)
            for value = 1: numel(array)
                obj.value_matrix(obj.index_matrix == value) = array(value);
            end
        end
        
    end
    
end