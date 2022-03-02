%% define constants
q = 1.602e-019      % charge of electron
k = 1.38e-023       % boltzman constant
n = 1.2             % ideality factor
T = 300             % temperature in Kelvin
Isc_stc = 9.15      % short circuit current under standard test condition
Voc_stc = .6        % open circuit voltage under standard test condition
T_stc = 25+273      % standard test condition temperature in kelvin
Ki = .003756        % temperture coefficient of current
Rs = .001           % series resistance
Rsh = 500           % shunt resistance
Eg0 = 1.1557        % reference bandgap
alp = 7.021e-004    % alpha value for silicon bandgap equation
bet = 1108          % beta value for silicon bandgap equation
day = 182           % day out of 365
lat = 39.0473       % latitude in degrees
S = 1368            % solar constant
TltAngl = 30         % tilt angle

%% write equations and define for loop variables
Is_stc = (Isc_stc)/((exp((q*Voc_stc)/(n*k*T_stc)))-1)                   % standard saturation current 
Eg = Eg0 - (alp*T^2)/(T + bet)                                          % bandgap equation 
Is = Is_stc*((T/T_stc)^3)*exp(((q*Eg)/(n*k))*((1/T_stc)-(1/T)))         % saturation current
DecAngl = 23.45*sind((360/365)*(284 + day))                             % calculate declination angle

% outer for loop variables
VoT = {}
IoT = {}
index2 = 1

% inner for loop variables
Vo = []
Io = []
Po = []
index1 = 1
I = 0
Irr = 0
zen = 0

%% perform iterations
for hour = 10:1:17
    
    HrAngl = 15*( hour - 12)                                               % calculate hour angle
    zen = acosd(sind(lat)*sind(DecAngl)+ cosd(lat)*cosd(DecAngl)*cosd(HrAngl))
    Irr = 1368*sind(90 - zen - TltAngl)
    Isc = (Isc_stc + Ki*(T-T_stc))*(Irr/1000)                              % calculate short circuit current

        for V = 0:.001:.7
            I = Isc - Is*((exp((q*(V+Rs*I))/(n*k*T)))-1)-((V+I*Rs)/Rsh)    % current equation
            Vo(index1) = V
            Io(index1) = I
            Po(index1) = V*I
            index1 = index1 + 1
                if I < 0 
                    break
                end
        end
   
    VoT{index2} = Vo
    IoT{index2} = Io
    PoT{index2} = Po
    index2 = index2 + 1
    
    Vo = [0]
    Io = [0]
    Po = [0]
    index1 = 1
    I = 0
    
end

%% plot IV and PV characteristics 

index3 = 1
lim = index2
for index3 = 1:1:lim
    hold on
    %I-V curve
    figure(1)
    plot(VoT{index3},IoT{index3})
    xlim([0 .7])
    ylim([0 10])
    xlabel('Voltage (V)')
    ylabel('Current (A)')
    title('Current-Voltage Characteristics')
    legend('I-V Curve 10am', 'I-V Curve 11am', 'I-V Curve 12pm', 'I-V Curve 1pm', 'I-V Curve 2pm', 'I-V Curce 3pm', 'I-V Curve 4pm', 'I-V Curve 5pm', 'I-V Curve 6pm', 'I-V Curve 7pm')
    
    %P-V curve
    figure(2)
    plot(VoT{index3},PoT{index3})
    xlim([0 .7])
    ylim([0 6])
    xlabel('Voltage (V)')
    ylabel('Power (W)')
    title('Power-Voltage Characteristics')
    legend('P-V Curve 10am', 'P-V Curve 11am', 'P-V Curve 12pm', 'P-V Curve 1pm', 'P-V Curve 2pm', 'P-V Curce 3pm', 'P-V Curve 4pm', 'P-V Curve 5pm', 'P-V Curve 6pm', 'P-V Curve 7pm')
    
end
hold off
