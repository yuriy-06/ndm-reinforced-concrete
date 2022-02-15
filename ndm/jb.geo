b = 0.3;
h = 0.3;
d = 0.025;
a = 0.05; //защитный слой бетона (центр тяжести)

meshSize = d/4;
// квадрат
Point(1) = {-b/2, -h/2, 0, meshSize};
Point(2) = {b/2, -h/2, 0, meshSize};
Point(3) = {b/2, h/2, 0, meshSize};
Point(4) = {-b/2, h/2, 0, meshSize};
// круг
meshSize = d/8;
Point(5) = {-b/2 + a -d/2, -h/2 + a -d/2, 0, meshSize};
Translate {0, d, 0}{ Duplicata{ Point{5}; } } // можно копировать точки
Translate {-d/2, d/2, 0}{ Duplicata{ Point{5}; } }
Translate {d/2, d/2, 0}{ Duplicata{ Point{5}; } }
Translate {0, d/2, 0}{ Duplicata{ Point{5}; } }
Physical Point(1) = {5,6,7,8,9}; // можно точки объединить в сущность чтоб потом все их копировать

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

Circle(5) = {5,9,7};
Circle(6) = {7,9,6};
Circle(7) = {6,9,8};
Circle(8) = {8,9,5};

Curve Loop(1) = {1, 2, 3, 4};
Curve Loop(2) = {5, 6, 7, 8};
dist = h-2*a;
Translate {0, dist, 0}{ Duplicata{ Point{9}; } } // тут я еще не догадался что можно копировать группу точек
Translate {-d/2, 0, 0}{ Duplicata{ Point{10}; } }
Translate {0, -d/2, 0}{ Duplicata{ Point{10}; } }
Translate {d/2, 0, 0}{ Duplicata{ Point{10}; } }
Translate {0, d/2, 0}{ Duplicata{ Point{10}; } }

Circle(9) = {12,10,11};
Circle(10) = {11,10,14};
Circle(11) = {14,10,13};
Circle(12) = {13,10,12};
Curve Loop(3) = {9, 10, 11, 12};

dist = b-2*a;
Translate {dist, 0, 0}{ Duplicata{Physical Point{1}; } } // скопировали сразу группу точек
Translate {dist, 0, 0}{ Duplicata{Curve{5}; } }
Translate {dist, 0, 0}{ Duplicata{Curve{6}; } }
Translate {dist, 0, 0}{ Duplicata{Curve{7}; } }
Translate {dist, 0, 0}{ Duplicata{Curve{8}; } }
Curve Loop(4) = {13, 14, 15, 16};

Translate {b-2*a, h-2*a, 0}{ Duplicata{Physical Point{1}; } } // скопировали сразу группу точек
dist = h-2*a;
Translate {0, dist, 0}{ Duplicata{Curve{13}; } }
Translate {0, dist, 0}{ Duplicata{Curve{14}; } }
Translate {0, dist, 0}{ Duplicata{Curve{15}; } }
Translate {0, dist, 0}{ Duplicata{Curve{16}; } }
Curve Loop(5) = {17, 18, 19, 20};

Plane Surface(1) = {1,2,3,4,5}; //сечение бетона
Plane Surface(2) = {2}; //арматура 1
Plane Surface(3) = {3}; //арматура 2
Plane Surface(4) = {4}; //арматура 3
Plane Surface(5) = {5}; //арматура 4
//Physical Surface("jb section") = {1}; // жб
//Physical Surface("arm1") = {2}; // арматура
//Physical Surface("arm2") = {3}; // арматура
//Physical Surface("arm3") = {4}; // арматура
//Physical Surface("arm4") = {5}; // арматура

Mesh 2;
RecombineMesh;
Save "jb.vrl"; //строчка почему-то не работает
