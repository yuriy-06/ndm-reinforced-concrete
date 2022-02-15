use NdmRegex;
use np;
use Coordinate;
module Surface {
    class KE is export {
        has Int $.number;
        has Str $.n1;
        has Str $.n2;
        has Str $.n3;
        has Str $.n4;
        # начальное значение напряжения
        has $.sigma_v is rw = 0.0;
        has $.v is rw = 1.0;
        # к-т упругости элемента, начальное значение
        has $.E is rw;
        has $.e_  is rw = 0.0;
        # относительная деформация, начальное значение
        has $.A;
        has @.xlist;
        has $.x;
        # координата центра тяжести
        has $.zy;
        has @.ylist;
        has $.y;
        has $.zx;
        has @.coordList = [[Nil, Nil], [Nil, Nil], [Nil, Nil], [Nil, Nil]];
        method findCoord (@coordList) {
            for @coordList -> $node {
                if ($node.number == self.n1.Int) { self.coordList[0] = [$node.x.Num, $node.y.Num] };
                if ($node.number == self.n2.Int) { self.coordList[1] = [$node.x.Num, $node.y.Num] };
                if ($node.number == self.n3.Int) { self.coordList[2] = [$node.x.Num, $node.y.Num] };
                if ($node.number == self.n4.Int) { self.coordList[3] = [$node.x.Num, $node.y.Num] };
            }
            #self.checkNodes;
            self.square;
        }
        method checkNodes () {
            for @!coordList -> $elem {
                if $elem[0] === Nil { die "в элементе с узлами $!n1, $!n2, $!n3, $!n4 не нашлись координаты;" }
                if $elem[1] === Nil { die "в элементе с узлами $!n1, $!n2, $!n3, $!n4 не нашлись координаты;" }
            }
        }
        method square () {
            # площадь елемента вычисляет
            # протестировать если подавать координаты точек в разном порядке, сравнить с автокад
            for @!coordList -> $elem {
                @!xlist.push($elem[0]);
                @!ylist.push($elem[1]);
            }
            my $s1 = dot(@!xlist, @!ylist.rotate(1));
            # формула площади Гаусса
            my $s2 = dot(@!xlist, @!ylist.rotate(-1));
            # написать тест
            $!A = 0.5 * abs($s1 - $s2);
            $!x = average(@!xlist); # вычисляем координаты ц.т. сечения - нам это тоже надо
            $!zy = $!x;
            $!y = average(@!ylist);
            $!zx = -$!y;
        }
        method sigma ($s, $e0_) {
            $!e_ = $e0_;
            $s.newData($e0_);
            $!sigma_v = $s.sigma();
        }
    }

    sub surfaceExtract ($str) is export {
        # эспортируется в целях тестирования
        #my @surfArr;
        $str ~~ /(<surface>)/;
        my $last = $0.postmatch;
        if ($0) {
            # распаралеленный вариант, но он почему-то не дал ничего
            my @surfArr = $0<surface>[0].race.map({
                my ($node1, $node2, $node3, $node4) = $_.list;
                KE.new(n1 => $node1.Str, n2 => $node2.Str, n3 => $node3.Str, n4 => $node4.Str); });
            return [@surfArr, $last];
        } else {
            return [Nil, Nil];
        };
    }

    sub surfListExtract ($str) is export {
        my @mainSurf;
        # список списков
        my @surf;
        # сюда вклеиваются 2 рез-та
        my $last = $str;
        until ((@surf === Nil) or ($last === Any)) {
            @surf = surfaceExtract($last);  # этот вызов функции распаралелен с помощью hyper
            if @surf.elems != 2 { die 'Surface.surfListExtract.@surf.elems != 2'; }
            $last = @surf[1];
            if ($last === Any) { return @mainSurf; };
            if (@surf) {
                @mainSurf.push(@surf[0]);
            } else {
                return @mainSurf;
            };
        };
    }

    sub reallyflat (+@list) is export {
        gather @list.deepmap: *.take
    }

    sub coordInit (@surf, @nodes) is export {
        @surf.race.map({ $_.findCoord(@nodes) });
    }
}
