use Sp63_tables;
use Surface;

module Sigma {
    role Sigma_b is export {
        # деформации в элементе (по модулю)
        has Int $.N is rw; # -1 или 1 - знак деф-ий/напр-й
        has $.dataObject;
        has $.Eb;
        has $.Rb;
        has $.Rbt;
        has $.eb0 is rw;
        has $.ebt0 is rw;
        has $.eb1 is rw;
        has $.ebt1 is rw;
        has $.eb2 is rw;
        has $.ebt2 is rw;
        #has $.eb1_red; # используются при двухлинейной диаграмме
        #has $.ebt1_red;
        has $.sigma_b1;
        has $.sigma_bt1;
        has $.fi_b_cr; # к-т ползучести
        #has $.Ebt_red is rw;
        #has $.Eb_red is rw;
        has Str $.errorMsg;

        method init ($dataObject) {
            $!dataObject = $dataObject;
            $!Eb = $!dataObject.Eb;
            $!Rb = $!dataObject.Rb;
            $!Rbt = self.dataObject.Rbt;
            $!sigma_b1 = 0.6 * self.dataObject.Rb;
            $!sigma_bt1 = 0.6 * self.dataObject.Rbt;
            $!eb1 = self.sigma_b1 / self.dataObject.Eb;
            $!ebt1 = self.sigma_bt1 / self.dataObject.Eb;
            $!fi_b_cr = Sp63.fi_b_cr_dict<self.dataObject.W><self.dataObject.B>;
            # к-т ползучести
            self;
        }

        method newData ($e0_) {
            if $e0_ <= 0 { self.N = -1; } else { self.N = 1; }
            # в расчетах прочности и трещинообразования используют диаграмму работы бетона при непродолжительной длительности
            # для расчета величины раскрытия трещин используем фактическую длительнось нагрузок
            $!eb0 = abs($e0_);
            if self.dataObject.dlit eq 'no' { self.dlitNo; } elsif self.dataObject.dlit eq 'yes' { self.dlitYes; };
            #if self.N > 0 { self.Ebt_red = self.Rbt / self.ebt1_red; };
        }

        method dlitNo {
            if self.N <= 0
            {
                #self.eb1_red = 0.0015;
                # для тяжелого бетона
                if self.dataObject.B ∈ ['B5', 'B5', 'B10', 'B12.5', 'B15', 'B20', 'B25', 'B30', 'B35', 'B40', 'B45', 'B50', 'B55', 'B60']
                { self.eb2 = 0.0035; }
                elsif self.dataObject.B ∈ ['B70', 'B80', 'B90', 'B100']
                {
                    my %dict = ('B70' => 0.0033,
                                'B80' => 0.0031,
                                'B90' => 0.0030,
                                'B100' => 0.0028);
                    self.eb2 = %dict<self.dataObject.B>;
                }
            }
            if self.N > 0 { $!ebt2 = 0.00015; }
            $!eb0 = 0.002;
            $!ebt0 = 0.0001;
        }

        method dlitYes {
            self.Eb = self.Eb / (1 + self.fi_b_cr);
            if self.N >= 0 { (self.ebt0, self.ebt2, self.ebt1_red) = Sp63.t6_10_2<self.dataObject.W> }
            elsif self.N < 0 { (self.eb0, self.eb2, self.eb1_red) = Sp63.t6_10_1<self.dataObject.W> }
            if self.dataObject.B eq 'B70' { self.eb2 = self.eb2 * (270 - 70) / 210; }
            elsif self.dataObject.B eq 'B80' { self.eb2 = self.eb2 * (270 - 80) / 210; }
            elsif self.dataObject.B eq 'B90' { self.eb2 = self.eb2 * (270 - 90) / 210; }
            elsif self.dataObject.B eq 'B100' { self.eb2 = self.eb2 * (270 - 100) / 210; }
        }

        method sigma ($eb_) {
            self.newData($eb_);
            self.e_ = $eb_;
            my $eb = abs($eb_);
            # расчитываем напряжения бетона в зав-ти относит. деформаций
            #self.check; # проверка инициализации атрибутов выключена
            if self.N <= 0 {
                if $eb <= self.eb1
                    { self.sigma_v = - self.Eb * $eb;
                    return self.checkSigma('self.N <= 0, $eb <= self.eb1' ~ ";\n eb = $eb" ~ ";\n self.e_ = $(self.e_)");}
                elsif self.eb1 < $eb <= self.eb0
                    { self.sigma_v = - ((1 - self.sigma_b1 / self.Rb) * (($eb - self.eb1) / (self.eb0 - self.eb1)) + self.sigma_b1 / self.Rb) * self.Rb;
                    return self.checkSigma('self.N <= 0, self.eb1 < $eb < self.eb0');}
                elsif self.eb0 < $eb <= self.eb2
                    { self.sigma_v = - self.Rb;
                    return self.checkSigma('self.N <= 0, self.eb0 < $eb < self.eb2');}
                elsif $eb > self.eb2 {
                    self.sigma_v = - self.Rb;
                    return self.checkSigma('self.N <= 0, $eb > self.eb2');}
                }
            if self.N > 0
            {
                if 0 <= $eb <= self.ebt1
                    { self.sigma_v = self.Eb * $eb;
                    return self.checkSigma('self.N > 0, 0 <= $eb <= self.ebt1');}
                elsif self.ebt1 < $eb <= self.ebt0
                    { self.sigma_v = ((1 - self.sigma_bt1 / self.Rbt) * (($eb - self.ebt1) / (self.ebt0 - self.ebt1)) + self.sigma_bt1 / self.Rbt) * self.Rbt;
                    return self.checkSigma('self.N > 0, self.ebt1 < $eb < self.ebt0');}
                elsif self.ebt0 < $eb <= self.ebt2
                    { self.sigma_v = self.Rbt;
                    return self.checkSigma('self.N > 0, self.ebt0 < $eb < self.ebt2');}
                elsif $eb > self.ebt2
                    {
                        #self.sigma_v = self.Rbt;
                        self.sigma_v = 0;
                    return self.checkSigma('$eb > self.ebt2');}
            }
        }

        method check {
            if !self.N { die "self.N"; }
            if !self.Eb { die "self.Eb" }
            if self.N < 0 {
                if !self.eb2 {die "self.eb2"}
                if !self.eb1 { die "self.eb1" }
                if !self.eb0 { die "self.eb0" }
                if !self.sigma_b1 { die "self.sigma_b1" }
                if !self.Rb { die "self.Rb" }
            }
            if self.N > 0
            {
                if !self.ebt2 {die "self.ebt2"}
                if !self.ebt1 { die "self.ebt1" }
                if !self.ebt0 { die "self.ebt0" }
                if !self.Rbt { die "self.Rbt" }
                if !self.sigma_bt1 { die "self.sigma_bt1" }
            }
        }
        method checkSigma ($msg){
            $!errorMsg = $msg;
            self.v = self.sigma_v / ($!Eb * self.e_);
            if self.e_ * self.sigma_v < 0 {die 'self.e_ * self.sigma_v < 0' ~ $msg}
            return self;
        }
    }

