# здесь располагаются некоторые тесты

use Test;
use lib 'lib';
use Coordinate;
use np;
use Surface;
#use Math::Matrix;
use NDM;
#use Inline::Python;

my $fileStr = slurp 'wrl-test.wrl';

my $num-tests = 10;
plan $num-tests;

# Coordinate
is testCoordView(coordList($fileStr)), q:to/END/;
x = -0.15, y = -0.15, num = 0;
x = 0.15, y = -0.15, num = 1;
x = 0.15, y = 0.15, num = 2;
x = -0.15, y = 0.15, num = 3;
x = -0.1125, y = -0.1125, num = 4;
x = -0.1125, y = -0.08749999999999999, num = 5;
x = -0.125, y = -0.09999999999999999, num = 6;
x = -0.09999999999999999, y = -0.09999999999999999, num = 7;
x = 0.08518318299602902, y = 0.1092958241155231, num = 8;
x = 0.0800012494495031, y = 0.09741474834630535, num = 9;
x = 0.08571692940953789, y = 0.09233659998283703, num = 10;
x = 0.08124787485411515, y = 0.104798770350782, num = 11;
x = 0.08416379787352363, y = 0.09218750577619059, num = 12;
END
;

# np
is-approx average(2.15, 5.18, -0.12), 2.403333;
is-approx dot([2.53, 2.16, -1.5], [5.18, -1.15, 2.98]), 6.1514;

# Surface
#is surfaceExtract($fileStr), '';
is surfListExtract($fileStr)[1], '';
#is surfListExtract($fileStr)[1][0].Str, '';
my $k = KE.new(coordList => [[1902.5e0, 730.7e0], [2618.3e0, 1366.1e0], [1911.4e0, 2001.5e0], [1300.8e0, 1391.0e0]]);
$k.square;
is-approx $k.A, 837250.198;

# NDM
my @d = <2356.447154571489 2361.6595488542234 -0.008838366095673011 0.014513564003955759 -413.92507232410526 303099.9889260021>;
my @b = <9 1 9>;
#is-deeply linsolve(@d, @b), (0.003819310495701176, 0.00042875222686102103, 3.0278509402868324e-05);


done-testing;