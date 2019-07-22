function q_3=P_pronk(q_0,u_0)
%% 
g=9.81;                         %gravity acceleration 
k=3520;                         %spring constant
m=20.865;                        %torso mass
l_0=0.323;                      %rest length of leg
                          %damping constant


%angle the model hold at beginning
%0.146225*pi
  %initial conditions [y theta xdot ydot]

options_stance = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_stance); 
options_flight_1 = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_flight_1);
options_flight_2 = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_flight_2);

time= 60;

%% 
  
   %start at flight phase(terminate at touchdown event)
   [t,q,~,~,events_flight_1] =ode45(@flight_motion, [0,time] , ...
       [q_0(1) q_0(2) 0], options_flight_1);
   time =time - t(end);
   q_1=[q(end,1) ,q(end,2),q(end,3)];
   %[From apex to touchdown]  Proceed to stance phase
   if events_flight_1 == 1
       %get initial conditions from the termination event of flight phase
       rdot_touchdown=-sin(u_0)*q_1(2)+cos(u_0)*q_1(3);
       thetadot_touchdown=(-cos(u_0)*q_1(2)-sin(u_0)*q_1(3))/l_0;
       
    [t,q,~,~,events_stance] =ode45(@stance_motion, [0,time] ,...
        [l_0  u_0  rdot_touchdown  thetadot_touchdown], options_stance);
    q_2=[ q(end,1),q(end,2),q(end,3),q(end,4)];
    time = time - t(end);
       %get initial conditions from the termination event of stance phase
       
       y_liftoff = l_0*cos(q_2(2));
       xdot_liftoff = -sin(q_2(2))*q_2(3)-l_0*cos(q_2(2))*q_2(4);
       ydot_liftoff =cos(q_2(2))*q_2(3) - l_0*sin(q_2(2))*q_2(4);
    
    %[From take-off to apex]   Proceed to flight phase(terminate at apex height)
           if events_stance == 1
        [~,q,~,~,~] =ode45(@flight_motion, [0,time] ,...
            [y_liftoff    xdot_liftoff    ydot_liftoff ], options_flight_2);
         q_3=[ q(end,1),q(end,2)];
           end
    
    end
%% 

function dqdt=flight_motion(~,q)
%q=[y;xdot;ydot]
%dqdt=[ydot;xddot;yddot]
dqdt_1=q(3);
dqdt_2=0;
dqdt_3=-g;

dqdt=[dqdt_1;dqdt_2;dqdt_3];

end


function dqdt=stance_motion(~,q)
%q=[l ; phi ; ldot ; phidot]
%dqdt=[ldot ; phidot ; lddot  ; phiddot]

dqdt_1=q(3);
dqdt_2=q(4);
dqdt_3=(2*(k/m))*(l_0-q(1))-g*cos(q(2))+q(1)*q(4)^2 ;%  - (2*(b/m))*q(3);
dqdt_4=(g*sin(q(2)))/q(1)-(2*q(3)*q(4))/q(1);


dqdt=[dqdt_1;dqdt_2;dqdt_3;dqdt_4];

end


%% 

function [value,isterminal,direction] = end_flight_1(~,q)
	%%Event 1 touchdown condition: 'y_touchdown' - 'r_0*cos(angle_of_attack)' =0;
    %%Event 2 fall down(point mass touch ground)
		value = [ q(1)-cos(u_0)*l_0,q(1),q(2)];
		isterminal = [ 1,1,1];
		direction =  [-1,-1,-1];
end


function [value,isterminal,direction] = end_flight_2(~,q)
	%%Event 1 reach apex height
		value = q(3);
		isterminal =1;
		direction = -1;
end



function [value,isterminal,direction] = end_stance(~,q)
    %%Event 1 takeoff condition
    %%Event 2 point mass touch ground
    %%Event 3 point mass touch ground
		value = [l_0-q(1),q(2)-pi/2,q(3),q(4)];
		isterminal = [1,1,1,1];
		direction = [-1,-1,-1,1];
end


end
