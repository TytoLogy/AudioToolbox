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

% Last Modified by GUIDE v2.5 06-Aug-2012 14:33:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotCal_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotCal_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
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
	else
		handles.pdata = struct(	'freq', [], ...
										'v1', [], ...
										'v2', [], ...
										'e1', [], ...
										'e2', [], ...
										'y_label', [], ...
										'cmd', [] );
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
function Update_ctrl_Callback(hObject, eventdata, handles) %#ok<*INUSL>
	axes(handles.axes1);
	cla;
	if isfield(handles, 'caldata')
		caldata = handles.caldata;
	else
		msgbox('No data loaded', 'PlotCal error');
		return
	end
	
	pdata.x = caldata.freq;
	
	popup_sel_index = get(handles.PlotMenu, 'Value');
	switch popup_sel_index
		%--------------------------------
		% 1: Magnitude
		%--------------------------------
	    case 1
			if isfield(caldata,'magdbspl')
				pdata.v1 = caldata.mag(1, :);
				pdata.v2 = caldata.mag(2, :);
				pdata.e1 = caldata.mag_stderr(1, :);
				pdata.e2 = caldata.mag_stderr(2, :);	
				pdata.y_label = 'Max Intensity (db SPL)';
			else
				pdata.v1 = caldata.mag(1, :);
				pdata.v2 = caldata.mag(2, :);
				pdata.e1 = caldata.mag_stderr(1, :);
				pdata.e2 = caldata.mag_stderr(2, :);	
				pdata.y_label = 'Mag (db SPL)';
			end
			pdata.cmd = @errorbar;

		%--------------------------------
		% 2: Maginv
		%--------------------------------
		case 2
			if isfield(caldata, 'maginv')
				pdata.v1 = db(caldata.maginv(1, :));
				pdata.v2 = db(caldata.maginv(2, :));
	 			pdata.e1 = zeros(size(pdata.v1));
				pdata.e2 = pdata.e1;	
				pdata.y_label = 'Correction Intensity (db SPL)';
				pdata.cmd = @plot;
			end
		%--------------------------------
		% 3: Phase
		%--------------------------------
		case 3
			if isfield(caldata, 'phase')
				% convert phases from angle (RADIANS) to microsecond
				pdata.v1 = (1.0e6 * unwrap(caldata.phase(1, :))) ./ (2 * pi * caldata.freq);
				pdata.v2 = (1.0e6 * unwrap(caldata.phase(2, :))) ./ (2 * pi * caldata.freq);
				pdata.e1 = (1.0e6 * unwrap(caldata.phase_stderr(1, :))) ./ (2 * pi * caldata.freq);
				pdata.e2 = (1.0e6 * unwrap(caldata.phase_stderr(2, :))) ./ (2 * pi * caldata.freq);
				pdata.y_label = 'Phase (us)';
				pdata.cmd = @errorbar;
			end
		%--------------------------------
		% 4: Distortion
		%--------------------------------
		case 4
			if isfield(caldata, 'dist')
				pdata.v1 = caldata.dist(1, :) * 100;
				pdata.v2 = caldata.dist(2, :) * 100;
				pdata.y_label = 'Distortion (%)';
				pdata.cmd = @plot;
			end
		%--------------------------------
		% 5: Leak Intensity (crosstalk)
		%--------------------------------
		case 5
			if isfield(caldata, 'leakmag')
				pdata.v1 = caldata.leakmag(1, :);
				pdata.v2 = caldata.leakmag(2, :);
				pdata.e1 = caldata.leakmag_stderr(1, :);
				pdata.e2 = caldata.leakmag_stderr(2, :);
				pdata.y_label = 'Leak Intensity (db SPL)';
				pdata.cmd = @errorbar;
			else
				warndlg('no leakmag data', mfilename);
				return
			end
		%--------------------------------
		% 6: Leak Phase (crosstalk)
		%--------------------------------
		case 6
			if isfield(caldata, 'leakphase')
				% convert phases from angle (RADIANS) to microsecond
				pdata.v1 = (1.0e6 * unwrap(caldata.leakphase(1, :))) ./ (2 * pi * caldata.freq);
				pdata.v2 = (1.0e6 * unwrap(caldata.leakphase(2, :))) ./ (2 * pi * caldata.freq);
				pdata.y_label = 'Leak Phase (us)';
				pdata.cmd = @plot;
			end
		%--------------------------------
		% 7: Leak Distortion (crosstalk)
		%--------------------------------
		case 7
			if isfield(caldata, 'leakdist')
				pdata.v1 = caldata.leakdist(1, :) * 100;
				pdata.v2 = caldata.leakdist(2, :) * 100;
				pdata.y_label = 'Leak Distortion (%)';
				pdata.cmd = @plot;
			end
		%--------------------------------
		% 8: magnitude std. error
		%--------------------------------
		case 8
			if isfield(caldata, 'mag_stderr')
				pdata.v1 = caldata.mag_stderr(1, :);
				pdata.v2 = caldata.mag_stderr(2, :);
				pdata.y_label = 'Mag stderr';
				pdata.cmd = @plot;
			end
		%--------------------------------
		% 9: phase std. error
		%--------------------------------
		case 9	
			if isfield(caldata, 'phase_stderr')
				pdata.v1 = (1.0e6 * unwrap(caldata.phase_stderr(1, :))) ./ (2 * pi * caldata.freq);
				pdata.v2 = (1.0e6 * unwrap(caldata.phase_stderr(2, :))) ./ (2 * pi * caldata.freq);
				pdata.y_label = 'Phase stderr';
				pdata.cmd = @plot;
			end
		%--------------------------------
		% 10: Background
		%--------------------------------
	    case 10
			if isfield(caldata,'background')
				pdata.v1 = caldata.background(1, :);
				pdata.v2 = caldata.background(2, :);
				pdata.e1 = caldata.background_stderr(1, :);
				pdata.e2 = caldata.background_stderr(2, :);	
				pdata.y_label = 'Background Intensity (db SPL)';
				pdata.cmd = @errorbar;
			else
				warndlg('no background data', mfilename);
				return
			end
		%--------------------------------
		% 11: Magnitude (Volts)
		%--------------------------------
		case 11
			if isfield(caldata,'magsraw')
				pdata.v1 = mean(caldata.magsV{1}, 2);
				pdata.v2 = mean(caldata.magsV{2}, 2);
				pdata.e1 = std(caldata.magsV{1}, 0, 2);
				pdata.e2 = std(caldata.magsV{2}, 0, 2);	
				pdata.y_label = 'Magnitude (Volts)';
				pdata.cmd = @errorbar;
			else
				warndlg('no magsraw data', mfilename);
				return
			end
		%--------------------------------
		% 12: Magnitude (dbV)
		%--------------------------------
		case 12
			if isfield(caldata,'magsraw')
				pdata.v1 = db(mean(caldata.magsV{1}, 2));
				pdata.v2 = db(mean(caldata.magsV{2}, 2));
				pdata.e1 = db(std(caldata.magsV{1}, 0, 2));
				pdata.e2 = db(std(caldata.magsV{2}, 0, 2));
				pdata.y_label = 'Magnitude (dB V)';
				pdata.cmd = @errorbar;
			else
				warndlg('no magsraw data for dB V calculation!', mfilename);
				return
			end

	end

	%-------------------------------------------------------------------
	% check if plot selected is 1 (magnitude) 2 (mag inverse) or 5 (Leak mag)
	%-------------------------------------------------------------------
	if any(popup_sel_index == [1 2 5 10])
		% check on channel(s) to plot
		if handles.Channel == 1
			errorbar(caldata.freq, pdata.v1, pdata.e1, 'g.-');
			legend({'L'})
		elseif handles.Channel == 2
			errorbar(caldata.freq, pdata.v2, pdata.e2, 'r.-');
			legend({'R'})		
		elseif handles.Channel == 3
			errorbar(caldata.freq, pdata.v1, pdata.e1, 'g.-');
			hold on;
			errorbar(caldata.freq, pdata.v2, pdata.e2, 'r.-');
			hold off;
			legend({'L', 'R'})
		end
		% if ref channel data were collected, plot them
		if isfield(handles, 'ReferenceChannel')
			if handles.ReferenceChannel && (popup_sel_index) == 1
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
	%-------------------------------------------------------------------
	% plot other types
	%-------------------------------------------------------------------
	else
		if handles.Channel == 1
			plot(caldata.freq, pdata.v1, 'g.-');
			legend({'L'})
		elseif handles.Channel == 2
			plot(caldata.freq, pdata.v2, 'r.-');
			legend({'R'})		
		elseif handles.Channel == 3
			plot(caldata.freq, pdata.v1, 'g.-', caldata.freq, pdata.v2, 'r.-');
			legend({'L', 'R'})
		end
	end
	
	%-------------------------------------------------------------------
	% Plot display settings
	%-------------------------------------------------------------------
	% Update labels
	xlabel('Frequency');
	ylabel(pdata.y_label);
	% Turn on Grid
	set(gca, 'XGrid', 'on');
	set(gca, 'YGrid', 'on');
	% set background color
	set(gca, 'Color', .5*[1 1 1]);
	% set scale 
	if handles.XScale == 1
		set(gca, 'XScale', 'linear')
	else
		set(gca, 'XScale', 'log');
	end
	% legend
	legend(gca, 'Location', 'Best');
	legend(gca, 'boxoff');
	% update Dataname string
	if isfield(caldata, 'settings')
		if isfield(caldata.settings, 'calfile')
			update_ui_str(handles.Dataname, caldata.settings.calfile);
		end
	else
		update_ui_str(handles.Dataname, 'unknown calfile name');
	end
	%-------------------------------------------------------------------
	% store pdata struct in handles, update hObject
	%-------------------------------------------------------------------
	handles.pdata = pdata;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function PlotSelect_Callback(hObject, eventdata, handles)
	Update_ctrl_Callback(hObject, eventdata, handles);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function AutoXLimitCtrl_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
	currentVal = read_ui_val(hObject);
	if currentVal == 1
		set(handles.axes1, 'XLimMode', 'auto');
