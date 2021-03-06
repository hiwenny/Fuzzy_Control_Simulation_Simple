% Moving target and chaser car simulation.
% For demonstrating the use of fuzzy control in steering.
% Wenny Hidayat

function Fuzzy_Control()
close all
clear all

% Handles for plotting
figure(1) ; clf ;  hold on ;
handleCar.shape = plot(0,0,'b');
handleCar.centroid = plot(0,0,'c');
handleCar.target = plot(0,0,'or');
xlabel('x (m)'); ylabel('y (m)'); axis([-20, 20, -20, 20]) ; zoom on ; hold off;
title('Global Frame');

% Defining car shape
% Car.shape = [-0.5,-0.5 ; 0,0.5 ; 0.5,-0.5 ; -0.5,-0.5]; %triangle
Car.shape = [-0.25 -0.5; -0.25 0; 0 1; 0.25 0; 0.25 -0.5; -0.25 -0.5]; % pentagon
Car.shapeDefault = Car.shape;
Car.center = [mean(Car.shape(1:5,1)) mean(Car.shape(1:5,2))];
Car.centerDefault = Car.center;
Car.heading = atan2(Car.shape(2,2)-Car.center(2), Car.shape(2,1)-Car.center(1)); %in rad

% Defining target x y
target = [10 10];

% Loop (simulation)
% Initialization
dt=0.3;
iterations = 1000;
% vel = rand(1,iterations);
% ang_vel = rand(1,iterations)*50*pi/180;

for i=1:iterations
    
    % Control fuzzy
    % Distance is a straight line between car centroid and targe's centroid
    % Angle is the difference between current car heading and angle
    % calculated from the new distance.
    fis = readfis('Control_new.fis');
    distance = sqrt( (target(1)-Car.center(1))^2 + (target(2)-Car.center(2))^2 );   
    angle = atan2(target(2)-Car.center(2), target(1)-Car.center(1)) - Car.heading;
    angle = mod(  angle+pi, 2*pi) - pi;
    
%     if distance < 0.1
%         break;
%     end;
    
    inputs = [distance angle];
    [outputs] = evalfis(inputs, fis);

%     rotation = [cos -sin] + posn
%                [sin  cos]

    [Car.shape(:,1), Car.shape(:,2), Car.heading ]= moveModel(Car.shape(:,1), Car.shape(:,2), Car.heading, dt, outputs(1), outputs(2));
    Car.center = [mean(Car.shape(1:5,1)) mean(Car.shape(1:5,2))];
    trackCar(i,:) = Car.center;
    
    % Rotate THEN translate
    % From local frame to global x y.
    local_to_global_Map_X = cos(Car.heading-pi/2)*Car.shapeDefault(:,1) - sin(Car.heading-pi/2)*Car.shapeDefault(:,2) + Car.center(1) ;
    local_to_global_Map_Y = sin(Car.heading-pi/2)*Car.shapeDefault(:,1) + cos(Car.heading-pi/2)*Car.shapeDefault(:,2) + Car.center(2);
    


    % Set graphic handles 
    set(handleCar.centroid,'xdata',trackCar(:,1),'ydata',trackCar(:,2) ); 
    set(handleCar.shape,'xdata',local_to_global_Map_X,'ydata',local_to_global_Map_Y );
    set(handleCar.target,'xdata',target(1),'ydata',target(2) );
    pause(0.1) ;
    % Defining the target movement
    % Can be any
    if target(1)<=20 && target(1)>=-20 && target(2) <=20 && target(2)>=-20,
        target(1) = target(1)+2*(rand(1)-rand(1));
        target(2) = target(2)+2*(rand(1)-rand(1));
    else
        % To reset back into boundary
        target = [-5 -5];
    end;
end;


% Function for updating the car, changing the location of each points
function [xnext, ynext, tnext] = moveModel(x,y,theta,dt,velocity,ang_velocity)
    xnext = x + velocity*dt*cos(theta);
    ynext = y + velocity*dt*sin(theta);
    tnext= theta + ang_velocity*dt;
return;

