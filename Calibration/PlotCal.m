function varargout = PlotCal(varargin)
% PLOTCAL M-file for PlotCal.fig
%      PLOTCAL, by itself, creates a new PLOTCAL or raises the existing
%      singleton*.
%
%      H = PLOTCAL returns the handle to a new PLOTCAL or the handle to
%      the existing singleton*.
%
%      PLOTCAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTCAL.M with the given input arguments.
%
%      PLOTCAL('Property','Value',...) creates a new PLOTCAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotCal_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotCal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlotCal

% Last Modified by GUIDE v2.5 16-Jul-2012 19:01:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotCal_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotCal_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Executes just before PlotCal is made visible.
% Performs Initial Setup
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function PlotCal_OpeningFcn(hObject, eventdata, handles, varargin)
	% Choose default command line output for PlotCal
	handles.output = hObject;
	
	% This sets up the initial plot - only do when we are invisible
	% so window can get raised using PlotCal.
	if strcmp(get(hObject,'Visible'),'off')
	    plot([0 0]);
	end
	
	% set Channel for plot
	handles.Channel = 3;
	update_ui_val(handles.PlotChannelCtrl, handles.Channel);
	
	% set XScale for plot (linear)
	handles.XScale = 1;
	update_ui_val(handles.XScaleCtrl, handles.XScale);
	

	% if input arguments were given, assign varargin{1} to caldata
	if ~isempty(varargin)
		handles.caldata = varargin{1};
		% check if maginv (magnitude correction) exists, if not, compute it
		if ~isfield(handles.caldata, 'maginv')
			handles.caldata.phase_us = handles.caldata.phase;
			% preconvert phases from angle (RADIANS) to microsecond
			handles.caldata.phase_us(1, :) = (1.0e6 * unwrap(handles.caldata.phase(1, :))) ./ (2 * pi * handles.caldata.freq);
			handles.caldata.phase_us(2, :) = (1.0e6 * unwrap(handles.caldata.phase(2, :))) ./ (2 * pi * handles.caldata.freq);

			% get the overall min and max dB SPL levels
			handles.caldata.mindbspl(1) = min(handles.caldata.mag(1, :));
			handles.caldata.mindbspl(2) = min(handles.caldata.mag(2, :));
			handles.caldata.maxdbspl(1) = max(handles.caldata.mag(1, :));
			handles.caldata.maxdbspl(2) = max(handles.caldata.mag(2, :));

			% precompute the inverse filter, and convert to RMS value.
			handles.caldata.maginv = zeros(size(handles.caldata.mag));
			% subtract SPL mags (at each freq) from the min dB recorded for each
			% channel and convert back to rms
			handles.caldata.maginv(1, :) = invdb(handles.caldata.mindbspl(1) - handles.caldata.mag(1, :));
			handles.caldata.maginv(2, :) = invdb(handles.caldata.mindbspl(2) - handles.caldata.mag(2, :));		
			% check if caldata has reference channel data (3)
			[n, ~] = size(handles.caldata.mag);
			if n > 2
				disp([mfilename ': calibration data has reference channel information'])
				disp([mfilename ': ' num2str(n) ' reference channels detected'])
				handles.ReferenceChannel = n;
			else
				handles.ReferenceChannel = 0;
			end
		end
		guidata(hObject, handles);
		% update the plot
		Update_ctrl_Callback(hObject, eventdata, handles);
	end
	% Update handles structure
	guidata(hObject, handles);
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% GUI control callbacks
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% Update Plots
%-------------------------------------------------------------------------
function Update_ctrl_Callback(hObject, eventdata, handles)
	axes(handles.axes1);
	cla;
	caldata = handles.caldata;
	
	popup_sel_index = get(handles.PlotMenu, 'Value');
	switch popup_sel_index
		%--------------------------------
		% 1: Magnitude
		%--------------------------------
	    case 1
			if isfield(caldata,'magdbspl')
				v1 = caldata.mag(1, :);
				v2 = caldata.mag(2, :);
				e1 = caldata.mag_stderr(1, :);
				e2 = caldata.mag_stderr(2, :);	
				y_label = 'Max Intensity (db SPL)';
			else
				v1 = caldata.mag(1, :);
				v2 = caldata.mag(2, :);
				e1 = caldata.mag_stderr(1, :);
				e2 = caldata.mag_stderr(2, :);	
				y_label = 'Mag (db SPL)';
			end
		%--------------------------------
		% 2: Maginv
		%--------------------------------
		case 2
			if isfield(caldata, 'maginv')
				v1 = db(caldata.maginv(1, :));
				v2 = db(caldata.maginv(2, :));
	 			e1 = zeros(size(v1));
				e2 = e1;	
				y_label = 'Correction Intensity (db SPL)';
			end
		%--------------------------------
		% 3: Phase
		%--------------------------------
		case 3
			if isfield(caldata, 'phase')
				% convert phases from angle (RADIANS) to microsecond
				v1 = (1.0e6 * unwrap(caldata.phase(1, :))) ./ (2 * pi * caldata.freq);
				v2 = (1.0e6 * unwrap(caldata.phase(2, :))) ./ (2 * pi * caldata.freq);
				e1 = (1.0e6 * unwrap(caldata.phase_stderr(1, :))) ./ (2 * pi * caldata.freq);
				e2 = (1.0e6 * unwrap(caldata.phase_stderr(2, :))) ./ (2 * pi * caldata.freq);
				y_label = 'Phase (us)';
			end
		%--------------------------------
		% 4: Distortion
		%--------------------------------
		case 4
			if isfield(caldata, 'dist')
				v1 = caldata.dist(1, :);
				v2 = caldata.dist(2, :);
				y_label = 'Distortion (%)';
			end
		%--------------------------------
		% 5: Leak Intensity (crosstalk)
		%--------------------------------
		case 5
			if isfield(caldata, 'leakmag')
				v1 = caldata.leakmag(1, :);
				v2 = caldata.leakmag(2, :);
				e1 = caldata.leakmag_stderr(1, :);
				e2 = caldata.leakmag_stderr(2, :);
				y_label = 'Leak Intensity (db SPL)';
			end
		%--------------------------------
		% 6: Leak Phase (crosstalk)
		%--------------------------------
		case 6
			if isfield(caldata, 'leakphase')
				% convert phases from angle (RADIANS) to microsecond
				v1 = (1.0e6 * unwrap(caldata.leakphase(1, :))) ./ (2 * pi * caldata.freq);
				v2 = (1.0e6 * unwrap(caldata.leakphase(2, :))) ./ (2 * pi * caldata.freq);
				y_label = 'Leak Phase (us)';
			end
		%--------------------------------
		% 7: Leak Distortion (crosstalk)
		%--------------------------------
		case 7
			if isfield(caldata, 'leakdist')
				v1 = caldata.leakdist(1, :);
				v2 = caldata.leakdist(2, :);
				y_label = 'Leak Distortion (%)';
			end
		%--------------------------------
		% 8: magnitude std. error
		%--------------------------------
		case 8
			if isfield(caldata, 'mag_stderr')
				v1 = caldata.mag_stderr(1, :);
				v2 = caldata.mag_stderr(2, :);
				y_label = 'Mag stderr';
			end
		%--------------------------------
		% 9: phase std. error
		%--------------------------------
		case 9	
			if isfield(caldata, 'phase_stderr')
				v1 = (1.0e6 * unwrap(caldata.phase_stderr(1, :))) ./ (2 * pi * caldata.freq);
				v2 = (1.0e6 * unwrap(caldata.phase_stderr(2, :))) ./ (2 * pi * caldata.freq);
				y_label = 'Phase stderr';
			end
	end

	% check if plot selected is 1 (magnitude) or 2 (mag inverse)
	if any(popup_sel_index == [1 2 5])
		% check on channel(s) to plot
		if handles.Channel == 1
			errorbar(caldata.freq, v1, e1, 'g.-');
			legend({'L'})
		elseif handles.Channel == 2
			errorbar(caldata.freq, v2, e2, 'r.-');
			legend({'R'})		
		elseif handles.Channel == 3
			errorbar(caldata.freq, v1, e1, 'g.-');
			hold on;
			errorbar(caldata.freq, v2, e2, 'r.-');
			hold off;
			legend({'L', 'R'})
		end
				
		if isfield(handles, 'ReferenceChannel')
			if handles.ReferenceChannel & popup_sel_index == 1
				if handles.ReferenceChannel == 3
					hold on;
					plot(caldata.freq, caldata.mag(3, :), 'k.-');
					hold off;
					legend({'L', 'R', 'REF'})
				elseif handles.ReferenceChannel == 4
					hold on;
					plot(caldata.freq, caldata.mag(3, :), 'c.:');
					plot(caldata.freq, caldata.mag(4, :), 'mo:');
					hold off;
					legend({'L', 'R', 'REFL', 'REFR'})
				end
			end
		end
	else
		if handles.Channel == 1
			plot(caldata.freq, v1, 'g.-');
			legend({'L'})
		elseif handles.Channel == 2
			plot(caldata.freq, v2, 'r.-');
			legend({'R'})		
		elseif handles.Channel == 3
			plot(caldata.freq, v1, 'g.-', caldata.freq, v2, 'r.-');
			legend({'L', 'R'})
		end
	end
	xlabel('Frequency');
	ylabel(y_label);
	set(gca, 'XGrid', 'on');
	set(gca, 'YGrid', 'on');
	set(gca, 'Color', .5*[1 1 1]);
	if handles.XScale == 1
		set(gca, 'XScale', 'linear')
	else
		set(gca, 'XScale', 'log');
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function PlotSelect_Callback(hObject, eventdata, handles)
	Update_ctrl_Callback(hObject, eventdata, handles);
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function AutoXLimitCtrl_Callback(hObject, eventdata, handles)
	currentVal = read_ui_val(hObject);
	if currentVal == 1
		set(handles.axes1, 'XLimMode', 'auto');
		newlim = xlim(handles.axes1);
		disable_ui(handles.XMinCtrl);
		disable_ui(handles.XMaxCtrl);
	else
		set(handles.axes1, 'XLimMode', 'manual');
		enable_ui(handles.XMinCtrl);
		enable_ui(handles.XMaxCtrl);
		lim1 = read_ui_str(handles.XMinCtrl, 'n');
		lim2 = read_ui_str(handles.XMaxCtrl, 'n');
		xlim(handles.axes1, [lim1 lim2]);
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function AutoYLimitCtrl_Callback(hObject, eventdata, handles)
	currentVal = read_ui_val(hObject);
	if currentVal == 1
		set(handles.axes1, 'YLimMode', 'auto');
		newlim = ylim(handles.axes1);
		disable_ui(handles.YMinCtrl);
		disable_ui(handles.YMaxCtrl);
	else
		set(handles.axes1, 'YLimMode', 'manual');
		enable_ui(handles.YMinCtrl);
		enable_ui(handles.YMaxCtrl);
		lim1 = read_ui_str(handles.YMinCtrl, 'n');
		lim2 = read_ui_str(handles.YMaxCtrl, 'n');
		ylim(handles.axes1, [lim1 lim2]);
	end
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
function XMinCtrl_Callback(hObject, eventdata, handles)
	newlim = xlim(handles.axes1);
	newval = read_ui_str(hObject, 'n');
	newlim(1) = newval;
	xlim(newlim);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function XMaxCtrl_Callback(hObject, eventdata, handles)
	newlim = xlim(handles.axes1);
	newval = read_ui_str(hObject, 'n');
	newlim(2) = newval;
	xlim(newlim);
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% --- Executes on selection change in XScaleCtrl.
%-------------------------------------------------------------------------
function XScaleCtrl_Callback(hObject, eventdata, handles)
	handles.XScale = get(handles.XScaleCtrl, 'Value');
	guidata(hObject, handles);
	Update_ctrl_Callback(hObject, eventdata, handles);
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
function YMinCtrl_Callback(hObject, eventdata, handles)
	newlim = ylim(handles.axes1);
	newval = read_ui_str(hObject, 'n');
	newlim(1) = newval;
	ylim(newlim);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function YMaxCtrl_Callback(hObject, eventdata, handles)
	newlim = ylim(handles.axes1);
	newval = read_ui_str(hObject, 'n');
	newlim(2) = newval;
	ylim(newlim);
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
% --- Executes on selection change in PlotChannelCtrl.
%-------------------------------------------------------------------------
function PlotChannelCtrl_Callback(hObject, eventdata, handles)
	popup_sel_index = get(handles.PlotChannelCtrl, 'Value');
	handles.Channel = popup_sel_index;
	guidata(hObject, handles);
	Update_ctrl_Callback(hObject, eventdata, handles);