% 		newlim = xlim(handles.axes1);
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
% 		newlim = ylim(handles.axes1);
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
	[calfile, calpath] = uigetfile( {'*.cal'; '*_cal.mat'}, ...
												'Load headphone calibration data from file...');
	if calfile ~=0
		datafile = fullfile(calpath, calfile);	
		handles.caldata = load_headphone_cal(datafile);

		% check if caldata has reference channel data (3)
		[n, ~] = size(handles.caldata.mag);
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
function SaveFigureMenuItem_Callback(hObject, eventdata, handles)
	[figfile, figpath] = uiputfile('*.fig','Save plot and figure in .fig file...');
	if figfile ~=0
		figfile = fullfile(figpath, figfile);
		saveas(handles.axes1, figfile, 'fig');
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function IndividualPlotMenuItem_Callback(hObject, eventdata, handles)
	% create new figure
	figure	
	% copy 
	a = axes;
	ax2ax(handles.axes1, a)
	plotStrings = read_ui_str(handles.PlotMenu);
	plotVal = read_ui_val(handles.PlotMenu);
	
	if isfield(handles.caldata, 'settings')
		if isfield(handles.caldata.settings, 'calfile')
			[~, fname, ~] = fileparts(handles.caldata.settings.calfile);
		else
			fname = {};
		end
	else
		fname = {};
	end	

	if ~isempty(fname)
		tstr = {plotStrings{plotVal}, fname};
	else
		tstr = plotStrings{plotVal};
	end
	
	title(tstr, 'Interpreter', 'none')
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function ax2ax(hSource, hDest)
	% Copy everything on one axes to another.

	% Find children, copy non-text ones.
	kids=allchild(hSource);
	nontextkids=kids(~strcmp(get(kids,'type'),'text'));
	copyobj(nontextkids,hDest);

	% Axes Directions (may need to add other properties)
	meth={'YDir','XLim','YLim'};
	cellfun(@(m)set(hDest,m,get(hSource,m)),meth);

	% Special treatment for text-children
	axes(hDest)
	xlabel(get(get(hSource,'xlabel'),'string'));
	ylabel(get(get(hSource,'ylabel'),'string'));
	title(get(get(hSource,'title'),'string'));
	set(hDest, 'XScale', get(hSource, 'XScale'))
	set(hDest, 'XGrid', get(hSource, 'XGrid'));
	set(hDest, 'YGrid', get(hSource, 'YGrid'));
%-------------------------------------------------------------------------
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
function PlotSelect_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
	if ispc
	    set(hObject,'BackgroundColor','white');
	else
	    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end
	set(hObject, 'String', ...
			{	'Magnitude (dB SPL)', ...
				'Correction Magnitude (dB)', ...
				'Phase', ...
				'Distortion (%)', ...
				'Leak Magnitude (dB)', ...
				'Leak Phase', ...
				'Leak Distortion', ...
				'Magnitude StdErr', ...
				'Phase StdErr', ...
				'Background', ...
				'Magnitude (V)', ...
				'Magnitude (dbV)'	...
			}...
		);
%-------------------------------------------------------------------------
function XMinCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
											get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function XMaxCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
											get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function YMaxCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
											get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function YMinCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
											get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function PlotChannelCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
											get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function XScaleCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
											get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------





