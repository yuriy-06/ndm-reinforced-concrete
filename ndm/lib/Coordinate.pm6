use NdmRegex;
module Coordinate {
    class Coord is export {
        has Str $.x;
        has Str $.y;
        has Int $.number;
        method testView () {
            return "x = $!x, y = $!y, num = $!number;\n";
        }
    }
    sub coordList (Str $str) is export {
        # функция извлекает ообъекты координат из строки
        $str ~~ /(<coordString>)+/;
        my Int $i = 0;  # как ни странно, но в surface мне попал КЭ с узлом 0
        my Coord @coordList;  # сюда загнали объекты коодинат
        sub lp ($elem) {
            my $x = $elem<coordString>[0]<number>.Str;
            my $y = $elem<coordString>[1]<number>.Str;
            @coordList.push(Coord.new(:$x, :$y, number => $i));
            $i += 1;
        }
        $0.hyper.map(&lp);
        say "узлов: $i;";
        @coordList;
    };

    sub testCoordView (@arr) is export {
        my $str = '';
        for @arr -> $elem {
            $str = $str ~ $elem.testView;
        }
        $str;
    }
}
