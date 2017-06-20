function varargout = ADICV(varargin)
% ADICV MATLAB code for ADICV.fig
%      ADICV, by itself, creates a new ADICV or raises the existing
%      singleton*.
%
%      H = ADICV returns the handle to a new ADICV or the handle to
%      the existing singleton*.
%
%      ADICV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADICV.M with the given input arguments.
%
%      ADICV('Property','Value',...) creates a new ADICV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ADICV_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ADICV_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ADICV

% Last Modified by GUIDE v2.5 25-May-2017 16:09:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ADICV_OpeningFcn, ...
                   'gui_OutputFcn',  @ADICV_OutputFcn, ...
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


% --- Executes just before ADICV is made visible.
function ADICV_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ADICV (see VARARGIN)

% Choose default command line output for ADICV
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ADICV wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ADICV_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function demand_Callback(hObject, eventdata, handles)
% hObject    handle to demand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of demand as text
%        str2double(get(hObject,'String')) returns contents of demand as a double


% --- Executes during object creation, after setting all properties.
function demand_CreateFcn(hObject, eventdata, handles)
% hObject    handle to demand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tabel.columnname = {'Demand'};
D = str2double(get(handles.demand, 'String'));
if D > 0
	tabel = cell(D,1);
	tabel(:,:)={''};
end; 
set(handles.tabeldemand,'Data',tabel);
set(handles.tabeldemand,'ColumnEditable', true(1,1));



% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.demandGraph);
cla;

demand = str2double(get(handles.tabeldemand, 'Data'))
demand = transpose(demand)

c = size(demand)
a = c(1,2)

demandCheck = ismember(demand,0)
demandCheck = not(demandCheck) + 1 - 1
numDemand = histc(demandCheck,1)

zeroDemand = not(demandCheck)

total = 0;
for i = 1:a
	total = total+demand(i);
end;

cumZD(1,1) = 0;
for i = 2:a
	if zeroDemand(1,i) == 1
       cumZD(1,i) = cumZD(1,i-1)+zeroDemand(1,i); else
       cumZD(1,i) = 0;
    end;
end;

for i = 2:a 
    if demandCheck(1,1) == 1
       	intv(1,1) = 1; else 
 		intv(1,1) = 0
	end;

	if (demandCheck(1,i) == 1) && (demandCheck(1,i-1) == 1)
		intv(1,i) = 1;
    elseif (demandCheck(1,i) == 1) && (demandCheck(1,i-1) == 0)
		intv(1,i) = (cumZD(1,i-1)+1); else
		intv(1,i) = 0
    end;

    sumIntv = cumsum(intv)
end;

t = max(sumIntv)
ADI = t / numDemand

miu = mean2(demand);
sd = std(demand,1);
CV = sd/miu
minimal = min(demand)
maksimal = max(demand)

if (ADI > 1.32) && (CV < 0.49)
	cl = 'Intermittent';
elseif (ADI > 1.32) && (CV > 0.49)
	cl = 'Lumpy';
elseif (ADI < 1.32) && (CV > 0.49)
	cl = 'Erratic';
else cl = 'Slow';
end;

b = [1:a];
g = line(b, demand, 'LineStyle', ':');
g.marker = '+';

L = str2num(get(handles.leadtime,'String'));
K = str2num(get(handles.ordering,'String'));
h = str2num(get(handles.holding,'String'));
p = str2num(get(handles.backorder,'String'));

L = L/12;   


miuL = (L+1)*miu
sdL = sd*sqrt(L+1)

% Step 1
% compute Dp units

Dp = (1.3*(miu^0.494))*((K/(h))^0.506)*(1+((sdL^2)/(miu^2)))^0.116;

% compute z
z = sqrt((Dp/((sdL*p)/h)));

% calculate sp
sp = 0.973*miuL +sdL*((0.183/z)+1.063-2.192*z);

% Step 2
if Dp/miu > 1.5
	s = sp;
	S = sp + Dp;
else
	% Go to the step 3
	% compute So
	v = (-p - h) / ((exp(2))*sqrt(2*pi*p));
	So = (L+1)*miu + v*sdL;
	s = min(sp,So);
	S = min(sp+Dp,So);
end;

if s < 0 
	s = 0;
end;

set(handles.adi, 'String', num2str(ADI, '%.3f'));
set(handles.cv, 'String', num2str(CV, '%.3f'));
set(handles.deviation, 'string', num2str(sd, '%.3f'));
set(handles.mean, 'String', num2str(miu, '%.3f'));
set(handles.minimal, 'String', minimal);
set(handles.maksimal, 'String', maksimal);
set(handles.count, 'String', numDemand);
set(handles.total, 'String', total);
set(handles.cls, 'String', cl);

