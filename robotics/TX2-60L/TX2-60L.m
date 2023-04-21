% Script Name   : TX2-60L
% Description   : A simple script which calculates from hard-coded values
%                 the transform matrix, Jacobian, and formula for the
%                 determinant of the TX2-60L robot arm from Stäubli, as
%                 well as create an interactive rigid body tree
% Author        : Yang Geng
% Date Created  : 2023-04-20
% Last Modified : 2023-04-21

%% DH parameters validation
% Define DH parameters
%       a       alpha       d       theta
dh = [  0       -pi/2       375     0;      % 1
        400     0           20      0;      % 2
        0       -pi/2       0       0;      % 3
        0       -pi/2       450     0;      % 4
        0       pi/2        0       0;      % 5
        0       0           70      0];     % 6

% Create robot using DH parameters
robot = rigidBodyTree;
bodies = cell(6, 1);
joints = cell(6, 1);
for i = 1:6
    bodies{i} = rigidBody(['bdy' num2str(i)]);
    joints{i} = rigidBodyJoint(['jnt' num2str(i)], 'revolute');
    setFixedTransform(joints{i}, dh(i,:), "dh");
    bodies{i}.Joint = joints{i};
    if i == 1
        addBody(robot, bodies{i}, "base");
    else
        addBody(robot, bodies{i}, bodies{i-1}.Name);
    end
end

showdetails(robot);
gui = interactiveRigidBodyTree(robot, MarkerScaleFactor=200);



%% Calculate transform matrices and angular Jacobian
% declare syms; t stands for theta
syms a2
syms alpha1 alpha3 alpha4 alpha5
syms d1 d2 d4 d6
syms t [1 6]

% declare a symbolic version of the DH parameters with only non-zero values
%           a   alpha   d   theta
sym_dh = [  0   alpha1  d1  t1;     % 1
            a2  0       d2  t2;     % 2
            0   alpha3  0   t3;     % 3
            0   alpha4  d4  t4;     % 4
            0   alpha5  0   t5;     % 5
            0   0       d6  t6];    % 6

% symbolic function to calculate the transform matrix between neighbours
syms getTransform(a, alpha, d, theta)
getTransform(a, alpha, d, theta) = [    
    cos(theta)  -sin(theta)*cos(alpha)  sin(theta)*sin(alpha)   a*cos(theta);
    sin(theta)  cos(theta)*cos(alpha)   -cos(theta)*sin(alpha)  a*sin(theta);
    0           sin(alpha)              cos(alpha)              d;
    0           0                       0                       1];

T06 = getTransform(sym_dh(1,1), sym_dh(1,2), sym_dh(1,3), sym_dh(1,4));
Jw = sym(zeros(3, 6)); Jw(:,1) = T06(1:3, 3);
for i = 2:6
    T06 = T06 * getTransform(sym_dh(i,1), sym_dh(i,2), sym_dh(i,3), sym_dh(i,4));
    Jw(:,i) = T06(1:3, 3);
end
T06 = simplify(T06);
disp(T06);

% subsitute in known variables to further simplify
sub_T06 = simplify(subs(T06, ...
    [a2     alpha1  alpha3  alpha4  alpha5  d1  d2  d4  d6], ...
    [400    -pi/2   -pi/2   -pi/2   pi/2    375 20  450 70]));
disp(sub_T06);



%% Jacobian calculations
X = T06*[0;0;0;1]; X = X(1:3);
Jv = jacobian(X, [t1 t2 t3 t4 t5 t6]);
J = simplify([Jv;Jw]);
disp(J);
disp(rank(J));

sub_X = sub_T06*[0;0;0;1]; sub_X = sub_X(1:3);
sub_Jv = jacobian(sub_X, [t1 t2 t3 t4 t5 t6]);
sub_Jw = subs(Jw, ...
    [a2     alpha1  alpha3  alpha4  alpha5  d1  d2  d4  d6], ...
    [400    -pi/2   -pi/2   -pi/2   pi/2    375 20  450 70]);
sub_J = simplify([sub_Jv;sub_Jw]);
disp(sub_J);
disp(rank(sub_J));



%% Find formula for determinant
sub_D = simplify(det(sub_J));
disp(sub_D);
