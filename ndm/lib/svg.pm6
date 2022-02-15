use Surface;
use Data;
module svg {
    my &ok = {round($_, 0.0001)};
    sub svg-export (@surfJB, @surfArm) is export {
        #say @surfJB;
        my @xlist; my @ylist;
        # минимальные и максимальные значения напряжений материалов
        my $max_s_arm; my $min_s_arm; my $max_s_jb; my $min_s_jb;
        # минимальные и максимальные значения деформаций материалов
        my $max_def_arm; my $max_def_jb; my $min_def_arm; my $min_def_jb;

        sub s_def (@arr) {
            my $min_def = @arr[0].e_; my $max_def  = @arr[0].e_;
            my $min_s = @arr[0].sigma_v; my $max_s = @arr[0].sigma_v;
            for @arr -> $e {
                @xlist.push($e.xlist);
                @ylist.push($e.ylist);
                $min_def = min($e.e_, $min_def);
                $max_def = max($e.e_, $max_def);
                $min_s = min($e.sigma_v, $min_s);
                $max_s = max($e.sigma_v, $max_s);
            }
            return [$min_def, $max_def, $min_s, $max_s];
        }

        ($min_def_arm, $max_def_arm, $min_s_arm, $max_s_arm) = s_def(@surfArm);
        ($min_def_jb, $max_def_jb, $min_s_jb, $max_s_jb) = s_def(@surfJB);

        say "минимальное и максимальное напряжение в арматуре = ($(ok($min_s_arm)), $(ok($max_s_arm))) тс/м2";
        say "минимальное и максимальное напряжение в бетоне = ($(ok($min_s_jb)), $(ok($max_s_jb))) тс/м2";
        say "минимальное и максимальная отнюсит. деф-ия в арматуре = ($(ok($min_def_arm)), $(ok($max_def_arm))) ";
        say "минимальное и максимальная отнюсит. деф-ия в бетоне = ($(ok($min_def_jb)), $(ok($max_def_jb))) ";

        @xlist = reallyflat(@xlist); # превращаем список в плоский
        @ylist = reallyflat(@ylist);
        my ($min_x, $max_x) = (min(@xlist), max(@xlist));
        my ($min_y, $max_y) = (min(@ylist), max(@ylist));
        # вычисляем координаты центра изображения
        my $x_center = ($min_x + $max_x)/2;
        my $y_center = ($min_y + $max_y)/2;
        my $svg-center-x = (Data_.svg-width)/2;
        my $svg-center-y = (Data_.svg-height)/2;
        my $addit-x = $svg-center-x - $x_center; # поправка для координат, чтоб центрировать изображение в цент svg поля, поправка прибавляется
        my $addit-y = $svg-center-y - $y_center;
        # вычислим к-ты масштабирования по Х и У
        my $kx = (Data_.svg-width - 2*Data_.svg-field)/($max_x - $min_x);
        my $ky = (Data_.svg-height - 2*Data_.svg-field)/($max_y - $min_y);
        my $k = min($kx,$ky); # общий к-т масштабирования (на него умножаем реальные кординаты)
        # запустили цикл преобразования координат элементов
        sub coord ($elem) {
            sub ct (@arr) {
                return [@arr[0]*$k + $addit-x, @arr[1]*$k + $addit-y];
            }
            $elem.coordList = map(&ct, $elem.coordList);
            return $elem;
        }
        @surfJB = @surfJB.map({coord($_)});
        @surfArm = @surfArm.map({coord($_)});
        # далее непосредственно надо вывести изображение
        svg-main(@surfArm, @surfJB, $min_s_arm, $max_s_arm, $min_s_jb, $max_s_jb, {$^a.sigma_v}, "sigma.svg");
        svg-main(@surfArm, @surfJB, $min_def_arm, $max_def_arm, $min_def_jb, $max_def_jb, {$^a.e_}, "deform.svg");
    }

    sub body ($body) {
            return "<?xml version=\"1.0\" standalone=\"no\"?>
<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"
  \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">
<svg width=\"$(Data_.svg-width)\" height=\"$(Data_.svg-height)\" version=\"1.1\" id=\"toplevel\"
    xmlns=\"http://www.w3.org/2000/svg\"
    xmlns:xlink=\"http://www.w3.org/1999/xlink\">" ~ $body ~ '</svg>'
    }

    sub poligon ($elem, $min, $max, $val) {
        my $color;
        my $c = $elem.coordList;
        my ($x1, $y1) = $c[0];
        my ($x2, $y2) = $c[1];
        my ($x3, $y3) = $c[2];
        my ($x4, $y4) = $c[3];
        '<polygon points="' ~  "$(round $x1),$(round $y1) $(round $x2),$(round $y2) $(round $x3),$(round $y3) $(round $x4),$(round $y4)" ~ '"
            fill="' ~ color($min, $max, $val) ~ '" stroke="black" />' ~ "\n";
    }

    sub svg-main (@arr1, @arr2, $min_arm, $max_arm, $min_jb, $max_jb, &f, $fileName){
        my $svg = open($fileName, :w);
        sub work(@arr, $min, $max) {
            my $svg-string = '';
            for @arr.map({poligon($_, $min, $max, f($_))}) -> $elem {
                $svg-string = $svg-string ~ $elem;
            }
            return $svg-string;
        }
        $svg.say(body(work(@arr1, $min_arm, $max_arm) ~ work(@arr2,  $min_jb, $max_jb)));
        $svg.close();
    }

    sub color ($min, $max, $val) {
        my $layer = round((($val - $min)/($max - $min))*255);
        if $layer < 0 {say "\$min, \$max, \$val = $(ok($min)), $(ok($max)), $(ok($val))";}
        return "rgb($layer, $(255 - $layer), 0)";
    }
}