set(handles.rop,'String',round(s));
set(handles.maximuminv,'String',round(S));

axes(handles.eoq);
cla;
title('EOQ GRAPHIC');
xlabel('Demand');
ylabel('Cost');

EOQ = sqrt((2*total*K)/h * ((p+h)/p))
Q = (EOQ-20):(EOQ+20)

S = EOQ * (h/(h+p))

TO = (total./Q)*K; 
TC = h .* ((Q-S).^2)./ (2.*Q);
TP = p*(S^2)./(2.*Q);
TI = TO + TC + TP;

TOO = (total/EOQ)*K
TCO = h * ((EOQ-S)^2)/ (2*EOQ)
TPO = p*(S^2)/(2*EOQ)
TIO = TOO + TCO + TPO

A = [EOQ EOQ];
B = [0 TIO];
C = [0 EOQ];
D = [TIO TIO];


plot(Q, TO, Q, TC, Q, TP, Q, TI, Q, TP);
zoom on
vline = line(A, B, 'LineStyle','--');
hline = line(C, D, 'LineStyle','--');
set(hline,'Color','k');
set(vline,'Color','k');

R = EOQ/miu;
set(handles.periodic,'String', num2str(R, '%.3f'));


function adi_Callback(hObject, eventdata, handles)
% hObject    handle to adi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of adi as text
%        str2double(get(hObject,'String')) returns contents of adi as a double


% --- Executes during object creation, after setting all properties.
function adi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to adi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function cv_Callback(hObject, eventdata, handles)
% hObject    handle to cv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cv as text
%        str2double(get(hObject,'String')) returns contents of cv as a double


% --- Executes during object creation, after setting all properties.
function cv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cls_Callback(hObject, eventdata, handles)
% hObject    handle to cls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cls as text
%        str2double(get(hObject,'String')) returns contents of cls as a double


% --- Executes during object creation, after setting all properties.
function cls_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4



function mean_Callback(hObject, eventdata, handles)
% hObject    handle to mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mean as text
%        str2double(get(hObject,'String')) returns contents of mean as a double


% --- Executes during object creation, after setting all properties.
function mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function deviation_Callback(hObject, eventdata, handles)
% hObject    handle to deviation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deviation as text
%        str2double(get(hObject,'String')) returns contents of deviation as a double


% --- Executes during object creation, after setting all properties.
function deviation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deviation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minimal_Callback(hObject, eventdata, handles)
% hObject    handle to minimal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minimal as text
%        str2double(get(hObject,'String')) returns contents of minimal as a double


% --- Executes during object creation, after setting all properties.
function minimal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minimal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maksimal_Callback(hObject, eventdata, handles)
% hObject    handle to maksimal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maksimal as text
%        str2double(get(hObject,'String')) returns contents of maksimal as a double


