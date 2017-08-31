function varargout = SATUFC(varargin)
% SATUFC MATLAB code for SATUFC.fig
%      SATUFC, by itself, creates a new SATUFC or raises the existing
%      singleton*.
%
%      H = SATUFC returns the handle to a new SATUFC or the handle to
%      the existing singleton*.
%
%      SATUFC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SATUFC.M with the given input arguments.
%
%      SATUFC('Property','Value',...) creates a new SATUFC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SATUFC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SATUFC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SATUFC

% Last Modified by GUIDE v2.5 21-Jul-2017 13:21:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SATUFC_OpeningFcn, ...
                   'gui_OutputFcn',  @SATUFC_OutputFcn, ...
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


% --- Executes just before SATUFC is made visible.
function SATUFC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SATUFC (see VARARGIN)
filename = 'localizacoes.xls';
[dadosLoc, localizacao] = xlsread(filename, '', '', 'basic');
set(handles.listLoc, 'String', localizacao); 
global DADOSLOC;
DADOSLOC = dadosLoc;

filename1 = 'satelites.xls';
[dadosSat, satelites] = xlsread(filename1, '', '', 'basic');
set(handles.listSat, 'String', satelites); 
global DADOSSAT;
DADOSSAT = dadosSat;

% Choose default command line output for SATUFC
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SATUFC wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = SATUFC_OutputFcn(hObject, eventdata, handles) 
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

    %
    % GEOMETRIA DO ENLACE
    %
    global DADOSLOC;
    dadosLoc = DADOSLOC;
    global DADOSSAT;
    dadosSat = DADOSSAT;
    global INDEX;
    indexLoc = INDEX;
    global INDEXSAT;
    indexSat = INDEXSAT;
    latET = dadosLoc(indexLoc, 1); 
    longET = dadosLoc(indexLoc, 2);
    longSAT = dadosSat(indexSat, 1);

    %Calculo angulo azimute
    delta = longET-longSAT;
    az = atand( tand(abs(delta))/sind(latET) ); 

    %Calculo Angulo Elevacao
    r = 6375; % m
    h = 35786000;    % m
    o = acosd( cosd(delta)*cosd(latET) );
    
    elv = atand(( cosd(o)-(r/(r-h)) )/sind(o) ); % Angulo de elevacao

    %Calculo distancia
    d = sqrt((r+h)^2 + r^2 - 2*r*(r+h)*cosd(delta)*cosd(latET)); % Distancia da ET e o satelite
    d = d/10^3; %Transforma para Km
    
    %Resultados
    set(handles.azimute, 'String', az);
    set(handles.angel, 'String', elv);
    set(handles.distancia, 'String', d);
    
    %
    % DADOS GERAIS
    %
    lbo = str2double(get(handles.lbo, 'String'));
    ldp = str2double(get(handles.ldp, 'String'));
    
    %
    % ENLACE DE SUBIDA
    %
    FSat = str2double(get(handles.FSat, 'String')); %Figura de ruido em dB
    FSat = 10^(FSat/10); % Transforma pra não ser em dB
    lconSat = str2double(get(handles.lconSat, 'String')); %Perdas por conectores em dB
    lconSat = 10^(lconSat/10);% Transforma pra não ser em dB
    Ptx = str2double(get(handles.Ptx, 'String')); %Potencia em W
    
    TaSat = str2double(get(handles.TaSat, 'String')); %Temperatura de ruido da antena do satelite
    
    
    FrET = str2double(get(handles.FrET, 'String')); % Frequencia Hz
    FrET = FrET*10^9; %transformando pra GHz
    FrSat = str2double(get(handles.FrSat, 'String'));
    FrSat = FrSat*10^9;   
    
    c = 3*10^8; % Velocidade da onda = velocidade da luz

    %Ganho da antena transmissora
    effET = str2double(get(handles.effET, 'String'));
    dET = str2double(get(handles.dET, 'String')); % diametro da antena da ET
    
    lambdaET = c/FrET; % MHz 
    GET = 10*log10(effET*((pi*dET)/lambdaET)^2); % dBi
    
    %Ganho da antena receptora
    effSat = str2double(get(handles.effSat, 'String'));
    dSat = str2double(get(handles.dSat, 'String'));
    
    lambdaSat = c/FrSat;
    GSat = 10*log10(effSat*((pi*dSat)/lambdaSat)^2); % dBi
    
    %Temperatura da antena
