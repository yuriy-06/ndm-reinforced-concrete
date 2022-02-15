module Data {
    class Data_ is export {
        my $.B = 'B25';
        my $.A = 'A500';
        my $.Eb = 3e6; # модуль упругости бетона
        my $.Rb = 14.5 * 100;
        my $.Rbt = 1.05 * 100;
        my $.Rs = 435 * 100;
        my $.gamma_b2 = 1;
        my $.Es = 2.0e7;
        # модуль упругости арматуры
        my $.dlit = 'no'; # 'yes' or 'no'
        my $.N = -5;  # тс
        # тс
        my $.Mx = -2.1;  # тс*м
        # тс*м
        my $.My = -0.2;  # тс*м
        # тс*м
        my $.pathWrlFile = "./jb_test.wrl"; # файл wrl
        my $.W = '40-75'; # влажность твердения бетона, возможные значения: '40-75' '>75' '<40' - используется в расчете на длительное воздействие
	    my $.iter-limit = 30; # предельное число итераций поиска решения
        my $.error_pr = 0.05; # относительная допускаемая ошибка в долях
        my $.abs_error = 0.05; # абсолютная допускаемая ошибка (тс, тс*м)
        my $.svg-width = 900; # пиксели
        my $.svg-height = 900;
        my $.svg-field = 100; # поле рисунка
        method dlitRb() {
            if self.dlit eq 'yes' {
                    self.Rb = self.Rb * 0.9 * self.gamma_b2;
                    self.Rbt = self.Rbt * 0.9 * self.gamma_b2;}
        }
    }
}