% --- Executes during object creation, after setting all properties.
function maksimal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maksimal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function total_Callback(hObject, eventdata, handles)
% hObject    handle to total (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of total as text
%        str2double(get(hObject,'String')) returns contents of total as a double


% --- Executes during object creation, after setting all properties.
function total_CreateFcn(hObject, eventdata, handles)
% hObject    handle to total (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function count_Callback(hObject, eventdata, handles)
% hObject    handle to count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of count as text
%        str2double(get(hObject,'String')) returns contents of count as a double


% --- Executes during object creation, after setting all properties.
function count_CreateFcn(hObject, eventdata, handles)
% hObject    handle to count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function review_Callback(hObject, eventdata, handles)
% hObject    handle to review (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of review as text
%        str2double(get(hObject,'String')) returns contents of review as a double


% --- Executes during object creation, after setting all properties.
function review_CreateFcn(hObject, eventdata, handles)
% hObject    handle to review (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function leadtime_Callback(hObject, eventdata, handles)
% hObject    handle to leadtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of leadtime as text
%        str2double(get(hObject,'String')) returns contents of leadtime as a double


% --- Executes during object creation, after setting all properties.
function leadtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leadtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ordering_Callback(hObject, eventdata, handles)
% hObject    handle to ordering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ordering as text
%        str2double(get(hObject,'String')) returns contents of ordering as a double


% --- Executes during object creation, after setting all properties.
function ordering_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ordering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function holding_Callback(hObject, eventdata, handles)
% hObject    handle to holding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of holding as text
%        str2double(get(hObject,'String')) returns contents of holding as a double


% --- Executes during object creation, after setting all properties.
function holding_CreateFcn(hObject, eventdata, handles)
% hObject    handle to holding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function backorder_Callback(hObject, eventdata, handles)
% hObject    handle to backorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of backorder as text
%        str2double(get(hObject,'String')) returns contents of backorder as a double


% --- Executes during object creation, after setting all properties.
function backorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function maximuminv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maximuminv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function periodic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to periodic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function rop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function demandGraph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to demandGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate demandGraph


% --- Executes during object creation, after setting all properties.
function periodicRGraph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to periodicRGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate periodicRGraph


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str2double(set(handles.demand, 'String', {}));
% str2double(set(handles.tabeldemand, 'String'));
str2double(set(handles.leadtime, 'String'));
% set(handles.ordering, 'String', '');
% set(handles.holding, 'String', '');
% set(handles.backorder, 'String', '');
% set(handles.adi, 'String', '');
% set(handles.cv, 'String', '');
% set(handles.cl, 'String', '');
% set(handles.mean, 'String', '');
% set(handles.deviation, 'String', '');
% set(handles.minimal, 'String', '');
% set(handles.maksimal, 'String', '');
% set(handles.numDemand, 'String', '');
% set(handles.count, 'String', '');
% set(handles.periodic, 'String', '');
% set(handles.rop, 'String', '');
% set(handles.maximumInv, 'String', '');
cla(handles.demandGraph, 'reset');
cla(handles.eoq, 'reset');


% --------------------------------------------------------------------
function uitoggletool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uitoggletool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function simulate_Callback(hObject, eventdata, handles)
% hObject    handle to simulate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulate as text
%        str2double(get(hObject,'String')) returns contents of simulate as a double


% --- Executes during object creation, after setting all properties.
function simulate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

simulate = get(handles.simulate, 'String');
demand = str2double(get(handles.tabeldemand, 'Data'));
L = str2double(get(handles.leadtime, 'string'))
R = str2double(get(handles.periodic, 'String'))
s = str2double(get(handles.rop, 'String'))
S = str2double(get(handles.maximuminv, 'String'))

L = L*1
R = R*1
s = s*1
S = S*1

value = unique(demand)
frequency = histc(demand, value)
a = size(value);
c = a(1,1)

aa = get(handles.demand, 'String')

cumFreq(1) = frequency(1)
for i = 2:c
	cumFreq(i) = cumFreq(i-1) + frequency(i);
end;
cumFreq = transpose(cumFreq)

cumProb = cumFreq ./ 12
% cumProb = str2double(cumProb);

temp = round(cumProb*100)

rentang = [0:(temp(1)-1)];
rngMIN = min(rentang);
rngMAX = max(rentang);

for i = 2:c
	rentang = [temp(i-1):(temp(i)-1)];
	rngMIN = [rngMIN; min(rentang)];
	rngMAX = [rngMAX; max(rentang)];
end;

rng = [rngMIN, rngMAX]

initialStock = 3;
finalStock = initialStock;

quantity = S - s;
orderPeriod = 1;
receipt = L + 1;
%qR(receipt) = quantityOrder

leadtime = L;
for i = 2:12
	bulan(i) = i;
	
	initialStock(i) = finalStock(i-1);
	x(i) = rand;
	x(i) = x(i) * 100;

	j = find ( (x(i) >= rngMIN) & (x(i) <= rngMAX) )

	dmnd(i) = value(j);
	if initialStock(i) - dmnd(i) < 0
		shortage(i) = abs(initialStock(i)-dmnd(i));
	else 
		shortage(i) = 0;
	end; 

	check = 0;
	finalStock(i) = initialStock(i) - dmnd(i);
	if ((finalStock(i) <= s) | (mod(i,R) == 0) & (check == 0));
		quantity = [quantity,  quantity]
		orderPeriod = [orderPeriod, i]
		quantityOrder(orderPeriod) = quantity

		leadtime = [leadtime; L];
		check = not(check);
	end;


	if finalStock(i) < 0 
		finalStock(i) = 0;
	end;

	receipt = L + i;
	qR(receipt) = quantityOrder(i);

	if i == receipt
		check = not(check);
	end;

end;

initialStock = transpose(initialStock)
x = transpose(x)
dmnd = transpose(dmnd)
shortage = transpose(shortage)
qR = transpose(qR)
finalStock = transpose(finalStock);
quantityOrder = transpose(quantityOrder)
leadtime = transpose(leadtime);

% fprintf('Value %.2f', 'Freq %.2f', 'cumFreq %.2f', 'cumProb %.2f', 'Range %.2f\n', value, frequency, cumFreq, cumProb, rng);
% fprintf('Bulan', 'IS', 'RN', 'Demand', 'SH', 'QR', 'FS', 'QO', 'L', bulan, initialStock, x, dmnd, shortage, qR, finalStock, quantityOrder, leadtime);

tabelsimulasi = [value, frequency, cumFreq, cumProb, rng]
montecarlo = [initialStock, x, dmnd, shortage, finalStock]

% set(handles.simulasi, 'Data', tabelsimulasi);
% set(handles.montecarlo, 'Data', montecarlo);