%     TaSub = 15 + 30/dET + 180/elv; % Kelvin
     
    %Temperatura do ruido
    TeSat = 290*(FSat-1) ; %Kelvin
    
    %Temperatura do sistema
    TsSat = TaSat/lconSat + 290*(1-(1/lconSat)) + TeSat; % Kelvin
    
    %Figura de merito
    GTSat = GSat - 10*log10(TsSat) - lbo; % dB
    
    %Perda por espaço livre
    pel = 10*log10((4*pi*d*10^3/lambdaET)^2); % dB
    
    %PIRE
    pire = 10*log10(Ptx) - ldp - lconSat + GET; % dB
    
    % Perdas totais
    ltotal = lbo + 10*log10(lconSat) + ldp + pel; %dB
    
    %C/No
    K = 1.38*(10^-23) ; %constante de boltzman
    CNo = pire - ltotal + GTSat - 10*log10(K);  %dB
    
    %Resutados
    set(handles.GET, 'String', GET);
    set(handles.TaSub, 'String', TaSat);
    set(handles.TeSub, 'String', TeSat);
    set(handles.TsSub, 'String', TsSat);
    set(handles.GTSat, 'String', GTSat);
    set(handles.pel, 'String', pel);
    set(handles.pire, 'String', pire);
    set(handles.ltotal, 'String', ltotal);
    set(handles.CNo, 'String', CNo);
    
    
    %
    % ENLACE DE DESCIDA
    %

    TaET = str2double(get(handles.TaET, 'String'));
    lconET = str2double(get(handles.lconET, 'String')); % dB
    lconET = 10^(lconET/10);
    FET = str2double(get(handles.FET, 'String')); % dB
    FET = 10^(FET/10); 
    PtxSat = str2double(get(handles.PtxSat, 'String'));

    
    %Temperatura da antena
%     TaDesc = 15 + 30/dSat + 180/elv; % Kelvin
     
    %Temperatura do ruido
    TeET = 290*(FET-1) ; %Kelvin
    
    %Temperatura do sistema
    TsET = TaET/lconET + 290*(1-(1/lconET)) + TeET; % Kelvin
    
    %Figura de merito
    GTET = GET - 10*log10(TsET) - lbo; % dB
    
    %Perda por espaço livre
    pelSat = 10*log10((4*pi*d*10^3/lambdaSat)^2); % dB
    
    %PIRE
    pireSat = 10*log10(PtxSat) - ldp - lconET + GSat; % dB
    
    % Perdas totais
    ltotalSat = lbo + 10*log10(lconET) + ldp + pelSat; %dB
    
    %C/No
    CNoSat = pireSat - ltotalSat + GTET - 10*log10(K);  %dB
    
    set(handles.GSat, 'String', GSat);
    set(handles.TaDesc, 'String', TaET);
    set(handles.TeDesc, 'String', TeET);
    set(handles.TsDesc, 'String', TsET);
    set(handles.GTET, 'String', GTET);
    set(handles.pelSat, 'String', pelSat);
    set(handles.pireSat, 'String', pireSat);
    set(handles.ltotalSat, 'String', ltotalSat);
    set(handles.CNoSat, 'String', CNoSat);
    
    %
    % C/No TOTAL
    %
    % CNoInt = str2double(get(handles.CNoInt, 'String'));
    CNoTotal = 10*log10(1/(1/10^(CNo/10) + 1/10^(CNoSat/10)));
    set(handles.CNoTotal, 'String', CNoTotal);
    
        
    
    
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ldp_Callback(hObject, eventdata, handles)
% hObject    handle to ldp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ldp as text
%        str2double(get(hObject,'String')) returns contents of ldp as a double


% --- Executes during object creation, after setting all properties.
function ldp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ldp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lconET_Callback(hObject, eventdata, handles)
% hObject    handle to lconET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lconET as text
%        str2double(get(hObject,'String')) returns contents of lconET as a double


% --- Executes during object creation, after setting all properties.
function lconET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lconET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lbo_Callback(hObject, eventdata, handles)
% hObject    handle to lbo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lbo as text
%        str2double(get(hObject,'String')) returns contents of lbo as a double


% --- Executes during object creation, after setting all properties.
function lbo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freqSAT_Callback(hObject, eventdata, handles)
% hObject    handle to freqSAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqSAT as text
%        str2double(get(hObject,'String')) returns contents of freqSAT as a double


% --- Executes during object creation, after setting all properties.
function freqSAT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqSAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FSat_Callback(hObject, eventdata, handles)
% hObject    handle to FSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FSat as text
%        str2double(get(hObject,'String')) returns contents of FSat as a double


% --- Executes during object creation, after setting all properties.
function FSat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tasat_Callback(hObject, eventdata, handles)
% hObject    handle to tadesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tadesc as text
%        str2double(get(hObject,'String')) returns contents of tadesc as a double