    role Sigma_s is export {
        has $.dataObject;
        has $.Rs;
        has $.Es;
        has $.es2 = 0.025;
        has $.es0;
        has $.es is rw;
        has $.N is rw;
        # знак напряжения в элементе
        method init ($dataObject) {
            $!dataObject = $dataObject;
            $!Rs = self.dataObject.Rs;
            $!Es = self.dataObject.Es;
            $!es0 = self.dataObject.Rs / self.dataObject.Es;
            # не используем в расчетах арматуру с условныи пределом текучести (в этом случае другая ф-ла будет)
            self;
        }
        method sigma ($es) {
            self.e_ = $es;
            self.es = abs($es);
            if self.e_ > 0 { self.N = 1 } else { self.N = -1 }
            if (0 < abs(self.es) < self.es0) {
                self.sigma_v = self.e_ * self.Es;
                self.v = self.sigma_v / ($!Es * self.e_);
                return self;
                # $!e_ определено в родительском классе, перед вызовом метода его надо установить
            }
            if (self.es0 <= abs(self.es) <= self.es2) {
                self.sigma_v = self.Rs * $!N;
                self.v = self.sigma_v / ($!Es * self.e_);
                return self;
            }
            if (abs(self.es) > self.es2) {
                #self.sigma_v = 0; self.v = 0; return self;
                self.sigma_v = self.Rs * $!N;
                self.v = self.sigma_v / ($!Es * self.e_);
                return self;
            }
        }
    }
}
