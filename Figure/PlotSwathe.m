function H = PlotSwathe(bar,swathe,SwatheOpt)
% =========================================================================
% Plot a line with a shaded swathe
% =========================================================================
% H = PlotSwathe(bar,swathe,SwatheOpt.col,SwatheOpt.transp,nticks,fo,SwatheOpt.frequency,SwatheOpt.swatheonly)
% -------------------------------------------------------------------------
% INPUT
%   - bar: line to plot
%   - swathe: if a vector, draws symmetric errorbars. Otherwise draws 
%     	asymmetric error bars, with first columnn being the upper bar and 
%       second column being the lower bar
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%   - SwatheOpt.col: SwatheOpt.col of the line/patch, can be rgb number (e.g. [1 0 0]
%       or string (e.g. 'blue')
%   - SwatheOpt.transp: 'transparent' for transparency, [empty] otherwise. 
%       Default is [empty]
%   - nticks: number ticks on the horizontal axis
%   - fo: first observation (convention: 1987.00 = 1987Q1)
%   - SwatheOpt.frequency: quarterly ('q') or annual ('y') SwatheOpt.frequency. Default: 'q'
%   - SwatheOpt.swatheonly: set to 1 to plot only the swathe. Default: 0
%--------------------------------------------------------------------------
% OUPUT
%   - H.bar: handle for the median
%   - H.patch: handle for the patch
%   - H.swathe: H.swathe(1) handle for upp , H.swathe(2) handle for low
%   - H.ax: hande for the axis
%   - H.nobs: number of observations
% =========================================================================
% EXAMPLE
% x = 3*sin(1:50);
% PlotSwathe(x,1,'dark blue','transparent',2,1970)
% hold on
% y = cos(1:50);
% PlotSwathe(y,1,'light red','transparent',2,1970)
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

if ~exist('SwatheOpt','var')
    SwatheOpt = PlotSwatheOption;
end

if isnumeric(SwatheOpt.col) % in case user provides already the rgb code
    colrgb = SwatheOpt.col;
else % otherwise use rgb to get the code
    colrgb = rgb(SwatheOpt.col);
end

% Number of observations
nobs = length(bar); H.nobs = nobs;

% Make sure data is row-vector
if size(bar,1)>1
    bar =bar';
end

% Check if swathe is vector and set error bands
if isvector(swathe)
    % Check if swathe has the right dimension [1 x T]
    if size(swathe,1)>1
        swathe = swathe';
        low = bar - swathe;
        upp = bar + swathe;
    else
        low = bar - swathe;
        upp = bar + swathe;
    end
else
    % Check if i has the right dimension [2 x T]
    if size(swathe,1)>2
        swathe = swathe';
        upp = swathe(1,:);
        low = swathe(2,:);
    else
        upp = swathe(1,:);
        low = swathe(2,:);
    end
end
    
% Create the x axis
xaxis = 1:nobs;



%% PLOT
% Initialize patch 
edgeColor = colrgb+(1-colrgb)*0.55;
patchSaturation = 1; %How de-saturated or SwatheOpt.transp to make the patch
if strcmp(SwatheOpt.transp,'transparent')==1
    faceAlpha = patchSaturation;
    patchColor = colrgb;
    set(gcf,'renderer','openGL')
else
    faceAlpha = 1;
    patchColor = colrgb+(1-colrgb)*(1-patchSaturation);
    set(gcf,'renderer','painters')
end

% Plot the 'bar' line
if SwatheOpt.swatheonly==0
    H.bar = plot(xaxis,bar,'LineWidth',2,'Color',colrgb);
end

%Add the error-bar plot elements
holdStatus = ishold;
if ~holdStatus, hold on,  end

% Make the cordinats for the patch
yP = [low,fliplr(upp)];
xP = [xaxis,fliplr(xaxis)];

% Remove any nans otherwise patch won't work
xP(isnan(yP))=[];
yP(isnan(yP))=[];
H.patch=patch(xP,yP,1,'facecolor',patchColor,'edgecolor','none','facealpha',faceAlpha);

%Make nice edges around the patch. 
H.swathe(1)=plot(xaxis,low,'-','Color',edgeColor);
H.swathe(2)=plot(xaxis,upp,'-','Color',edgeColor);
if SwatheOpt.swatheonly==0
    delete(H.bar)
end
if SwatheOpt.swatheonly==0
    H.bar=plot(xaxis,bar,'LineWidth',2,'Color',colrgb,'Marker',SwatheOpt.marker);
end
if ~holdStatus, hold off, end

% Make smart x labels
if SwatheOpt.do_dates==1
    DatesPlot(fo,nobs,nticks,SwatheOpt.frequency)
end
H.ax = gca;