% --- Executes during object creation, after setting all properties.
function Tasat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tadesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    
    
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ptx_Callback(hObject, eventdata, handles)
% hObject    handle to text333 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text333 as text
%        str2double(get(hObject,'String')) returns contents of text333 as a double


% --- Executes during object creation, after setting all properties.
function text333_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text333 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dET_Callback(hObject, eventdata, handles)
% hObject    handle to dET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dET as text
%        str2double(get(hObject,'String')) returns contents of dET as a double


% --- Executes during object creation, after setting all properties.
function dET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to ldp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ldp as text
%        str2double(get(hObject,'String')) returns contents of ldp as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ldp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text53_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function effET_Callback(hObject, eventdata, handles)
% hObject    handle to effET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of effET as text
%        str2double(get(hObject,'String')) returns contents of effET as a double


% --- Executes during object creation, after setting all properties.
function effET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to effET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PtxSat_Callback(hObject, eventdata, handles)
% hObject    handle to PtxSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PtxSat as text
%        str2double(get(hObject,'String')) returns contents of PtxSat as a double


% --- Executes during object creation, after setting all properties.
function PtxSat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PtxSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dSat_Callback(hObject, eventdata, handles)
% hObject    handle to dSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dSat as text
%        str2double(get(hObject,'String')) returns contents of dSat as a double


% --- Executes during object creation, after setting all properties.
function dSat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrSat_Callback(hObject, eventdata, handles)
% hObject    handle to FrSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrSat as text
%        str2double(get(hObject,'String')) returns contents of FrSat as a double


% --- Executes during object creation, after setting all properties.
function FrSat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function effSat_Callback(hObject, eventdata, handles)
% hObject    handle to effSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of effSat as text
%        str2double(get(hObject,'String')) returns contents of effSat as a double


% --- Executes during object creation, after setting all properties.
function effSat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to effSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listLoc.
function listLoc_Callback(hObject, eventdata, handles)
% hObject    handle to listLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listLoc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listLoc
    index = get(handles.listLoc, 'value');
    global INDEX;
    INDEX = index;
    


% --- Executes during object creation, after setting all properties.
function listLoc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global INDEX;
    index = INDEX;
    global DADOSLOC;
    dadosLoc = DADOSLOC;
    
    latET = dadosLoc(index, 1);
    longET = dadosLoc(index, 2);
    
    set(handles.latET, 'String', latET);
    set(handles.longET, 'String', longET); 


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global INDEXSAT;
    indexSat = INDEXSAT;
    global DADOSSAT;
    dadosSat = DADOSSAT;
    
    longSAT = dadosSat(indexSat, 1);
    set(handles.longSAT, 'String', longSAT); 


% --- Executes on selection change in listSat.
function listSat_Callback(hObject, eventdata, handles)
% hObject    handle to listSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listSat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listSat
    indexSat = get(handles.listSat, 'value');
    global INDEXSAT;
    INDEXSAT = indexSat;


% --- Executes during object creation, after setting all properties.
function listSat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Ptx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ptx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrET_Callback(hObject, eventdata, handles)
% hObject    handle to FrET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrET as text
%        str2double(get(hObject,'String')) returns contents of FrET as a double


% --- Executes during object creation, after setting all properties.
function FrET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CNoInt_Callback(hObject, eventdata, handles)
% hObject    handle to CNoInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CNoInt as text
%        str2double(get(hObject,'String')) returns contents of CNoInt as a double


% --- Executes during object creation, after setting all properties.
function CNoInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CNoInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TaET_Callback(hObject, eventdata, handles)
% hObject    handle to TaSub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TaSub as text
%        str2double(get(hObject,'String')) returns contents of TaSub as a double


% --- Executes during object creation, after setting all properties.
function TaSub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TaSub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FET_Callback(hObject, eventdata, handles)
% hObject    handle to FET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FET as text
%        str2double(get(hObject,'String')) returns contents of FET as a double


% --- Executes during object creation, after setting all properties.
function FET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TaSat_Callback(hObject, eventdata, handles)
% hObject    handle to TeDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TeDesc as text
%        str2double(get(hObject,'String')) returns contents of TeDesc as a double


% --- Executes during object creation, after setting all properties.
function TeDesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TeDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lconSat_Callback(hObject, eventdata, handles)
% hObject    handle to lconSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lconSat as text
%        str2double(get(hObject,'String')) returns contents of lconSat as a double


% --- Executes during object creation, after setting all properties.
function lconSat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lconSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function TaDesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TaDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function TaET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TaET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function TaSat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TaSat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
