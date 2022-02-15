use Math::Matrix;
use Data;
module NDM {
    # модуль определяет основные функции вычислений по теории НДМ,
    # за исключением зависимостей напряжений-деформаций по диаграммам (см. модуль sigma)
    # вычисляем жесткостные характеристики сечения ф. 8.42-8.47 СП63
    sub  d(&f) {
        sub func(@jbArr, @armArr, $Eb, $Es) {
            my Num $sum = 0e0;
            sub sumf (@arr, $E) {
                for @arr -> $el
                { $sum += &f($el, $E); }
            }
            sumf(@jbArr, $Eb);
            sumf(@armArr, $Es);
            return $sum;
        }
        return  &func;
    }

    our &d11 is export = d(-> $e, $Em { $e.A * $e.zx ** 2 * $Em * $e.v; });
    our &d22 is export = d(-> $e, $Em  { $e.A * $e.zy ** 2 * $Em * $e.v });
    our &d12 is export = d(-> $e, $Em  { $e.A * $e.zx * $e.zy * 2 * $Em * $e.v });
    our &d13 is export = d(-> $e, $Em  { $e.A * $e.zx * $Em * $e.v });
    our &d23 is export = d(-> $e, $Em  { $e.A * $e.zy * $Em * $e.v });
    our &d33 is export = d(-> $e, $Em  { $e.A * $Em * $e.v });
    sub Darr (@jbArr, @armArr, $Eb, $Es) is export {
        return (&d11(@jbArr, @armArr, $Eb, $Es),
                &d22(@jbArr, @armArr, $Eb, $Es),
                &d12(@jbArr, @armArr, $Eb, $Es),
                &d13(@jbArr, @armArr, $Eb, $Es),
                &d23(@jbArr, @armArr, $Eb, $Es),
                &d33(@jbArr, @armArr, $Eb, $Es));
    }

    # вычисляем правые части уравнений 8.26-8.27 СП63
    sub force(&f) 
    {
        sub func(@jbArr, @armArr)
        {
            my $sum = 0;
            for @jbArr -> $e
            { $sum += &f($e); }
            for @armArr -> $e
            { $sum += &f($e); }
            return $sum;
        }
        return &func;
    }

    my &mxf = force(-> $e { $e.A * $e.sigma_v * $e.zx });
    my &myf = force(-> $e  { $e.A * $e.sigma_v * $e.zy });
    my &nf = force(-> $e { $e.A * $e.sigma_v });

    # в цикле выполняем проверки уравнений 8.26-8.27 СП63
    sub temp()
    {
        # отсюда вернем функцию признак со встроенным счетчиком
        my Int $count = 1;
        sub priznak ($N, $Mx, $My, @jbKElist, @armKElist)
        {
            sub check($forceV, &forceFunc, $str)
            {
                my $v = forceFunc(@jbKElist, @armKElist);
                if $forceV == 0 and $v < Data_.error_pr {return False; }
                if $forceV == 0 and $v > Data_.error_pr {return True; }
                my $val = abs(($forceV - $v) / $v);
                if abs($forceV - $v) < Data_.abs_error {return False;}
                if $val > Data_.error_pr
                {
                    $count += 1;
                    say "\nОшибка расхождения для первой неудачи в долях составила $(round($val,0.001)).; для $str";
                    say "Ошибка: $(round($val,0.001)) = abs(($forceV - $(round($v, 0.001))) / $(round($v,0.001)))";
                    return True;
                    # проверка не выполняется
                }
            }
            if check($Mx, &mxf, 'Mx') { return False; }
            # если первое уравнение не сходится остальные проверять не надо
            if check($My, &myf, 'My') { return False; }
            if check($N, &nf, 'N')  { return False; }
            say 'Число итераций: ' ~ $count;
            return True;
        }
        return &priznak;
    }

    our &priznak is export = temp();

    sub linsolve (@d, @b) is export {
        my ($d11, $d22, $d12, $d13, $d23, $d33) = @d;
        my $Am = Math::Matrix.new([
            [$d11, $d12, $d13],
            [$d12, $d22, $d23],
            [$d13, $d23, $d33]
        ]);
	#my $l = $Am.Cholesky-decomposition();
        my ($L, $U) = $Am.LU-decomposition();	
        my $y1 = @b[0] / $L.element(0, 0);
        my $y2 = (@b[1] - $y1 * $L.element(1, 0)) / $L.element(1, 1);
        my $y3 = (@b[2] - $y1 * $L.element(2, 0) - $y2 * $L.element(2, 1)) / $L.element(2, 2);
	#my $t = $l.transposed;
        my $x3 = $y3 / $U.element(2, 2);
        my $x2 = ($y2 - $x3 * $U.element(1, 2)) / $U.element(1, 1);
        my $x1 = ($y1 - $x3 * $U.element(0, 2) - $x2 * $U.element(0, 1)) / $U.element(0, 0);
        ($x1, $x2, $x3);
    }

}
