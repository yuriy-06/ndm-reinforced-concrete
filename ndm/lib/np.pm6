module np {
    sub dot (@l1, @l2) is export  {
        my Num $sum = 0e0;
        for zip(@l1, @l2) -> $e {
            $sum = $sum + $e[0]*$e[1];
         };
        $sum;
    }
    sub average (+@list) is export {
        my Num $sum = 0e0;
        for @list -> $elem {
            $sum = $sum + $elem;
        }
        $sum/@list.elems;
    }
}