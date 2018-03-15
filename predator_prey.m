function engn40_project2
   close all
mr = 18e-03; % Mass of predator, in kg
my = 10.e-03; % Mass of prey, in kg
Frmax = 15e-03; % Max force on predator, in Newtons
Fymax = 10.e-03; % Max force on prey, in Newtons
c = 1.e-03; % Viscous drag coeft, in N s/m
Er0 = 10; % Initial energy of predator, in J
Ey0 = 10; % Initial energy of prey, in J
initial_w = [50,0,0,0,0,0,0,0,Er0,Ey0]; % Initial position/velocity
force_table_predator = rand(251,2)-0.5;
force_table_prey = rand(251,2)-0.5;
   options = odeset('Event',@event,'RelTol',0.00001);
   [time_vals,sol_vals] = ode45(@(t,w) ...
eom(t,w,mr,my,Frmax,Fymax,c,force_table_predator,force_table_prey),[0:1:250],initial_w,options);

   animate_projectiles(time_vals,sol_vals);



 end
function dwdt = eom(t,w,mr,my,Frmax,Fymax,c,forcetable_r,forcetable_y)
% Extract the position and velocity variables from the vector w
% Note that this assumes the variables are stored in a particular order in w.
pr=w(1:2); vr=w(5:6); py=w(3:4); vy=w(7:8); Er=w(9); Ey=w(10);
% Compute all the forces on the predator
amiapredator = true;
Fr = compute_f_young(t,Frmax,Fymax,amiapredator,pr,vr,py,vy,Er,Ey);
Frrand = compute_random_force(t,forcetable_r);
Frvisc = -vr*c;
dErdt = -dot(Fr,vr);
Frtotal = Fr + Frrand+Frvisc;
% Write similar code below to call your compute_f_young function to
% compute the force on the prey, determine the random forces on the prey,
% and determine the viscous forces on the prey

amiapredator = false;
Fy = compute_f_young(t,Frmax,Fymax,amiapredator,pr,vr,py,vy,Er,Ey);
Fyrand = compute_random_force(t,forcetable_y);
Fyvisc = -vy*c;
Fytotal = Fy+Fyrand+Fyvisc;
dEydt = -dot(Fy,vy);
dwdt = [vr;vy;Frtotal/mr;Fytotal/my;dErdt;dEydt];
end
function [event,stop,direction] = event(t,w)
% Event function to stop calculation when predator catches prey
% Write your code here... For the event variable, use the distance between
% predator and prey. You could add other events to detect when predator/prey leave % the competition area as well. See the MATLAB manual for how to detect and
% distinguish between multiple events if you want to do this
pr=w(1:2); vr=w(5:6); py=w(3:4); vy=w(7:8); Er=w(9); Ey=w(10);
dist = sqrt(dot((py-pr),(py-pr)));
event = dist-1;
stop = 1;
direction = 0;
end
function F = compute_f(t,Frmax,Fymax,amiapredator,pr,vr,py,vy,Er,Ey) % Write your code to compute the forces below. This will be the function
% that you must submit to the competition. You don?t need to submit the rest
% of the code ? that?s just for test purposes
if(amiapredator)

    if norm(py-pr) > 20
        alpha = 10;
    else
        alpha = 5;
    end

    dirvec = py-pr + alpha*(vy - vr);
    dirvec = dirvec / norm(dirvec);
    if abs(pr-py) < 5 %If it's close enough go straight for the prey.
        dirvec = py-pr;
    else
        dirvec = py-pr + alpha*(vy - vr);
    end


     F = Frmax * dirvec;

else % I'm a prey
if(t == 249)
disp('play wins')
end
%%%%%% PASTE AFTER THIS LINE %%%%%%%%%

    % forceOnPredator = compute_f_young (t, Frmax, Fymax, true, pr, vr, py, vy, 100, 100);

    % if(norm(forceOnPredator) == 0)
    if(norm(vr) == 0)
    % directionOfForce = [1;0];
    directionOfVelocity = [1;0];
    else
    % directionOfForce = forceOnPredator/norm(forceOnPredator);
    directionOfVelocity = vr/norm(vr);
    end
   % Fy = directionOfForce(2);
   % Fx = directionOfForce(1);
    Fy = directionOfVelocity(2);
    Fx = directionOfVelocity(1);

    ay1 = [-Fy; - Fx];
    ay2 = [ Fy;  -Fx];

    anticipatedPreyPosition1 = py + ay1/norm(ay1);
    anticipatedPreyPosition2 = py + ay2/norm(ay2);

    if((anticipatedPreyPosition1 - pr)>(anticipatedPreyPosition2 - pr)) % checking to see which distance is greater
        Fy = ay1;
    else
        Fy = ay2;
    end
distance = abs(pr-py);
  if (distance>10) % then harvest energy
    directionOfVelocity = vr/norm(vr);
    F = Fymax * -directionOfVelocity;
  else % go in direction perp to pred velocity
        F = Fymax*Fy;
% if it's really close to it, then go in perp direction to its velocity,
% not force.
  end


%%%%%% PASTE BEFORE THIS LINE %%%%%%%%%

end
end

function F  = compute_random_force(t,force_table)
% Computes value of fluctuating random force at time t, where 0<t<250.
% The variable force_table is a 251x2 matrix of pseudo-random
% numbers between -0.5 and 0.5, computed using
%  force_table = rand(251,2)-0.5;
% The force is in Newtons ? if you use another system of units you
% must convert.
 %F = [interp1(force_table(:,1),t+1);interp1(force_table(:,2),t+1)]/100;
  F = [interp1(force_table(:,1),t+1);interp1(force_table(:,2),t+1)]/100;

%F = 0;
end

function animate_projectiles(t,sols)
figure
xmax = max(max(sols(:,3)),max(sols(:,1)));
xmin = min(min(sols(:,3)),min(sols(:,1)));
ymax = max(max(sols(:,4)),max(sols(:,2)));
ymin = min(min(sols(:,4)),min(sols(:,2)));
dx = 0.1*(xmax-xmin)+0.5;
dy = 0.1*(ymax-ymin)+0.5;
for i = 1:length(t)
 clf
 plot(sols(1:i,3),sols(1:i,4),'LineWidth',2,'LineStyle',...
 ':','Color',[0 0 1]);
 ylim([ymin-dy ymax+dy]);
 xlim([xmin-dx xmax+dx]);
 hold on
 plot(sols(1:i,1),sols(1:i,2),'LineWidth',2,'LineStyle',':',...
 'Color',[1 0 0]);
 plot(sols(i,1),sols(i,2),'ro','MarkerSize',11,'MarkerFaceColor','r');
 plot(sols(i,3),sols(i,4),'ro','MarkerSize',5,'MarkerFaceColor','g');
 pause(0.1);
end
end