%-------------------------------------------------------------------------









%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Menu Functions
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function LoadCalMenuItem_Callback(hObject, eventdata, handles)
	[calfile, calpath] = uigetfile('*_cal.mat','Load headphone calibration data from file...');
	if calfile ~=0
		datafile = fullfile(calpath, calfile);	
		handles.caldata = load_headphone_cal(datafile);

		% check if caldata has reference channel data (3)
		[n, m] = size(handles.caldata.mag);
		if n == 3
			disp([mfilename ': calibration data has reference channel information'])
			handles.ReferenceChannel = 1;
		else
			handles.ReferenceChannel = 0;
		end
		guidata(hObject, handles);
		Update_ctrl_Callback(hObject, eventdata, handles);
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
	printdlg(handles.figure1)
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
	delete(handles.figure1)
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function SavePlotMenuItem_Callback(hObject, eventdata, handles)
	[figfile, figpath] = uiputfile('*.fig','Save plot in figure file...');
	if figfile ~=0
		figfile = fullfile(figpath, figfile);
		saveas(handles.axes1, figfile, 'fig');
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
%-------------------------------------------------------------------------
function varargout = PlotCal_OutputFcn(hObject, eventdata, handles)
	varargout{1} = handles.output;
%-------------------------------------------------------------------------

	
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Create Functions
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function PlotSelect_CreateFcn(hObject, eventdata, handles)
	if ispc
	    set(hObject,'BackgroundColor','white');
	else
	    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end
	set(hObject, 'String', {'Magnitude', 'Correction Magnitude', 'Phase', 'Distortion', ...
							'Leak Magnitude', 'Leak Phase', 'Leak Distortion', ...
							'Magnitude StdErr', 'Phase StdErr'});
%-------------------------------------------------------------------------
function XMinCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function XMaxCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function YMaxCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function YMinCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function PlotChannelCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function XScaleCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------





