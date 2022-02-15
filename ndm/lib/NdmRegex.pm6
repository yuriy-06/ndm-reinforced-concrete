module NdmRegex {

    my regex beginCoord  is export {
        Coordinate3\s\{\n\s+point\s\[\n 
    }
    
    my regex number  is export {
        \- ** 0..1 
        \d* 
        \. ** 0..1 
        \d* 
        e ** 0..1 
        <[+-]> ** 0..1
        \d* 
    }

    my regex coordString is export {
        (<number>) \s (<number>) \s <number> \, \n
    }

    my regex surfaceString  is export {
        \d+ \, \d+ \, \d+ \, \d+ \,
        \- ** 0..1 \d+ \, \n
        # 4375,1814,6163,4374,-1,
    }
    
    my regex surface is export {
        ((\d+) \, (\d+) \, (\d+) \, (\d+) \,
        \- ** 0..1 \d+ \, \n)+
        # 4375,1814,6163,4374,-1,
    }

}