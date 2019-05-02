function varargout = bondGUI(varargin)
% BONDGUI MATLAB code for bondGUI.fig
%      BONDGUI, by itself, creates a new BONDGUI or raises the existing
%      singleton*.
%
%      H = BONDGUI returns the handle to a new BONDGUI or the handle to
%      the existing singleton*.
%
%      BONDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BONDGUI.M with the given input arguments.
%
%      BONDGUI('Property','Value',...) creates a new BONDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bondGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bondGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bondGUI

% Last Modified by GUIDE v2.5 01-May-2019 23:38:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bondGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @bondGUI_OutputFcn, ...
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

% --- Executes just before bondGUI is made visible.
function bondGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bondGUI (see VARARGIN)

% Choose default command line output for bondGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using bondGUI.
if strcmp(get(hObject,'Visible'),'off')
    createPortfolio;
    ind = get(handles.radiobutton1,'Value');
    if(ind == 0)
        portfolio = NonIndexedPortfolio;
    else
        portfolio = NonIndexedPortfolio;
    end
    portfolio.yieldCurve;
end

% UIWAIT makes bondGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bondGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
createPortfolio;

switch popup_sel_index
    case 1
        NonIndexedPortfolio.yieldCurve;
    case 2
        NonIndexedPortfolio.zeroCurve;
    case 3
        NonIndexedPortfolio.forwardCurve;
    case 4
        NonIndexedPortfolio.discountCurve;
    % TODO: SWAP RATES 
    % case 5
    %    NonIndexedPortfolio.yieldCurve;
end
% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Yield', 'Zero rates', 'Forward rates', 'Discount rates'}); % TODO: 'Swap rates'

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Yield', 'Zero rates', 'Forward rates', 'Discount rates'}); % TODO: 'Swap rates'


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hold on
createPortfolio;
ind = get(handles.radiobutton1,'Value');
if(ind == 0)
    portfolio = NonIndexedPortfolio;
else
    portfolio = NonIndexedPortfolio;
end
portfolio = portfolio.calculateCurves;
contents = get(handles.popupmenu1,'String'); 
curve = contents{get(handles.popupmenu1,'Value')}; 
dates = portfolio.curveDates;

switch curve
    case "Yield"
        rates = portfolio.yield;
        dates = datenum(portfolio.maturity,'dd/mm/yyyy');
    case "Zero rates"
        rates = portfolio.zeroRates;
    case "Forward rates"
        rates = portfolio.forwardRates;
    case "Discount rates"
        rates = portfolio.discountRates;
end

plot(dates, rates*100,'b--')
ytickformat('%.2f%%')
datetick('x','dd/mm/yyyy')
xlim([min(dates) max(dates)])

% GILDI ÚR POP UP MENU
%contents = get(handles.popupmenu1,'String'); 
%contents{get(handles.popupmenu1,'Value')}; 
    
% Hint: get(hObject,'Value') returns toggle state of checkbox1

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
hold on
createPortfolio;
ind = get(handles.radiobutton1,'Value');
degree = round(get(handles.slider3,'Value'))

if(ind == 0)
    portfolio = NonIndexedPortfolio;
else
    portfolio = NonIndexedPortfolio;
end
portfolio = portfolio.calculateCurves;
contents = get(handles.popupmenu1,'String'); 
curve = contents{get(handles.popupmenu1,'Value')}; 
dates = portfolio.curveDates;

switch curve
    case "Yield"
        rates = portfolio.yield;
        dates = datenum(portfolio.maturity,'dd/mm/yyyy');
    case "Zero rates"
        rates = portfolio.zeroRates;
    case "Forward rates"
        rates = portfolio.forwardRates;
    case "Discount rates"
        rates = portfolio.discountRates;
end

 
p = polyfit(dates', rates, degree);
px = linspace(min(dates),max(dates),max(dates)-min(dates));
py = polyval(p, px);

plot(px, py*100,'r--')
ytickformat('%.2f%%')
datetick('x','dd/mm/yyyy')
xlim([min(dates) max(dates)])


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

numSteps = 6;
set(hObject, 'Min', 1);
set(hObject, 'Max', numSteps);
set(hObject, 'Value', 1);
set(hObject, 'SliderStep', [1/(numSteps-1) , 1/(numSteps-1) ]);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in radiobutton1.
 function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
