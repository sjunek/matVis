# matVis
General purpose Matlab data viewer 
 matVis is a Matlab GUI for displaying data sets of arbitrary dimension using 2D images and 
  1D profiles. Key features of matVis include
  - Easy data input: load variables from the workspace or various image file
    formats including Zeiss lsm-files and .mat-files
  - Easy navigation through data sets of arbitrary dimension
  - Easy to learn user interface with tooltips for each control item
  - Visualize multiple data sets of identical dimensions in parallel
  - Histogram-guided contrast adjustment including gamma correction and
    algorithmic thresholding
  - Large variety of colormaps
  - Image and plot filter
  - Image projections including image tiling
  - RGB display including color-coded max- and mean-projections ('RGB
    stretch')
  - Extensive region of interest manager
  - Video generator, which can combine the content of mutiple windows into  
    a single customizable movie
  - Specify scales, names and units for the data dimensions
  - Use of alpha data including contrast and gamma adjustments
  - 2D histogram for image data / alpha data with histogram guided 2D 
    contrast adjustment
  - Figure and function handles can be accessed from 'outside', making
    matVis easy to integrate with other GUIs or Matlab functions
  - Save configuration (settings, window positions, ...) for future use
  - Use 'startPar' argument to selectively overwrite configuration
    paramaters (see below for list of start parameters)
  - Check for updates from within the main GUI
 
### Input Arguments
    -none-                      Select image file(s) (including matrices 
                                saved as .mat-file, multi-image tif, Zeiss 
                                lsm-files, RGB files, animated gif and most 
                                other image formats) via uigetfile. Files 
                                can be combined into a single matrix or 
                                opened "in parallel".
    data1, data2, ...           Data sets of arbitrary but identical dimension
    'pathname\filename.ext'     Path- + filename of desired file (works only for
                                one file)
 
### Optional Arguments ('PropertyName', PropertyValue)
        'dimScale'              Scale for dimensions, i.e. values of bounds
                                of 'pixel-locations' (like the x and y paramteres in
                                imagesc(x,y,d))
        'dimNames'              Cell array containing dimension names, e.g.
                                names = {'x';'y';'z';'time';'lambda'};
                                Make sure that size(names,1) == ndims(data{1}).
                                If omitted, dimensions will be named
                                Dim1  , Dim2, Dim3, ...
        'dimUnits'              Units of dimensions (simply for display purposes)
        'matNames'              Names of matrices displayed in Figure Name.
                                Needs to be specified as a cell array of
                                strings, even if only one matrix is
                                specified.
                                Default is the name of the variable in the matlab workspace, but if an
                                expression is used (such as d(:,:,1)), it will be empty leaving
                                matVis to display an empty string.
        'alphaMap'              Alphamap, has to be of same size as data
                                matrix. Useful for masking images. Background color will
                                be set to black.
        'startPar'              List of configuration settings. These
                                settings 'override' the custom settings saved in a customConfig
                                file (if available). The list should be a cell array with the
                                common {'propertyName1'; 'propertyValue1'; 'propertyName2';
                                'propertyValue2';...} structure. The following properies can be
                                set:
                                xySel             x- and y-dim for image display
                                zoomVal           Matrix indicating zoom setting
                                plotDim           Dimensions along which plots will be displayed
                                plotMean          Number indicating status of plot-average-mode: 0: 1x1, 1: 3x3, 2: 5x5, 3: [1x1,3x3,5x5], 4: zoom area, 5: RGB
                                currPos           Vector indicating starting position
                                cmMinMax          Matrix of size 2 x number of data sets for colormap limits
                                cmap              Number of colormap from list of available colormaps:  {'Gray';'Gray (Range)'; 'Jet'; 'HSV'; 'Hot'; 'Cool';
                                                    'Red 1';'Red 2';'Green 1';'Green 2';'Blue 1';'Blue 2'; 'Rainbow1';'Rainbow2';'Rainbow3';'Rainbow4';
                                                    'Blue-Gray-Yellow (0 centered)';'Magenta-Gray-Green (0 centered)'}
                                aspRatio          Two element vector
                                rgbDim            Number of RGB dimensions
                                projDim           Number of projection dimensions
                                projMethod        Number or string: {'None';'Max';'Min';'Mean';'Std';'Var'; 'Tile'}
                                windowVisibility  Binary vector indicating visibility of [imageWin zoomWin plotWin]
                                windowPositions   Structure s containing the fields s.gui, s.imageWin, s.zoomWin and s.plotWin. In case there is one data set, 
                                                    the values of the fields are four element vectors [x0, y0, width, height], in case there are nMat data sets, 
                                                    the values are matrices of size nMat x 4.
                                                    WARNING: gui Position includs TooltipDisplay!!!
 
### Output Argument (optional)
     Structure containing the following fields:
        - figHandles: figure handles to all figures, including main GUI
        - fctHandles: function handles of functions useful for 'data
          exchange' or 'external' update of matVis settings
        - settings: structure containing information about current settings
          (currently zoom and zoomXY)
        - dataName: cell array containing names of the loaded data
 
### Mouse actions
    Left click and drag                      Draw zoom region
    Right click                              Unzoom
    Left click and drag in Zoom Rectangle    Move zoom region (pan)
    Middle click or Shift + left click       Move Position Lines
    Double click                             Copy content of current figure
                                             to clipboard (either as bitmap or vector graphics).
                                             Works only for Windows OS.
    Right click in main gui                  Bring all visibile windows on
                                             top of the screen
    Scroll Wheel (Matlab 2007a or later)     Zoom in and out (for zoom and
                                             image windows)
 
### Keyboard
    Instead of using sliders or text boxes to change the current position values,
    you can use the number keys on the keyboard instead. Press '1' to increase
    the current value of Dim1 by one, press 'control'+'1' to decrease its
    value by one,... This is however only possible if the main gui is the
    current figure (i.e. the selected window) and none of its controls is active
    (click in some empty space within the gui if it doesn't work as you
    expect).
    Works also only for the first nine dimensions :(
 
### RGB Display
    RGB display can be toggled with the RGB button. You can use RGB display
    for each dimension that is not used as either 'x' or 'y' dimension. As
    you press the RGB button you switch between all possible dimensions.
    The current image is displayed as the green channel, the preceding as
    red and the succeeding as the blue channel. If there are only two
    values in the selected dimension the blue channel will be left empty.
    If you select the 'Stretch RGB' option, a colormap along the complete
    dimension will be created such that red corresponds to high intensities
    in the initial part, green to high intensities in the intermediate part,
    and blue to high intensities in the late part of the selected
    dimension. Changing the position of the slider of this dimension does
    not have any effect.
 
  Note that some functions (e.g. histogram, export data) are so
  far only supported for the first data set! Using them while multiple data
  sets are loaded might lead to errors!
 
  See end of this file for a list of known bugs and planned feature
  implementations.
  See http://www.colors-and-contrasts.com/Documents/matVisGuide.pdf for a
  complete manual (can also be accessed from the main Gui of matVis).
  Manual is not completely up to date. Please contact me if you have 
  questions / bug reports / feature requests!
 
 **************************************************************************
          Copyright 2016, Stephan Junek (stephan.junek@brain.mpg.de)
