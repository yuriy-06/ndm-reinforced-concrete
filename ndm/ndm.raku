#use trace;
use lib "lib";
use Coordinate;
use Surface;
use Data;
use Sigma;
use NDM;
use svg;

Data_.dlitRb;  # поправка Rb на длительность, если нужно
my $strWrl = slurp Data_.pathWrlFile;
my @coordList = coordList($strWrl);
# функция возвращает массив объектов координат
my @surfList = surfListExtract($strWrl);

my @jbSurf = reallyflat(@surfList.shift); # первый элемент массива - жб сечение
say "число КЭ жб сечения: $(@jbSurf.elems);";

my @armSurf = reallyflat(@surfList); # все остальные - арматура
say "число КЭ сечения арматуры: $(@armSurf.elems);";
#say @armSurf;
#----------------------------------------------------------------------------
say 'начали обсчет координат и площадей жб сечения;';
coordInit(@jbSurf, @coordList);  # нужно добавить узлы к элементам, обсчитать площади
say 'закончили обсчет площадей жб сечения, начали обсчет арматуры;';
coordInit(@armSurf, @coordList);
say 'закончили обсчет площадей элементов арматуры;';

# преобразуем КЕ в дочерние типы
say 'преобразуем КЕ в дочерние типы ЖБ и Арматуры;';
@jbSurf = @jbSurf.race.map({($_ but Sigma_b).init(Data_)});
@armSurf = @armSurf.race.map({($_ but Sigma_s).init(Data_)});

my Int $num = 1; # начальный номер итерации
# матрицы
my @b = [Data_.Mx, Data_.My, Data_.N];
my @d;
my Num ($r1x, $r1y, $e0);  # кривизны и деформация по центральной оси
my Num $e_; # фактическая деформация элемента
my Bool $pr; # признак успешности расчета

say 'начался основной цикл расчетов НДМ;';
my &ok = {round($_, 0.000001)};
while $num < Data_.iter-limit + 1
{
    @d = Darr(@jbSurf, @armSurf, Data_.Eb, Data_.Es); # Darr см. модуль NDM
    say "\nИтерация: $num;";
    say "\n@d = " ~ @d.map({ok $_}) ~ ';';
    ($r1x, $r1y, $e0) = linsolve(@d, @b);  # r1x - величина равная 1/rx
    say "\n" ~ '(1/rx, 1/ry, e0) = ' ~ ((ok $r1x), (ok $r1y), (ok $e0)) ~ ';';

    @jbSurf = @jbSurf.race.map({$_.sigma($e0 + $r1x*$_.zx + $r1y*$_.zy)}); # вычислили и задали относительные деф. для бетона, здесь же расчит-ся к-ты упругости для след. итерации, если потребуется
    @armSurf = @armSurf.race.map({$_.sigma($e0 + $r1x*$_.zx + $r1y*$_.zy)}); # вычислили и задали относительные деф. для арматуры
    #say @armSurf;

    if priznak(Data_.N, Data_.Mx, Data_.My, @jbSurf, @armSurf)
        {say "\nРасчет прочности жб сечения окончен успешно";
        $pr = True;
        $num = Data_.iter-limit + 1;}
    $num += 1;}

# далее выполняем расчет раскрытия и ширины трещин - дописать

if !$pr {say "\nРасчет окончился неудачей.";}
say "\nНачался вывод графики";
svg-export(@jbSurf, @armSurf);
say "\nвремя расчета: ";
print now - INIT now; say " сек";

# дописать вычислении пред. деформаций бетона при распределении по сечению напряжений одного знака п.8.1.30
